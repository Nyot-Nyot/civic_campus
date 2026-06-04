-- Migration: create-functions-and-triggers
-- Database functions + triggers for CIVIC Campus

-- 3.1 submit_report_secure
create or replace function public.submit_report_secure(
  p_location_id uuid,
  p_location_details text,
  p_category_id uuid,
  p_description text,
  p_existing_incident_id uuid default null
) returns jsonb
language plpgsql
security definer
as $$
declare
  v_user_id uuid;
  v_report_id uuid;
  v_incident_id uuid;
  v_result jsonb;
begin
  v_user_id := auth.uid();

  insert into public.reports (user_id, location_id, location_details, category_id, description)
  values (v_user_id, p_location_id, p_location_details, p_category_id, p_description)
  returning id into v_report_id;

  if p_existing_incident_id is not null then
    if not exists (select 1 from public.incidents where id = p_existing_incident_id and status not in ('Closed', 'Resolved')) then
      raise exception 'Incident not available for confirmation';
    end if;

    update public.reports set incident_id = p_existing_incident_id where id = v_report_id;

    insert into public.confirmations (user_id, incident_id)
    values (v_user_id, p_existing_incident_id)
    on conflict (user_id, incident_id) do nothing;

    v_incident_id := p_existing_incident_id;

    update public.incidents
    set priority_score = priority_score + 5,
        updated_at = now()
    where id = v_incident_id;
  else
    insert into public.incidents (title, location_id, category_id, reporter_id, priority_score)
    values (
      coalesce(p_description, 'Laporan ' || (select name from public.categories where id = p_category_id)),
      p_location_id,
      p_category_id,
      v_user_id,
      10
    )
    returning id into v_incident_id;

    update public.reports set incident_id = v_incident_id where id = v_report_id;
  end if;

  insert into public.audit_logs (actor_id, action, entity_type, entity_id, metadata)
  values (v_user_id, 'report_created', 'report', v_report_id,
    jsonb_build_object('incident_id', v_incident_id, 'category_id', p_category_id));

  return jsonb_build_object(
    'report_id', v_report_id,
    'incident_id', v_incident_id
  );
end;
$$;

-- 3.2 dedup_score_candidates
create or replace function public.dedup_score_candidates(
  p_location_id uuid,
  p_category_id uuid,
  p_description text default ''
) returns table (
  incident_id uuid,
  title text,
  score integer,
  location_name text,
  category_name text,
  status text,
  confirm_count bigint,
  updated_at timestamptz
)
language plpgsql
security definer
as $$
declare
  v_location public.locations;
  v_location_type text;
  v_parent_id uuid;
begin
  select * into v_location from public.locations where id = p_location_id;
  v_location_type := v_location.type;
  v_parent_id := v_location.parent_id;

  return query
  with candidate as (
    select
      i.id,
      i.title,
      i.status,
      i.updated_at,
      l.type as location_type,
      l.parent_id as location_parent_id,
      l2.parent_id as floor_parent_id,
      case
        when i.location_id = p_location_id then 50
        when l.parent_id = v_parent_id and v_location_type = 'Area' then 30
        when l.parent_id = v_parent_id and v_location_type = 'Floor' then 20
        when l2.parent_id = v_parent_id then 20
        else 0
      end as location_score,
      case
        when i.category_id = p_category_id then 30
        else 0
      end as category_score,
      case
        when i.updated_at > now() - interval '24 hours' then 20
        when i.updated_at > now() - interval '7 days' then 10
        else 5
      end as time_score
    from public.incidents i
    join public.locations l on i.location_id = l.id
    left join public.locations l2 on l.parent_id = l2.id
    where i.status not in ('Closed')
      and i.is_rejected = false
      and (i.location_id = p_location_id
        or l.parent_id = v_parent_id
        or (v_location_type = 'Area' and l.parent_id = v_parent_id)
      )
  )
  select
    c.id,
    c.title,
    (c.location_score + c.category_score + c.time_score)::integer as total_score,
    (select name from public.locations where id = i.location_id),
    (select name from public.categories where id = i.category_id),
    c.status,
    (select count(*) from public.confirmations where incident_id = c.id),
    c.updated_at
  from candidate c
  join public.incidents i on c.id = i.id
  where (c.location_score + c.category_score + c.time_score) >= 40
  order by total_score desc;
