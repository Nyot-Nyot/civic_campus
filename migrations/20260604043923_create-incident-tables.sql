-- Migration: create-incident-tables
-- Tables: incidents, reports, report_attachments, confirmations

-- 2.4 incidents
create table if not exists public.incidents (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  location_id uuid not null references public.locations(id),
  category_id uuid not null references public.categories(id),
  status text not null default 'Open' check (status in ('Open', 'Assigned', 'In Progress', 'Resolved', 'Closed')),
  priority_score integer not null default 0,
  priority_label text not null default 'Low' check (priority_label in ('Low', 'Medium', 'High', 'Critical')),
  assigned_to uuid references public.profiles(id),
  reporter_id uuid not null references public.profiles(id),
  is_rejected boolean not null default false,
  reopen_requested boolean not null default false,
  waiting_parts boolean not null default false,
  needs_review boolean not null default false,
  is_overdue boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_incidents_status on public.incidents(status);
create index if not exists idx_incidents_location_id on public.incidents(location_id);
create index if not exists idx_incidents_category_id on public.incidents(category_id);
create index if not exists idx_incidents_assigned_to on public.incidents(assigned_to);
create index if not exists idx_incidents_updated_at on public.incidents(updated_at);
create index if not exists idx_incidents_priority on public.incidents(priority_label);
create index if not exists idx_incidents_reporter_id on public.incidents(reporter_id);
create index if not exists idx_incidents_overdue on public.incidents(is_overdue) where is_overdue = true;

-- 2.5 reports
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  location_id uuid not null references public.locations(id),
  location_details text,
  category_id uuid not null references public.categories(id),
  description text,
  incident_id uuid references public.incidents(id),
  created_at timestamptz not null default now()
);

create index if not exists idx_reports_user_id on public.reports(user_id);
create index if not exists idx_reports_incident_id on public.reports(incident_id);
create index if not exists idx_reports_created_at on public.reports(created_at);

-- 2.6 report_attachments
create table if not exists public.report_attachments (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  storage_key text not null,
  storage_url text not null,
  mime_type text not null default 'image/jpeg',
  file_size integer,
  created_at timestamptz not null default now()
);

create index if not exists idx_report_attachments_report_id on public.report_attachments(report_id);

-- 2.7 confirmations
create table if not exists public.confirmations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  incident_id uuid not null references public.incidents(id),
  comment text,
  photo_storage_key text,
  created_at timestamptz not null default now(),
  unique(user_id, incident_id)
);

create index if not exists idx_confirmations_incident_id on public.confirmations(incident_id);
