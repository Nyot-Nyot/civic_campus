-- Migration: seed-data
-- Seed reference data: categories, locations, demo users, sample incidents

-- ==========================================
-- 4.2 Categories (idempotent)
-- ==========================================
insert into public.categories (name, icon_name, color_hex) values
  ('AC', 'ac_unit', '#3B82F6'),
  ('Lampu', 'lightbulb', '#FBBF24'),
  ('Listrik', 'bolt', '#F97316'),
  ('Proyektor', 'videocam', '#8B5CF6'),
  ('Pipa Air', 'water_drop', '#06B6D4'),
  ('Toilet', 'wc', '#10B981'),
  ('Furnitur', 'chair', '#EC4899'),
  ('WiFi', 'wifi', '#6366F1'),
  ('Kebersihan', 'cleaning_services', '#14B8A6'),
  ('Struktur', 'construction', '#EF4444')
on conflict (name) do nothing;

-- ==========================================
-- 4.1 Locations (idempotent)
-- ==========================================
do $$
declare
  v_gedung_a uuid; v_gedung_b uuid;
  v_gedung_c uuid; v_gedung_d uuid; v_gedung_e uuid; v_gedung_f uuid; v_gedung_g uuid;
  v_serbaguna uuid; v_asmara uuid; v_asmari uuid; v_luar uuid; v_perpus uuid;
