-- Fix RLS on incidents: students see own, staff see assigned, admins see all
drop policy if exists "incidents_select_all" on public.incidents;

create policy "incidents_select_own"
  on public.incidents for select
  using (reporter_id = auth.uid());

create policy "incidents_select_staff_assigned"
  on public.incidents for select
  using (assigned_to = auth.uid());

create policy "incidents_select_admin"
  on public.incidents for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

-- staff assigned can also update (already exists: incidents_update_staff_assigned)
-- but also need insert policy for students (already exists: incidents_insert_all)
-- Also allow anyone to insert their own report:
drop policy if exists "incidents_insert_all" on public.incidents;
create policy "incidents_insert_own"
  on public.incidents for insert
  with check (reporter_id = auth.uid());
