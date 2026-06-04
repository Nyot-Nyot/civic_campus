# Implementation Plan: CIVIC Campus Backend dengan InsForge

## Ringkasan

**Status saat ini:** Flutter UI prototype dengan dummy data in-memory — belum ada integrasi backend, auth, atau storage.

**Target:** Backend lengkap di InsForge (PostgreSQL + Auth + Storage + Edge Functions) dengan Flutter app sebagai client yang terkoneksi via REST API.

---

## Task 1: Infrastructure & Project Setup

| Sub-task | Detail |
|---|---|
| 1.1 | Setup Flutter dependencies: `http`/`dio`, `image_picker`, `provider`/`riverpod`, `flutter_secure_storage` |
| 1.2 | Buat `.env.local` dari InsForge project credentials |
| 1.3 | Export config via `npx @insforge/cli config export` ke `insforge.toml` |
| 1.4 | Buat base Flutter API client service (handle auth token, base URL, error handling) |
| 1.5 | Setup storage bucket `incident-photos` via CLI |

---

## Task 2: Database Schema — SQL Migrations

### 2.1 Migration: `create_profiles.sql`

Table `profiles` — extends `auth.users` dengan data profil:

```sql
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  role text not null check (role in ('Student', 'Maintenance Staff', 'Facility Admin', 'Super Admin')),
  is_active boolean not null default true,
  phone text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### 2.2 Migration: `create_locations.sql`

Table `locations` — hierarki Building -> Floor -> Room/Area (self-referencing via `parent_id`):

```sql
create table public.locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('Building', 'Floor', 'Area')),
  parent_id uuid references public.locations(id) on delete cascade,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_locations_parent_id on public.locations(parent_id);
create index idx_locations_type on public.locations(type);
```

### 2.3 Migration: `create_categories.sql`

Table `categories` — jenis masalah fasilitas:

```sql
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  icon_name text,
  color_hex text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### 2.4 Migration: `create_incidents.sql`

Table `incidents` — core entity, satu masalah operasional nyata:

```sql
create table public.incidents (
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

create index idx_incidents_status on public.incidents(status);
create index idx_incidents_location_id on public.incidents(location_id);
create index idx_incidents_category_id on public.incidents(category_id);
create index idx_incidents_assigned_to on public.incidents(assigned_to);
create index idx_incidents_updated_at on public.incidents(updated_at);
create index idx_incidents_priority on public.incidents(priority_label);
```

### 2.5 Migration: `create_reports.sql`

Table `reports` — observasi dari user, bersifat historis/append-only:

```sql
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  location_id uuid not null references public.locations(id),
  location_details text,
  category_id uuid not null references public.categories(id),
  description text,
  incident_id uuid references public.incidents(id),
  created_at timestamptz not null default now()
);

create index idx_reports_user_id on public.reports(user_id);
create index idx_reports_incident_id on public.reports(incident_id);
create index idx_reports_created_at on public.reports(created_at);
```

### 2.6 Migration: `create_report_attachments.sql`

Table `report_attachments` — photo evidence:

```sql
create table public.report_attachments (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  storage_key text not null,
  storage_url text not null,
  mime_type text not null default 'image/jpeg',
  file_size integer,
  created_at timestamptz not null default now()
);

create index idx_report_attachments_report_id on public.report_attachments(report_id);
```

### 2.7 Migration: `create_confirmations.sql`

Table `confirmations` — user menandai mengalami masalah yang sama:

```sql
create table public.confirmations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  incident_id uuid not null references public.incidents(id),
  comment text,
  photo_storage_key text,
  created_at timestamptz not null default now(),
  unique(user_id, incident_id)
);

create index idx_confirmations_incident_id on public.confirmations(incident_id);
```

### 2.8 Migration: `create_assignments.sql`

Table `assignments` — staff ditugaskan ke incident:

```sql
create table public.assignments (
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

create index idx_assignments_staff_id on public.assignments(staff_id);
create index idx_assignments_incident_id on public.assignments(incident_id);
create unique index idx_assignments_active on public.assignments(incident_id) where status = 'Active';
```

### 2.9 Migration: `create_status_history.sql`

Table `status_history` — timeline perubahan status:

```sql
create table public.status_history (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents(id),
  from_status text,
  to_status text not null,
  actor_id uuid not null references public.profiles(id),
  reason text,
  created_at timestamptz not null default now()
);

create index idx_status_history_incident_id on public.status_history(incident_id);
```

### 2.10 Migration: `create_maintenance_notes.sql`

Table `maintenance_notes` — catatan staff/admin:

```sql
create table public.maintenance_notes (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents(id),
  author_id uuid not null references public.profiles(id),
  content text not null,
  created_at timestamptz not null default now()
);

create index idx_maintenance_notes_incident_id on public.maintenance_notes(incident_id);
```

### 2.11 Migration: `create_notifications.sql`

Table `notifications` — in-app notification:

```sql
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  type text not null check (type in ('incident_created', 'incident_assigned', 'status_changed', 'incident_resolved', 'incident_closed', 'reopen_requested', 'reopen_accepted', 'reopen_rejected')),
  title text not null,
  body text not null,
  entity_type text not null,
  entity_id uuid not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_notifications_user_id on public.notifications(user_id);
create index idx_notifications_read_at on public.notifications(read_at);
create index idx_notifications_created_at on public.notifications(created_at);
```

### 2.12 Migration: `create_reopen_requests.sql`

Table `reopen_requests` — request untuk reopen incident:

```sql
create table public.reopen_requests (
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

create index idx_reopen_requests_incident_id on public.reopen_requests(incident_id);
create index idx_reopen_requests_requester_id on public.reopen_requests(requester_id);
```

### 2.13 Migration: `create_audit_logs.sql`

Table `audit_logs` — append-only audit trail:

```sql
create table public.audit_logs (
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

create index idx_audit_logs_entity_id on public.audit_logs(entity_id);
create index idx_audit_logs_created_at on public.audit_logs(created_at);
create index idx_audit_logs_action on public.audit_logs(action);
```

---

## Task 3: Database Functions, Triggers & RLS

### 3.1 Function: `submit_report_secure()`

Atomic transaction untuk submit report:

```sql
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

  -- Create report
  insert into public.reports (user_id, location_id, location_details, category_id, description)
  values (v_user_id, p_location_id, p_location_details, p_category_id, p_description)
  returning id into v_report_id;

  -- If user selected existing incident
  if p_existing_incident_id is not null then
    -- Verify incident exists and is active
    if not exists (select 1 from public.incidents where id = p_existing_incident_id and status not in ('Closed', 'Resolved')) then
      raise exception 'Incident not available for confirmation';
    end if;

    -- Link report to existing incident
    update public.reports set incident_id = p_existing_incident_id where id = v_report_id;

    -- Create confirmation
    insert into public.confirmations (user_id, incident_id)
    values (v_user_id, p_existing_incident_id)
    on conflict (user_id, incident_id) do nothing;

    v_incident_id := p_existing_incident_id;

    -- Update priority score
    update public.incidents
    set priority_score = priority_score + 5,
        updated_at = now()
    where id = v_incident_id;
  else
    -- Create new incident
    insert into public.incidents (title, location_id, category_id, reporter_id, priority_score)
    values (
      coalesce(p_description, 'Laporan ' || (select name from public.categories where id = p_category_id)),
      p_location_id,
      p_category_id,
      v_user_id,
      10
    )
    returning id into v_incident_id;

    -- Link report to new incident
    update public.reports set incident_id = v_incident_id where id = v_report_id;
  end if;

  -- Create audit log
  insert into public.audit_logs (actor_id, action, entity_type, entity_id, metadata)
  values (v_user_id, 'report_created', 'report', v_report_id,
    jsonb_build_object('incident_id', v_incident_id, 'category_id', p_category_id));

  return jsonb_build_object(
    'report_id', v_report_id,
    'incident_id', v_incident_id
  );
end;
$$;
```

### 3.2 Function: `dedup_score_candidates()`

Rule-based deduplication scoring:

```sql
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
```

### 3.3 Function: `get_dashboard_stats()`

Aggregate analytics untuk admin dashboard:

```sql
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
```

### 3.4 Function: `get_staff_workload()`

Menghitung beban kerja aktif per staff:

```sql
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
```