begin
  if exists (select 1 from public.locations where name = 'Gedung A' and type = 'Building') then
    return;
  end if;

  insert into public.locations (name, type) values ('Gedung A', 'Building') returning id into v_gedung_a;
  insert into public.locations (name, type) values ('Gedung B', 'Building') returning id into v_gedung_b;
  insert into public.locations (name, type) values ('Gedung C', 'Building') returning id into v_gedung_c;
  insert into public.locations (name, type) values ('Gedung D', 'Building') returning id into v_gedung_d;
  insert into public.locations (name, type) values ('Gedung E', 'Building') returning id into v_gedung_e;
  insert into public.locations (name, type) values ('Gedung F', 'Building') returning id into v_gedung_f;
  insert into public.locations (name, type) values ('Gedung G', 'Building') returning id into v_gedung_g;
  insert into public.locations (name, type) values ('Gedung Serbaguna', 'Building') returning id into v_serbaguna;
  insert into public.locations (name, type) values ('Asrama Putra', 'Building') returning id into v_asmara;
  insert into public.locations (name, type) values ('Asrama Putri', 'Building') returning id into v_asmari;
  insert into public.locations (name, type) values ('Lokasi Luar Gedung', 'Building') returning id into v_luar;
  insert into public.locations (name, type) values ('Perpustakaan', 'Building') returning id into v_perpus;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Lantai 1', 'Floor', v_gedung_a), ('Lantai 2', 'Floor', v_gedung_a), ('Lantai 3', 'Floor', v_gedung_a)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Lantai 1','A101'),('Lantai 1','A102'),('Lantai 1','A103'),('Lantai 1','Koridor'),('Lantai 1','Lobi'),('Lantai 1','Toilet'),
    ('Lantai 2','A201'),('Lantai 2','A202'),('Lantai 2','A203'),('Lantai 2','A204'),('Lantai 2','Koridor'),('Lantai 2','Toilet'),
    ('Lantai 3','A301'),('Lantai 3','A302'),('Lantai 3','A303'),('Lantai 3','Koridor'),('Lantai 3','Toilet')
  ) as a(floor_name,area_name) on a.floor_name = f.name;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Lantai 1', 'Floor', v_gedung_b), ('Lantai 2', 'Floor', v_gedung_b)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Lantai 1','B101'),('Lantai 1','B102'),('Lantai 1','B103'),('Lantai 1','Lab Komputer'),('Lantai 1','Koridor'),('Lantai 1','Toilet'),
    ('Lantai 2','B201'),('Lantai 2','B202'),('Lantai 2','B203'),('Lantai 2','B204'),('Lantai 2','Koridor'),('Lantai 2','Toilet')
  ) as a(floor_name,area_name) on a.floor_name = f.name;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Lantai 1', 'Floor', v_gedung_f), ('Lantai 2', 'Floor', v_gedung_f), ('Lantai 3', 'Floor', v_gedung_f)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Lantai 1','F101'),('Lantai 1','F102'),('Lantai 1','F103'),('Lantai 1','F104'),('Lantai 1','Koridor'),('Lantai 1','Lobi'),('Lantai 1','Toilet'),
    ('Lantai 2','F201'),('Lantai 2','F202'),('Lantai 2','F203'),('Lantai 2','Lab Bahasa'),('Lantai 2','Koridor'),('Lantai 2','Toilet'),
    ('Lantai 3','F301'),('Lantai 3','F302'),('Lantai 3','F303'),('Lantai 3','Aula'),('Lantai 3','Koridor'),('Lantai 3','Toilet')
  ) as a(floor_name,area_name) on a.floor_name = f.name;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Lantai 1', 'Floor', v_perpus), ('Lantai 2', 'Floor', v_perpus)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Lantai 1','Ruang Baca'),('Lantai 1','Lobi'),('Lantai 1','Toilet'),('Lantai 1','Area Buku'),
    ('Lantai 2','Ruang Diskusi'),('Lantai 2','Ruang Digital'),('Lantai 2','Toilet')
  ) as a(floor_name,area_name) on a.floor_name = f.name;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Lantai 1', 'Floor', v_serbaguna), ('Lantai 2', 'Floor', v_serbaguna)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Lantai 1','Aula'),('Lantai 1','Kantin'),('Lantai 1','Koridor'),('Lantai 1','Toilet'),('Lantai 1','Mushola'),
    ('Lantai 2','Ruang Rapat'),('Lantai 2','Ruang Organisasi'),('Lantai 2','Koridor'),('Lantai 2','Toilet')
  ) as a(floor_name,area_name) on a.floor_name = f.name;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Lantai 1', 'Floor', v_asmara), ('Lantai 2', 'Floor', v_asmara)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Lantai 1','Kamar 101-110'),('Lantai 1','Ruang Tamu'),('Lantai 1','Toilet'),('Lantai 1','Dapur Umum'),
    ('Lantai 2','Kamar 201-210'),('Lantai 2','Ruang Belajar'),('Lantai 2','Toilet'),('Lantai 2','Dapur Umum')
  ) as a(floor_name,area_name) on a.floor_name = f.name;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Lantai 1', 'Floor', v_asmari), ('Lantai 2', 'Floor', v_asmari)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Lantai 1','Kamar 101-110'),('Lantai 1','Ruang Tamu'),('Lantai 1','Toilet'),('Lantai 1','Dapur Umum'),
    ('Lantai 2','Kamar 201-210'),('Lantai 2','Ruang Belajar'),('Lantai 2','Toilet'),('Lantai 2','Dapur Umum')
  ) as a(floor_name,area_name) on a.floor_name = f.name;

  with f as (
    insert into public.locations (name, type, parent_id) values
      ('Area Terbuka', 'Floor', v_luar), ('Fasilitas Umum', 'Floor', v_luar)
    returning id, name
  )
  insert into public.locations (name, type, parent_id)
  select a.area_name, 'Area', f.id from f
  join (values
    ('Area Terbuka','Taman Kampus'),('Area Terbuka','Lapangan'),('Area Terbuka','Parkiran Motor'),
    ('Area Terbuka','Parkiran Mobil'),('Area Terbuka','Gazebo'),('Area Terbuka','Halte'),('Area Terbuka','Jembatan Penghubung'),
    ('Fasilitas Umum','Kantin Utama'),('Fasilitas Umum','Koperasi'),('Fasilitas Umum','Pos Satpam'),
    ('Fasilitas Umum','Tempat Duduk Luar'),('Fasilitas Umum','Papan Informasi')
  ) as a(floor_name,area_name) on a.floor_name = f.name;
end;
$$;

-- ==========================================
-- 4.3 Demo Users (auth + profiles, idempotent)
-- ==========================================
do $$
declare
  v_id uuid;
begin
  if not exists (select 1 from auth.users where email = 'andi.mahasiswa@campus.id') then
    insert into auth.users (email, password, email_verified, profile, metadata)
    values ('andi.mahasiswa@campus.id', crypt('password123', gen_salt('bf')), true, '{}'::jsonb, '{}'::jsonb)
    returning id into v_id;
    insert into public.profiles (id, name, role) values (v_id, 'Andi Mahasiswa', 'Student');
  end if;

  if not exists (select 1 from auth.users where email = 'budi.teknisi@campus.id') then
    insert into auth.users (email, password, email_verified, profile, metadata)
    values ('budi.teknisi@campus.id', crypt('password123', gen_salt('bf')), true, '{}'::jsonb, '{}'::jsonb)
    returning id into v_id;
    insert into public.profiles (id, name, role) values (v_id, 'Budi Teknisi', 'Maintenance Staff');
  end if;

  if not exists (select 1 from auth.users where email = 'dewi.admin@campus.id') then
    insert into auth.users (email, password, email_verified, profile, metadata)
    values ('dewi.admin@campus.id', crypt('password123', gen_salt('bf')), true, '{}'::jsonb, '{}'::jsonb)
    returning id into v_id;
    insert into public.profiles (id, name, role) values (v_id, 'Dewi Admin', 'Facility Admin');
  end if;

  if not exists (select 1 from auth.users where email = 'super.admin@campus.id') then
    insert into auth.users (email, password, email_verified, profile, metadata)
    values ('super.admin@campus.id', crypt('password123', gen_salt('bf')), true, '{}'::jsonb, '{}'::jsonb)
    returning id into v_id;
    insert into public.profiles (id, name, role) values (v_id, 'Admin Utama', 'Super Admin');
  end if;
