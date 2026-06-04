-- Migration: create-workflow-tables
-- Tables: assignments, status_history, maintenance_notes

-- 2.8 assignments
create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents(id),
  staff_id uuid not null references public.profiles(id),
  assigned_by uuid not null references public.profiles(id),
  assigned_at timestamptz not null default now(),
  due_date timestamptz,
  status text not null default 'Active' check (status in ('Active', 'Completed', 'Cancelled')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_assignments_staff_id on public.assignments(staff_id);
create index if not exists idx_assignments_incident_id on public.assignments(incident_id);
create unique index if not exists idx_assignments_active on public.assignments(incident_id) where status = 'Active';

-- 2.9 status_history
create table if not exists public.status_history (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents(id),
  from_status text,
  to_status text not null,
  actor_id uuid not null references public.profiles(id),
  reason text,
  created_at timestamptz not null default now()
);

create index if not exists idx_status_history_incident_id on public.status_history(incident_id);

-- 2.10 maintenance_notes
create table if not exists public.maintenance_notes (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents(id),
  author_id uuid not null references public.profiles(id),
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_maintenance_notes_incident_id on public.maintenance_notes(incident_id);