### 3.5 Trigger: `on_status_change` -> `status_history`

```sql
create or replace function public.log_status_change()
returns trigger
language plpgsql
security definer
as $$
begin
  if old.status is distinct from new.status then
    insert into public.status_history (incident_id, from_status, to_status, actor_id)
    values (new.id, old.status, new.status, auth.uid());

    -- Auto-set is_overdue false when resolved/closed
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
```

### 3.6 Trigger: `on_incident_event` -> `notifications`

```sql
create or replace function public.create_incident_notification()
returns trigger
language plpgsql
security definer
as $$
begin
  -- Notify on assignment
  if new.assigned_to is distinct from old.assigned_to and new.assigned_to is not null then
    insert into public.notifications (user_id, type, title, body, entity_type, entity_id)
    values (new.assigned_to, 'incident_assigned', 'Tugas Baru',
      'Anda ditugaskan untuk: ' || new.title, 'incident', new.id);
  end if;

  -- Notify reporter on status change
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
```

### 3.7 Trigger: `on_important_action` -> `audit_logs`

```sql
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
```

### 3.8 RLS Policies

#### Profiles

```sql
-- Profiles: users can read own; admin/super admin can read all
alter table public.profiles enable row level security;

create policy "Users can read own profile"
  on public.profiles for select
  using (id = auth.uid());

create policy "Admin can read all profiles"
  on public.profiles for select
  using (exists (
    select 1 from public.profiles where id = auth.uid()
    and role in ('Facility Admin', 'Super Admin')
  ));

create policy "Super admin can manage profiles"
  on public.profiles for all
  using (exists (
    select 1 from public.profiles where id = auth.uid()
    and role = 'Super Admin'
  ));
```

#### Incidents

```sql
alter table public.incidents enable row level security;

create policy "Anyone can read incidents"
  on public.incidents for select
  using (true);

create policy "Staff can view assigned incidents"
  on public.incidents for select
  using (assigned_to = auth.uid()
     or exists (select 1 from public.profiles where id = auth.uid() and role in ('Facility Admin', 'Super Admin'))
  );

create policy "Admin can update incidents"
  on public.incidents for update
  using (exists (
    select 1 from public.profiles where id = auth.uid()
    and role in ('Facility Admin', 'Super Admin')
  ));

create policy "Staff can update own assigned incidents"
  on public.incidents for update
  using (assigned_to = auth.uid());
```

#### Reports, Confirmations, Assignments, Notifications, Audit Logs

RLS policies serupa mengikuti pola RBAC yang sama — user dapat insert data sendiri, admin dapat manage semua.

### 3.9 Indexes

```sql
-- Incident indexes (already included in 2.4)
-- Report indexes (already included in 2.5)
-- Notification indexes (already included in 2.11)
-- Assignment indexes (already included in 2.8)
-- Status history indexes (already included in 2.9)
-- Audit log indexes (already included in 2.13)
-- Location indexes (already included in 2.2)

-- Additional performance indexes
create index idx_incidents_is_overdue on public.incidents(is_overdue) where is_overdue = true;
create index idx_incidents_reporter_id on public.incidents(reporter_id);
create index idx_notifications_unread on public.notifications(user_id) where read_at is null;
```

---

## Task 4: Seed Data

### 4.1 Seed Locations

Insert buildings, floors, dan areas dari `dummy_data.dart`:

```sql
-- Insert buildings
with building as (
  insert into public.locations (name, type) values
    ('Gedung Rektorat', 'Building'),
    ('Gedung A', 'Building'),
    ('Gedung B', 'Building'),
    ('Gedung C', 'Building'),
    ('Gedung D', 'Building'),
    ('Gedung E', 'Building'),
    ('Gedung F', 'Building'),
    ('Gedung G', 'Building')
  returning id, name
)
-- Insert floors and areas for each building
-- (detail per building dari dummy_data)
insert into public.locations (name, type, parent_id)
select f.name, 'Floor', b.id
from building b
cross join (values ('Lantai 1'), ('Lantai 2'), ('Lantai 3')) as f(name);
```

### 4.2 Seed Categories

