-- Migration: create-core-tables
-- Tables: profiles, locations, categories

-- 2.1 profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  role text not null check (role in ('Student', 'Maintenance Staff', 'Facility Admin', 'Super Admin')),
  is_active boolean not null default true,
  phone text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2.2 locations (hierarki self-referencing: Building -> Floor -> Area)
create table if not exists public.locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('Building', 'Floor', 'Area')),
  parent_id uuid references public.locations(id) on delete cascade,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_locations_parent_id on public.locations(parent_id);
create index if not exists idx_locations_type on public.locations(type);

-- 2.3 categories
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  icon_name text,
  color_hex text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
