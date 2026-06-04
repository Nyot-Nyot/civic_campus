# Screen Requirements by User Role

Dokumen ini merangkum analisis dari semua dokumen relevan (`architecture_facility_incident_management_system.md`, `design_facility_incident_management_system.md`, `prd_facility_incident_management_system_flutter.md`, `system_design_facility_incident_management_system.md`) untuk menentukan layar yang dibutuhkan sebelum membuat mockup dan implementasi.

## 1. Tujuan

Tujuan analisis ini:
- memahami konteks dan tujuan aplikasi dari dokumentasi yang ada,
- mengidentifikasi semua layar yang dibutuhkan untuk setiap peran pengguna,
- memastikan tidak ada fungsi penting yang terlewat sebelum mulai membuat UI mockup.

## 2. Ringkasan Peran Pengguna

Peran utama:
- Student
- Maintenance Staff
- Facility Admin
- Super Admin

Arsitektur aplikasi: satu Flutter app dengan role-based routing dan floating bottom navigation dock.

## 3. Layar Umum (Shared)

### 3.1 Login / Authentication
- Login screen dengan email/password atau metode otentikasi InsForge.
- Loading / error state untuk autentikasi.
- Persistent auth state dan role guard.

### 3.2 Profile / Account
- Profile screen menampilkan nama, peran, foto profil, dan informasi akun.
- Pengaturan dasar akun (logout, notifikasi, bahasa jika diperlukan).

### 3.3 Location & Category Selection
- Master data lokasi yang dipakai saat report.
- Master data kategori masalah.
- Layar pemilihan / browsing lokasi untuk input report.

### 3.4 Common Incident Detail
- Incident detail yang menampilkan:
  - judul insiden,
  - status dan badge warna,
  - lokasi dan kategori,
  - assigned staff,
  - linked reports dan jumlah confirm,
  - timeline status,
  - gallery foto bukti.
- Versi yang menyesuaikan hak akses role (misal Student hanya lihat, Staff dapat update status, Admin dapat assign / close).

### 3.5 Notification / In-app Alerts
- Daftar notifikasi atau banner penting untuk status update, reopen request, dan assignment.

## 4. Student Screens

Student adalah pelapor utama. Layar fokus pada pelaporan cepat, visibilitas status, dan konfirmasi duplikat.

### 4.1 Student Home Screen
- Hero greeting dengan nama user.
- Quick action `Laporkan Masalah`.
- Search / filter lokasi kategori.
- Chips kategori / area.
- Ringkasan `My Active Reports` atau `My Incidents`.
- Indikator jika ada issue serupa di dekat lokasi.

### 4.2 New Report Flow
Alur report linear yang harus mencakup:
- pilih lokasi (Building -> Floor -> Room/Area),
- pilih kategori,
- upload foto bukti,
- isi deskripsi opsional,
- detail lokasi tambahan (`location_details`) untuk area umum,
- check duplicate candidate,
- opsi `Confirm Existing Incident` atau `Create New Incident`.

### 4.3 Duplicate Suggestion Screen / Dialog
- Card / modal rekomendasi incident serupa.
- Preview insiden kandidat dengan judul, lokasi, foto, status.
- Aksi utama: `Ini masalah yang sama`.
- Aksi alternatif: `Buat laporan baru`.

### 4.4 My Incidents / My Reports Screen
- Daftar laporan dan incident terkait yang dibuat oleh student.
- Status ringkas dan badge.
- Akses cepat ke incident detail dan timeline.

### 4.5 Incident Detail for Student
- Lihat status lifecycle (`Open`, `Assigned`, `In Progress`, `Resolved`, `Closed`).
- Timeline visual dengan milestone.
- Gallery bukti.
- Konfirmasi / follow-up jika isu sama.
- Tombol `Request Reopen` untuk incident `Resolved` / `Closed`.

### 4.6 Reopen Request Screen
- Form untuk alasan reopen.
- Upload foto tambahan optional.
- Konfirmasi dan notifikasi status review.

## 5. Maintenance Staff Screens

Maintenance staff butuh fokus pada daftar tugas, notifikasi assignment, dan update progress.

### 5.1 Staff Task List (Tugas Saya)
- Daftar incident yang ditugaskan ke staff.
- Kartu tugas menampilkan prioritas, kategori, lokasi, status, dan thumbnail bukti.
- Filter / sort minimal berdasarkan status atau overdue.
- Tap kartu → Staff Task Detail dengan staff actions.

### 5.2 Staff Task Detail Screen
- Detail incident yang ditugaskan.
- Foto besar, lokasi, kategori, deskripsi, dan link report.
- Timeline singkat.
- Note pekerjaan dan checklist kerja.
- Tombol sticky untuk update status: `Mulai Kerjakan`, `Selesai`, atau `Tambah Catatan`.

### 5.3 Create Budget Request (RAB) Screen
- Tombol "Buat RAB" di task detail saat status `Assigned`.
- Form input item RAB: deskripsi, qty, satuan, harga satuan.
- Total otomatis kalkulasi.
- Riwayat RAB versi sebelumnya + status (kalau ada revisi).
- Saat ditolak admin: tampilkan alasan dan tombol "Revisi RAB".