```sql
insert into public.categories (name, icon_name, color_hex) values
  ('AC', 'ac_unit', '#FF5252'),
  ('Lampu', 'lightbulb', '#FFC107'),
  ('Listrik', 'bolt', '#FF6D00'),
  ('Proyektor', 'videocam', '#E040FB'),
  ('Pipa Air', 'water_drop', '#448AFF'),
  ('Toilet', 'wc', '#00BCD4'),
  ('Furnitur', 'chair', '#8D6E63'),
  ('WiFi', 'wifi', '#4CAF50'),
  ('Kebersihan', 'cleaning_services', '#009688'),
  ('Struktur', 'architecture', '#607D8B');
```

### 4.3 Seed Demo Users

```sql
-- Insert profiles for each role (auth.users must exist first)
-- Use InsForge Auth API to create users, then link profiles
```

### 4.4 Seed Sample Incidents + Reports

```sql
-- Insert sample incidents matching dummy_data
insert into public.incidents (title, location_id, category_id, status, priority_label, reporter_id, assigned_to)
values
  ('AC Mati di Ruang 201', (select id from public.locations where name like '%Ruang 201%'), (select id from public.categories where name = 'AC'), 'Assigned', 'High', '...', '...'),
  ('Lampu Koridor Lantai 1', (select id from public.locations where name like '%Koridor%' and parent_id in (select id from public.locations where name = 'Lantai 1')), (select id from public.categories where name = 'Lampu'), 'Open', 'Medium', '...', null);
```

---

## Task 5: Edge Functions for Complex Logic

### 5.1 Function: `submit-report`

Deploy edge function untuk submit report dengan full logic:

- Menerima POST dengan data report + photo references
- Memanggil `submit_report_secure()` database function
- Mengembalikan report_id + incident_id
- Handle error dengan proper status codes

### 5.2 Function: `check-duplicates`

- Menerima location_id, category_id, description
- Memanggil `dedup_score_candidates()` function
- Mengembalikan sorted candidates dengan score >= 40

### 5.3 Function: `reopen-request`

- Validasi max 2 requests per user per incident
- Create reopen_request record
- Notify admin via notification
- Return status

### 5.4 Function: `dashboard-stats`

- Memanggil `get_dashboard_stats()` function
- Memanggil `get_staff_workload()` function
- Return combined data

---

## Task 6: Flutter API Integration Layer

### 6.1 `ApiClient` — Base API Client

```dart
class ApiClient {
  final String baseUrl;
  final String anonKey;
  String? _accessToken;

  // GET, POST, PATCH, DELETE with auth token injection
  // Error handling wrapper
  // Token refresh
}
```

### 6.2 `AuthService`

- `signIn(email, password)` -> POST `{oss_host}/auth/v1/token?grant_type=password`
- `signUp(email, password)` -> POST `{oss_host}/auth/v1/signup`
- `signOut()` -> POST `{oss_host}/auth/v1/logout`
- `getSession()` -> GET `{oss_host}/auth/v1/user`
- `refreshToken()` -> POST `{oss_host}/auth/v1/token?grant_type=refresh_token`

### 6.3 `IncidentApi`

- `list({status, locationId, categoryId, assignedTo, search})` -> GET `{oss_host}/rest/v1/incidents?...`
- `getById(id)` -> GET `{oss_host}/rest/v1/incidents?id=eq.{id}`
- `create(data)` -> POST `{oss_host}/rest/v1/incidents`
- `updateStatus(id, status, {notes, assignedTo})` -> PATCH `{oss_host}/rest/v1/incidents?id=eq.{id}`
- `getHistory(id)` -> GET `{oss_host}/rest/v1/status_history?incident_id=eq.{id}`
- `getNotes(id)` -> GET `{oss_host}/rest/v1/maintenance_notes?incident_id=eq.{id}`
- `addNote(id, content)` -> POST `{oss_host}/rest/v1/maintenance_notes`

### 6.4 `ReportApi`

- `submit(data)` -> POST `{oss_host}/functions/submit-report`
- `checkDuplicates(locationId, categoryId, description)` -> POST `{oss_host}/functions/check-duplicates`
- `confirm(incidentId)` -> POST `{oss_host}/rest/v1/confirmations`
- `getAttachments(reportId)` -> GET `{oss_host}/rest/v1/report_attachments?report_id=eq.{reportId}`