end;
$$;

-- 3.3 get_dashboard_stats
create or replace function public.get_dashboard_stats()
returns jsonb
language sql
security definer
stable
as $$
select jsonb_build_object(
  'open_incidents', (select count(*) from public.incidents where status in ('Open', 'Assigned', 'In Progress')),
  'unassigned_incidents', (select count(*) from public.incidents where status = 'Open' and assigned_to is null),
  'high_critical_incidents', (select count(*) from public.incidents where priority_label in ('High', 'Critical') and status not in ('Closed')),
  'resolved_this_week', (select count(*) from public.incidents where status = 'Resolved' and updated_at > now() - interval '7 days'),
  'overdue_incidents', (select count(*) from public.incidents where is_overdue = true),
  'total_users', (select count(*) from public.profiles where is_active = true),
  'total_staff', (select count(*) from public.profiles where role = 'Maintenance Staff' and is_active = true),
  'total_reports_today', (select count(*) from public.reports where created_at > now() - interval '24 hours')
);
$$;

-- 3.4 get_staff_workload
create or replace function public.get_staff_workload()
returns table (
  staff_id uuid,
  staff_name text,
  active_tasks bigint,
  total_tasks bigint
)
language sql
security definer
stable
as $$
select
  p.id,
  p.name,
  count(*) filter (where i.status in ('Assigned', 'In Progress')) as active_tasks,
  count(*) as total_tasks
from public.profiles p
left join public.incidents i on i.assigned_to = p.id
where p.role = 'Maintenance Staff' and p.is_active = true
group by p.id, p.name
order by active_tasks desc;
$$;

-- 3.5 Trigger log_status_change -> status_history
create or replace function public.log_status_change()
returns trigger
language plpgsql
security definer
as $$
begin
  if old.status is distinct from new.status then
    insert into public.status_history (incident_id, from_status, to_status, actor_id)
    values (new.id, old.status, new.status, auth.uid());

    if new.status in ('Resolved', 'Closed') then
      new.is_overdue := false;
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_status_change
  before update on public.incidents
  for each row
  when (old.status is distinct from new.status)
  execute function public.log_status_change();

-- 3.6 Trigger create_incident_notification -> notifications
create or replace function public.create_incident_notification()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.assigned_to is distinct from old.assigned_to and new.assigned_to is not null then
    insert into public.notifications (user_id, type, title, body, entity_type, entity_id)
    values (new.assigned_to, 'incident_assigned', 'Tugas Baru',
      'Anda ditugaskan untuk: ' || new.title, 'incident', new.id);
  end if;

  if old.status is distinct from new.status then
    insert into public.notifications (user_id, type, title, body, entity_type, entity_id)
    values (new.reporter_id, 'status_changed', 'Status Diperbarui',
      'Insiden "' || new.title || '" berubah menjadi ' || new.status, 'incident', new.id);
  end if;

  return new;
end;
$$;

create trigger trg_incident_notification
  after update on public.incidents
  for each row
  when (old.assigned_to is distinct from new.assigned_to
     or old.status is distinct from new.status)
  execute function public.create_incident_notification();

-- 3.7 Trigger log_audit_event -> audit_logs
create or replace function public.log_audit_event()
returns trigger
language plpgsql
security definer
as $$
begin
  if old.status is distinct from new.status then
    insert into public.audit_logs (actor_id, action, entity_type, entity_id, previous_value, new_value)
    values (auth.uid(), 'status_changed', 'incident', new.id,
      jsonb_build_object('status', old.status),
      jsonb_build_object('status', new.status));
  end if;

  if old.assigned_to is distinct from new.assigned_to then
    insert into public.audit_logs (actor_id, action, entity_type, entity_id, previous_value, new_value)
    values (auth.uid(), 'incident_assigned', 'incident', new.id,
      jsonb_build_object('assigned_to', old.assigned_to),
      jsonb_build_object('assigned_to', new.assigned_to));
  end if;

  return new;
end;
$$;

create trigger trg_audit_log
  after update on public.incidents
  for each row
  when (old.status is distinct from new.status
     or old.assigned_to is distinct from new.assigned_to)
  execute function public.log_audit_event();