### 5.4 Status Update / Completion Screen
- Form sederhana untuk mengubah status ke `In Progress` / `Resolved`.
- Input catatan kerja.
- Upload bukti penyelesaian jika diperlukan.

### 5.4 Staff Notifications
- Notifikasi assignment baru, perubahan status, dan reopen request.
- Reuse NotificationScreen yang sama dengan student.

### 5.5 Staff Profile / Workload Screen
- Informasi akun staff.
- Ringkasan tugas aktif.
- Metrik personal sederhana (misal jumlah task open / in progress / overdue).

## 6. Facility Admin Screens

Admin fokus pada incident handling, assignment, dan ringkasan operasional.

### 6.1 Admin Overview / Dashboard Screen
- Widget metrik utama:
  - Open incidents,
  - Unassigned incidents,
  - High / critical incidents,
  - Overdue incidents,
  - Staff active workload.
- Quick action cards untuk `Assign`, `Review`, atau `Close`.

### 6.2 Incident List Screen
- Daftar incident dengan filter dan search:
  - filter by status,
  - filter by location,
  - filter by assigned staff,
  - filter by priority.
- Kartu menampilkan summary incident, status badge, assignment state, dan konfirmasi count.

### 6.3 Incident Detail for Admin
- Full context: lokasi, kategori, data laporan, linked reports, confirm count.
- Timeline lengkap termasuk assignment history dan status changes.
- Quick assignment panel / inline action (tanpa perlu buka halaman detail).
- Tombol `Assign`, `Reassign`, `Close`, `Reject`.
- Note: `Request Info` dan `Merge / Split` tidak diimplementasi di MVP (butuh sistem notifikasi & data ops kompleks — Phase 2).

### 6.4 Budget Approval Screen
- Tab/section baru **"Persetujuan Anggaran"** di dashboard admin.
- List RAB pending (insiden status `Menunggu Anggaran`) dengan total biaya.
- Tap item → detail RAB: daftar item, total biaya, catatan teknisi.
- Tombol **Setujui** (→ `In Progress`) / **Tolak** (wajib isi alasan).
- Setelah setujui: tombol **Cetak PDF** → dokumen RAB formal siap diajukan ke keuangan kampus.

### 6.5 Quick Assignment / Action Panel
- Modal atau popover untuk menugaskan staff tanpa pindah halaman.
- Penugasan manual dengan due date optional.
- Override priority dan alasan (jika perlu).

### 6.5 Master Data / Location Management Screen
- CRUD lokasi utama: building, floor, room/area.
- Data kategori masalah.
- Optional asset management jika data asset tersedia.

### 6.6 Admin Audit / Activity Screen
- Riwayat audit log penting.
- Catatan siapa melakukan assign / close / reopen / merge.
- Filter berdasarkan user, incident, atau action.

## 7. Super Admin Screens

Super Admin mengelola sistem dan user, serta dapat melihat overview global.

### 7.1 Super Admin Dashboard Screen
- Ringkasan global seperti admin overview,
- ditambah status sistem, jumlah user per role, dan konfigurasi master data.

### 7.2 User Management Screen
- Daftar semua user dengan role.
- CRUD user, assign role, dan aktif / non-aktifkan.
- Role matrix overview.

### 7.3 System Config Screen
- Manajemen konfigurasi sistem tingkat atas:
  - RBAC / role settings dan permission overrides,
  - system-wide defaults (SLA thresholds, scoring),
  - audit trail konfigurasi.
- Note: Operasional master data (locations, categories) dikelola oleh Facility Admin (6.5). Super Admin dapat melihat namun tidak perlu mengelola data operasional harian.

### 7.4 Audit Log / System Events Screen
- Same as Admin audit log, plus perubahan sistem dan user management events.

## 8. Navigation & Role-Based Flow

### 8.1 Role-Based Bottom Navigation Dock
- Student: Home, New Report, My Incidents, Profile.
- Staff: Tugas Saya, Notifications, Profile.
- Admin: Overview, Incidents, Staff Workload, Master Data.
- Super Admin: Overview, Incidents, System Config, Users, Profile.

### 8.2 Shared Modal / Flow Screens
- Duplicate suggestion modal.
- Confirm same incident modal.
- Report submission success / failure.
- Status update confirmation.

## 9. Completeness Check

Dari dokumen yang dibaca, layar berikut wajib ada untuk mencakup fungsionalitas MVP:
- autentikasi dan role guard,
- laporan cepat untuk student,
- deduplication / confirmation flow,
- incident detail dengan timeline,
- staff task handling,
- admin incident management dan quick assignment,
- admin master data management (lokasi & kategori),
- super admin user management & system config,
- audit log dan reopen request.

Jika ingin, langkah berikutnya adalah membuat mockup per role berdasarkan daftar ini sebelum masuk ke implementasi InsForge.
