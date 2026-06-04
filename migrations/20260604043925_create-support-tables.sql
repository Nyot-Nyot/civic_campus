-- Migration: create-support-tables
-- Tables: notifications, reopen_requests, audit_logs

-- 2.11 notifications
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  type text not null check (type in (
    'incident_created', 'incident_assigned', 'status_changed',
    'incident_resolved', 'incident_closed', 'reopen_requested',
    'reopen_accepted', 'reopen_rejected'
  )),
  title text not null,
  body text not null,
  entity_type text not null,
  entity_id uuid not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user_id on public.notifications(user_id);
create index if not exists idx_notifications_unread on public.notifications(user_id) where read_at is null;
create index if not exists idx_notifications_created_at on public.notifications(created_at);

-- 2.12 reopen_requests
create table if not exists public.reopen_requests (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents(id),
  requester_id uuid not null references public.profiles(id),
  reason text not null,
  photo_storage_key text,
  status text not null default 'Pending' check (status in ('Pending', 'Accepted', 'Rejected')),
  reviewed_by uuid references public.profiles(id),
  review_reason text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create index if not exists idx_reopen_requests_incident_id on public.reopen_requests(incident_id);
create index if not exists idx_reopen_requests_requester_id on public.reopen_requests(requester_id);

-- 2.13 audit_logs
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  previous_value jsonb,
  new_value jsonb,
  metadata jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_audit_logs_entity_id on public.audit_logs(entity_id);
create index if not exists idx_audit_logs_created_at on public.audit_logs(created_at);
create index if not exists idx_audit_logs_action on public.audit_logs(action);