### 6.5 `LocationApi`

- `getBuildings()` -> GET `{oss_host}/rest/v1/locations?type=eq.Building`
- `getFloors(buildingId)` -> GET `{oss_host}/rest/v1/locations?parent_id=eq.{buildingId}&type=eq.Floor`
- `getAreas(floorId)` -> GET `{oss_host}/rest/v1/locations?parent_id=eq.{floorId}&type=eq.Area`

### 6.6 `CategoryApi`

- `list()` -> GET `{oss_host}/rest/v1/categories`
- `create(data)` -> POST `{oss_host}/rest/v1/categories`
- `update(id, data)` -> PATCH `{oss_host}/rest/v1/categories?id=eq.{id}`
- `delete(id)` -> DELETE `{oss_host}/rest/v1/categories?id=eq.{id}`

### 6.7 `UserApi`

- `list()` -> GET `{oss_host}/rest/v1/profiles`
- `getById(id)` -> GET `{oss_host}/rest/v1/profiles?id=eq.{id}`
- `create(data)` -> POST `{oss_host}/rest/v1/profiles`
- `update(id, data)` -> PATCH `{oss_host}/rest/v1/profiles?id=eq.{id}`
- `toggleActive(id)` -> PATCH `{oss_host}/rest/v1/profiles?id=eq.{id}` (patch is_active)

### 6.8 `NotificationApi`

- `list()` -> GET `{oss_host}/rest/v1/notifications?user_id=eq.{userId}&order=created_at.desc`
- `getUnreadCount()` -> GET `{oss_host}/rest/v1/notifications?user_id=eq.{userId}&read_at=is.null&select=count`
- `markRead(id)` -> PATCH `{oss_host}/rest/v1/notifications?id=eq.{id}`
- `markAllRead()` -> PATCH `{oss_host}/rest/v1/notifications?user_id=eq.{userId}` (set read_at = now())

### 6.9 `StorageService`

- `uploadPhoto(filePath, bucket)` -> POST `{oss_host}/storage/v1/object/{bucket}/{path}`
- `getPublicUrl(key, bucket)` -> `{oss_host}/storage/v1/object/public/{bucket}/{key}`
- `deletePhoto(key, bucket)` -> DELETE `{oss_host}/storage/v1/object/{bucket}/{key}`

---

## Task 7: Flutter State Management & Repository Refactoring

### 7.1 Setup Provider/Riverpod

```dart
// auth_provider.dart
final authServiceProvider = Provider<AuthService>(...);
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(...);

// incident_provider.dart
final incidentRepositoryProvider = Provider<IncidentRepository>(...);
final incidentListProvider = StateNotifierProvider<IncidentListNotifier, IncidentListState>(...);

// location_provider.dart
final locationRepositoryProvider = Provider<LocationRepository>(...);

// category_provider.dart
final categoryRepositoryProvider = Provider<CategoryRepository>(...);

// notification_provider.dart
final notificationRepositoryProvider = Provider<NotificationRepository>(...);
```

### 7.2 Refactor `IncidentRepository`

Replace in-memory operations dengan API calls via `IncidentApi`:
- `getAll()` -> `IncidentApi.list()`
- `getById(id)` -> `IncidentApi.getById(id)`
- `getActive()` -> `IncidentApi.list(status: 'in.(Open,Assigned,In Progress)')`
- `getCompleted()` -> `IncidentApi.list(status: 'in.(Resolved,Closed)')`
- `getAssignedTo(staffName)` -> `IncidentApi.list(assignedTo: 'eq.{staffId}')`
- `updateStatus(id, newStatus, {notes, assignedTo})` -> `IncidentApi.updateStatus(...)`

### 7.3 Refactor `BuildingRepository`

Replace with `LocationApi`:
- `getAll()` -> `LocationApi.getBuildings()`
- `search(query)` -> `LocationApi.getBuildings()` + client-side filter (atau ILIKE query)
- `add(building)` -> insert location records
- `update(index, building)` -> update location records
- `delete(index)` -> soft-delete location

### 7.4 Refactor `CategoryRepository`

