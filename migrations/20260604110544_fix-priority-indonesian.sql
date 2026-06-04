-- Migration: fix-priority-indonesian
-- Switch priority_label to Indonesian, add auto-escalation trigger

-- 1. Update check constraint and default to Indonesian
alter table public.incidents
  drop constraint if exists incidents_priority_label_check,
  alter column priority_label set default 'Rendah';

alter table public.incidents
  add constraint incidents_priority_label_check
  check (priority_label in ('Rendah', 'Sedang', 'Tinggi'));

-- 2. Update existing seed data to Indonesian
update public.incidents
  set priority_label = 'Rendah'
  where priority_label in ('Low', 'Critical');

update public.incidents
  set priority_label = 'Sedang'
  where priority_label = 'Medium';

update public.incidents
  set priority_label = 'Tinggi'
  where priority_label = 'High';

-- 3. Update submit_report_secure to set initial priority_label
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
  else
    insert into public.incidents (title, location_id, category_id, reporter_id, priority_score, priority_label)
    values (
      coalesce(p_description, 'Laporan ' || (select name from public.categories where id = p_category_id) || ' di ' || (select name from public.locations where id = p_location_id)),
      p_location_id,
      p_category_id,
      v_user_id,
      10,
      'Rendah'
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

-- 4. Auto-escalation trigger: confirmation increases priority
create or replace function public.escalate_priority_on_confirm()
returns trigger
language plpgsql
security definer
as $$
declare
  v_score integer;
  v_current_label text;
  v_new_label text;
begin
  select priority_score, priority_label
  into v_score, v_current_label
  from public.incidents
  where id = new.incident_id;

  if not found then
    return new;
  end if;

  v_score := v_score + 5;

  v_new_label := case
    when v_score >= 40 then 'Tinggi'
    when v_score >= 20 then 'Sedang'
    else 'Rendah'
  end;

  -- Only upgrade, never downgrade
  if v_new_label = 'Tinggi' or (v_new_label = 'Sedang' and v_current_label = 'Rendah') then
    update public.incidents
    set priority_score = v_score,
        priority_label = v_new_label,
        updated_at = now()
    where id = new.incident_id;
  else
    update public.incidents
    set priority_score = v_score,
        updated_at = now()
    where id = new.incident_id;
  end if;

  return new;
end;
$$;

create trigger trg_escalate_priority_on_confirm
  after insert on public.confirmations
  for each row
  execute function public.escalate_priority_on_confirm();

-- 5. Update dashboard stats to use Indonesian labels
create or replace function public.get_dashboard_stats()
returns jsonb
language sql
security definer
stable
as $$
select jsonb_build_object(
  'open_incidents', (select count(*) from public.incidents where status in ('Open', 'Assigned', 'In Progress')),
  'unassigned_incidents', (select count(*) from public.incidents where status = 'Open' and assigned_to is null),
  'high_critical_incidents', (select count(*) from public.incidents where priority_label = 'Tinggi' and status not in ('Closed')),
  'resolved_this_week', (select count(*) from public.incidents where status = 'Resolved' and updated_at > now() - interval '7 days'),
  'overdue_incidents', (select count(*) from public.incidents where is_overdue = true),
  'total_users', (select count(*) from public.profiles where is_active = true),
  'total_staff', (select count(*) from public.profiles where role = 'Maintenance Staff' and is_active = true),
  'total_reports_today', (select count(*) from public.reports where created_at > now() - interval '24 hours')
);
$$;
