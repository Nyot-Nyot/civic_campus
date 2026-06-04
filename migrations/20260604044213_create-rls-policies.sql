-- Migration: create-rls-policies
-- Row Level Security for all 13 tables

-- Helper: check if current user has role
create or replace function public.has_role(required_role text)
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = required_role and is_active = true
  );
$$;

create or replace function public.has_any_role(required_roles text[])
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = any(required_roles) and is_active = true
  );
$$;

-- ==========================================
-- profiles
-- ==========================================
alter table public.profiles enable row level security;

create policy "profiles_select_own"
  on public.profiles for select
  using (id = auth.uid());

create policy "profiles_select_admin"
  on public.profiles for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "profiles_insert_super_admin"
  on public.profiles for insert
  with check (public.has_role('Super Admin'));

create policy "profiles_update_own"
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

create policy "profiles_update_super_admin"
  on public.profiles for update
  using (public.has_role('Super Admin'))
  with check (public.has_role('Super Admin'));

create policy "profiles_delete_super_admin"
  on public.profiles for delete
  using (public.has_role('Super Admin'));

-- ==========================================
-- locations
-- ==========================================
alter table public.locations enable row level security;

create policy "locations_select_auth"
  on public.locations for select
  using (auth.role() = 'authenticated');

create policy "locations_insert_admin"
  on public.locations for insert
  with check (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "locations_update_admin"
  on public.locations for update
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "locations_delete_admin"
  on public.locations for delete
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

-- ==========================================
-- categories
-- ==========================================
alter table public.categories enable row level security;

create policy "categories_select_auth"
  on public.categories for select
  using (auth.role() = 'authenticated');

create policy "categories_insert_admin"
  on public.categories for insert
  with check (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "categories_update_admin"
  on public.categories for update
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "categories_delete_admin"
  on public.categories for delete
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

-- ==========================================
-- incidents
-- ==========================================
alter table public.incidents enable row level security;

create policy "incidents_select_all"
  on public.incidents for select
  using (auth.role() = 'authenticated');

create policy "incidents_insert_all"
  on public.incidents for insert
  with check (auth.role() = 'authenticated');

create policy "incidents_update_admin"
  on public.incidents for update
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "incidents_update_staff_assigned"
  on public.incidents for update
  using (assigned_to = auth.uid());

-- ==========================================
-- reports
-- ==========================================
alter table public.reports enable row level security;

create policy "reports_select_own"
  on public.reports for select
  using (user_id = auth.uid());

create policy "reports_select_admin"
  on public.reports for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "reports_select_staff"
  on public.reports for select
  using (exists (
    select 1 from public.incidents
    where id = reports.incident_id and assigned_to = auth.uid()
  ));

create policy "reports_insert_all"
  on public.reports for insert
  with check (auth.role() = 'authenticated');

-- ==========================================
-- report_attachments
-- ==========================================
alter table public.report_attachments enable row level security;

create policy "attachments_select_mixed"
  on public.report_attachments for select
  using (exists (
    select 1 from public.reports
    where reports.id = report_attachments.report_id
    and (
      reports.user_id = auth.uid()
      or public.has_any_role(array['Facility Admin', 'Super Admin'])
      or exists (
        select 1 from public.incidents
        where incidents.id = reports.incident_id and incidents.assigned_to = auth.uid()
      )
    )
  ));

create policy "attachments_insert_auth"
  on public.report_attachments for insert
  with check (auth.role() = 'authenticated');

-- ==========================================
-- confirmations
-- ==========================================
alter table public.confirmations enable row level security;

create policy "confirmations_select_own"
  on public.confirmations for select
  using (user_id = auth.uid());

create policy "confirmations_select_admin"
  on public.confirmations for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "confirmations_insert_auth"
  on public.confirmations for insert
  with check (auth.role() = 'authenticated');

-- ==========================================
-- assignments
-- ==========================================
alter table public.assignments enable row level security;

create policy "assignments_select_own_staff"
  on public.assignments for select
  using (staff_id = auth.uid());

create policy "assignments_select_admin"
  on public.assignments for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "assignments_insert_admin"
  on public.assignments for insert
  with check (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "assignments_update_admin"
  on public.assignments for update
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "assignments_update_staff"
  on public.assignments for update
  using (staff_id = auth.uid());

-- ==========================================
-- status_history
-- ==========================================
alter table public.status_history enable row level security;

create policy "status_history_select_auth"
  on public.status_history for select
  using (auth.role() = 'authenticated');

-- ==========================================
-- maintenance_notes
-- ==========================================
alter table public.maintenance_notes enable row level security;

create policy "notes_select_own"
  on public.maintenance_notes for select
  using (author_id = auth.uid());

create policy "notes_select_admin"
  on public.maintenance_notes for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "notes_select_staff_assigned"
  on public.maintenance_notes for select
  using (exists (
    select 1 from public.incidents
    where id = maintenance_notes.incident_id and assigned_to = auth.uid()
  ));

create policy "notes_insert_assigned"
  on public.maintenance_notes for insert
  with check (
    public.has_any_role(array['Facility Admin', 'Super Admin'])
    or exists (
      select 1 from public.incidents
      where id = maintenance_notes.incident_id and assigned_to = auth.uid()
    )
  );

-- ==========================================
-- notifications
-- ==========================================
alter table public.notifications enable row level security;

create policy "notifications_select_own"
  on public.notifications for select
  using (user_id = auth.uid());

create policy "notifications_update_own"
  on public.notifications for update
  using (user_id = auth.uid());

-- ==========================================
-- reopen_requests
-- ==========================================
alter table public.reopen_requests enable row level security;

create policy "reopen_select_own"
  on public.reopen_requests for select
  using (requester_id = auth.uid());

create policy "reopen_select_admin"
  on public.reopen_requests for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "reopen_insert_auth"
  on public.reopen_requests for insert
  with check (auth.role() = 'authenticated');

create policy "reopen_update_admin"
  on public.reopen_requests for update
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

-- ==========================================
-- audit_logs
-- ==========================================
alter table public.audit_logs enable row level security;

create policy "audit_logs_select_admin"
  on public.audit_logs for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));