Replace with `CategoryApi`:
- `getAll()` -> `CategoryApi.list()`
- `add(category)` -> `CategoryApi.create(category)`
- `update(index, category)` -> `CategoryApi.update(id, category)`
- `delete(index)` -> `CategoryApi.delete(id)`

### 7.5 Refactor `UserRepository`

Replace with `UserApi` + `AuthService`:
- `getCurrentUser()` -> `AuthService.getSession()` + `UserApi.getById(userId)`
- `getAllUsers()` -> `UserApi.list()`
- `addUser(user)` -> `AuthService.signUp()` + `UserApi.create(profile)`
- `updateUser(email, updated)` -> `UserApi.update(id, updated)`
- `deleteUser(email)` -> soft-delete (deactivate)
- `toggleUserActive(email)` -> `UserApi.toggleActive(id)`

### 7.6 Refactor `NotificationRepository`

Replace with `NotificationApi`:
- `getAll()` -> `NotificationApi.list()`
- `getUnreadCount()` -> `NotificationApi.getUnreadCount()`
- `markAllRead()` -> `NotificationApi.markAllRead()`

---

## Task 8: Update Flutter Screens for Real Backend

### 8.1 `LoginScreen`

- Ganti simulated login dengan `AuthService.signIn()`
- Tampilkan loading state selama sign in
- Handle error: invalid credentials, network error
- Redirect ke home screen sesuai role setelah berhasil login
- Simpan refresh token di flutter_secure_storage

### 8.2 `SplashScreen`

- Cek session yang tersimpan via `AuthService.getSession()`
- Jika valid, redirect ke role-based home
- Jika tidak valid, redirect ke login

### 8.3 `NewReportScreen`

- Location step: load real buildings/floors/areas dari `LocationApi`
- Category step: load real categories dari `CategoryApi`
- Photo step: implement real image picker + compression (< 500KB) + upload ke InsForge Storage
- Review step: call `ReportApi.checkDuplicates()` untuk dedup
- Submit: call `ReportApi.submit()` via edge function

### 8.4 `IncidentDetailScreen`

- Load data dari `IncidentApi.getById(id)`
- Load status history dari `IncidentApi.getHistory(id)`
- Load notes dari `IncidentApi.getNotes(id)`
- Status update: call `IncidentApi.updateStatus()` dengan validasi role
- Assign staff (admin): call `IncidentApi.updateStatus()` dengan assignedTo

### 8.5 Admin Screens

- `OverviewTab`: real metrics dari `IncidentApi.list()` + aggregate
- `StaffWorkloadTab`: panggil fungsi `get_staff_workload()`
- `MasterDataTab`: CRUD via `LocationApi` dan `CategoryApi`
- `IncidentListTab`: search/filter via PostgREST query params

### 8.6 SuperAdmin Screens

- `DashboardTab`: aggregate stats dari `get_dashboard_stats()`
- `UsersTab`: CRUD via `UserApi`, create user via `AuthService.signUp()` + profile insert
- `SystemConfigTab`: view audit logs dari `audit_logs` table

---

## Task 9: Real-time Notifications (Optional MVP)

### 9.1 Backend Setup

```bash
npx @insforge/cli config apply --file insforge.toml
# Configure realtime channel for notifications table
```

### 9.2 Flutter Subscription

```dart
// Subscribe to notification changes for current user
// Auto-refresh notification badge via stream
```

---

## Task 10: Testing & Deployment

### 10.1 Integration Tests

```dart
// Test critical flows:
// 1. Auth: signup -> login -> get profile -> logout
// 2. Report: submit report -> verify incident created
// 3. Dedup: submit same location/category -> verify suggestion
// 4. Assignment: admin assign staff -> verify assignment
// 5. Status cycle: Open -> Assigned -> In Progress -> Resolved -> Closed
```

### 10.2 RLS Testing

Test every endpoint dengan setiap role:
- Student: can create report, cannot assign
- Staff: can update own assigned incident, cannot close
- Admin: can assign, close, manage master data
- Super Admin: full access

### 10.3 Dedup Edge Cases

- Same location + same category -> high score
- Same building + related category -> medium score
- Different building + different category -> low score
- Closed incident -> not included in candidates
- Concurrent submit -> no duplicate incidents

### 10.4 Deploy