end;
$$;

-- ==========================================
-- 4.4 Sample Incidents + Reports (idempotent)
-- ==========================================
do $$
declare
  v_student_id uuid; v_staff_id uuid;
  v_ac uuid; v_lampu uuid; v_proyektor uuid; v_toilet uuid;
  v_furnitur uuid; v_wifi uuid; v_pipa uuid; v_kebersihan uuid;
begin
  if exists (select 1 from public.incidents where title = 'AC ruang kuliah tidak dingin') then
    return;
  end if;

  select id into v_student_id from public.profiles where role = 'Student' limit 1;
  select id into v_staff_id from public.profiles where role = 'Maintenance Staff' limit 1;
  select id into v_ac from public.categories where name = 'AC';
  select id into v_lampu from public.categories where name = 'Lampu';
  select id into v_proyektor from public.categories where name = 'Proyektor';
  select id into v_toilet from public.categories where name = 'Toilet';
  select id into v_furnitur from public.categories where name = 'Furnitur';
  select id into v_wifi from public.categories where name = 'WiFi';
  select id into v_pipa from public.categories where name = 'Pipa Air';
  select id into v_kebersihan from public.categories where name = 'Kebersihan';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'AC ruang kuliah tidak dingin', a.id, v_ac, 'In Progress', 'High', v_staff_id, v_student_id, 65, '2026-06-02 06:00+07', '2026-06-02 10:00+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='F101' and b.name='Gedung F';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'Lampu koridor mati', a.id, v_lampu, 'Open', 'Medium', null, v_student_id, 30, '2026-06-01 10:00+07', '2026-06-01 10:00+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='Koridor' and f.name='Lantai 2' and b.name='Gedung A';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'Proyektor tidak menyala', a.id, v_proyektor, 'Assigned', 'Medium', v_staff_id, v_student_id, 35, '2026-05-31 10:00+07', '2026-06-01 08:00+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='Lab Komputer' and b.name='Gedung B';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'Toilet mampet', a.id, v_toilet, 'Resolved', 'Low', v_staff_id, v_student_id, 15, '2026-05-30 10:00+07', '2026-06-02 09:00+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='Toilet' and f.name='Lantai 2' and b.name='Gedung F';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'Meja kursi rusak', a.id, v_furnitur, 'Closed', 'Low', null, v_student_id, 10, '2026-05-26 10:00+07', '2026-05-28 10:00+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='Kamar 201-210' and b.name='Asrama Putra';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'WiFi lambat', a.id, v_wifi, 'Open', 'High', null, v_student_id, 60, '2026-06-02 09:30+07', '2026-06-02 09:30+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='Ruang Baca' and b.name='Perpustakaan';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'Pipa air bocor', a.id, v_pipa, 'In Progress', 'High', v_staff_id, v_student_id, 70, '2026-06-02 04:00+07', '2026-06-02 10:00+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='Toilet' and f.name='Lantai 1' and b.name='Gedung A';

  insert into public.incidents (title, location_id, category_id, status, priority_label, assigned_to, reporter_id, priority_score, created_at, updated_at)
  select 'Kebersihan area baca', a.id, v_kebersihan, 'Closed', 'Low', null, v_student_id, 10, '2026-05-19 10:00+07', '2026-05-21 10:00+07'
  from public.locations a join public.locations f on a.parent_id=f.id join public.locations b on f.parent_id=b.id
  where a.name='Area Buku' and b.name='Perpustakaan';
end;
$$;

-- Reports for each incident
do $$
declare
  v_student_id uuid;
  v_inc record;
begin
  select id into v_student_id from public.profiles where role = 'Student' limit 1;

  for v_inc in select id, location_id, category_id, title, reporter_id from public.incidents loop
    if not exists (select 1 from public.reports where incident_id = v_inc.id) then
      insert into public.reports (user_id, location_id, category_id, description, incident_id)
      values (v_inc.reporter_id, v_inc.location_id, v_inc.category_id, v_inc.title, v_inc.id);
    end if;
  end loop;
end;
$$;