```bash
# Set deployment env vars
npx @insforge/cli deployments env set VITE_INSFORGE_URL https://f3k6x5hq.ap-southeast.insforge.app
npx @insforge/cli deployments env set VITE_INSFORGE_ANON_KEY <anon-key>

# Build Flutter web
flutter build web

# Deploy
npx @insforge/cli deployments deploy .
```

---

## Task 11: Budget / RAB System

### 11.1 Migration: `create_budget_requests.sql`

```sql
create table public.budget_requests (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents(id) on delete cascade,
  version integer not null default 1,
  items jsonb not null default '[]'::jsonb,
  total_cost numeric not null default 0,
  notes text,
  status text not null default 'Menunggu'
    check (status in ('Menunggu', 'Disetujui', 'Ditolak')),
  admin_notes text,
  created_by uuid not null references public.profiles(id),
  reviewed_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_budget_requests_incident on public.budget_requests(incident_id);
create index idx_budget_requests_status on public.budget_requests(status);
```

### 11.2 Migration: `update_incident_status.sql`

Add `Menunggu Anggaran` to incidents status check constraint:

```sql
alter table public.incidents
  drop constraint if exists incidents_status_check;

alter table public.incidents
  add constraint incidents_status_check
  check (status in ('Open', 'Assigned', 'Menunggu Anggaran', 'In Progress', 'Resolved', 'Closed'));
```

### 11.3 RLS Policies for `budget_requests`

```sql
alter table public.budget_requests enable row level security;

create policy "budget_select_staff_own"
  on public.budget_requests for select
  using (created_by = auth.uid());

create policy "budget_select_admin"
  on public.budget_requests for select
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));

create policy "budget_insert_staff_assigned"
  on public.budget_requests for insert
  with check (
    auth.uid() = created_by
    and exists (
      select 1 from public.incidents
      where id = budget_requests.incident_id
      and assigned_to = auth.uid()
      and status = 'Assigned'
    )
  );

create policy "budget_update_admin"
  on public.budget_requests for update
  using (public.has_any_role(array['Facility Admin', 'Super Admin']));
```

### 11.4 API Layer

| File | Method | Endpoint |
|------|--------|----------|
| `BudgetApi` | `listForIncident(id)` | GET budget_requests?incident_id=eq.{id} |
| `BudgetApi` | `create(data)` | POST budget_requests |
| `BudgetApi` | `approve(id, adminNotes)` | PATCH budget_requests?id=eq.{id} → status=Disetujui |
| `BudgetApi` | `reject(id, adminNotes)` | PATCH budget_requests?id=eq.{id} → status=Ditolak |
| `BudgetApi` | `getPending()` | GET budget_requests?status=eq.Menunggu |

### 11.5 Flutter Screens

- **Staff Task Detail**: Add "Buat RAB" button (visible when status = Assigned, user is assigned staff).
- **Create Budget Request Screen**: Form with dynamic item list (description, qty, unit, unit_cost). Auto-calculate total. Show previous versions and rejection reason.
- **Admin Budget Approval Tab**: List pending RABs with total cost. Tap → detail → Approve/Reject + PDF generate.
- **Admin Incident Detail**: Show RAB status and link to approval screen.

### 11.6 PDF Generation

Generate RAB PDF document using a package like `pdf` (Dart):

- Formal document header: RENCANA ANGGARAN BIAYA
- Auto-generated document number
- Incident info: title, location, category, technician
- Item table with costs
- Total sum
- Signature fields for technician and facility admin
- Admin can download/share the PDF for campus finance submission

### 11.7 Priority Order

```
[Now] Task 11.1 – DB migration + RLS
[Now] Task 11.2 – BudgetApi + Provider
[Now] Task 11.3 – Staff: Create RAB screen
[Now] Task 11.4 – Admin: Approval screen + PDF
```

---

## Prioritas Rekomendasi Pengerjaan

```
[Urgent] Task 1 → Task 2 → Task 3 → Task 4 → Task 6 → Task 7
[Secondary] Task 5 → Task 8 → Task 10 → Task 11
[Nice to have] Task 9
```

Task 2 dan 3 dapat dikerjakan secara paralel (migration files terlebih dahulu, kemudian RLS/triggers di migration terpisah).
