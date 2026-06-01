# ARCHITECTURE.md

# CIVIC Campus Architecture

## 1. Architecture Philosophy

Arsitektur CIVIC Campus dibuat untuk project mahasiswa informatika yang tetap serius secara rancangan sistem.

Prinsip utamanya:

- sederhana untuk dibangun,
- murah/gratis untuk demo,
- mudah dijelaskan,
- cukup kuat untuk data operasional nyata,
- tidak menambah beban admin,
- bisa dikembangkan bertahap tanpa rewrite besar.

Sistem ini bukan sekadar CRUD laporan. Namun untuk MVP, "kecerdasan" sistem dibuat dengan rule-based logic, transaksi database, dan workflow yang rapi, bukan infrastruktur berat.

---

## 2. Recommended Demo Architecture

```text
+------------------------------------------------+
|                 Flutter App                    |
|------------------------------------------------|
| Student UI | Staff UI | Admin UI               |
+------------------------|-----------------------+
                         |
                         v
+------------------------------------------------+
|                  InsForge                      |
|------------------------------------------------|
| PostgreSQL | Storage | Auth | Edge Functions   |
+------------------------------------------------+
```

Untuk demo Rp0, backend di-host sepenuhnya di platform **InsForge**, yang menyediakan database PostgreSQL, autentikasi, penyimpanan berkas, dan Deno Edge Functions secara terpadu tanpa perlu melakukan setup manual.

---

## 3. Deployment Options

## 3.1 Option A: InsForge Direct Integration

Gunakan:
- Flutter app,
- InsForge Auth,
- InsForge PostgreSQL,
- InsForge Storage,
- InsForge Edge Functions untuk custom backend logic (seperti secure submit dan auto-reopen rules).

Kelebihan:
- biaya demo Rp0,
- tidak perlu setup server manual (AI-agent friendly),
- database, auth, dan storage sudah terintegrasi dari awal.

Kekurangan:
- tergantung pada platform InsForge.

## 3.2 Option B: Local / Self-Hosted Docker (Bila Diperlukan)

Gunakan:
- Docker-compose lokal untuk menjalankan image InsForge.
- Flutter app terhubung ke localhost.

Kelebihan:
- kontrol penuh atas infrastruktur,
- tidak bergantung konektivitas internet luar untuk demo lokal.

Kekurangan:
- membutuhkan setup docker di laptop pemakai.

## 3.3 Recommendation

Gunakan **Option A (InsForge Cloud Trial)** untuk pengembangan cepat dan demo yang stabil, karena tidak memerlukan setup manual dari sisi pengguna.

---

## 4. Client Architecture

## 4.1 One Flutter App, Multi-Role UI

Gunakan satu aplikasi Flutter dengan role-based routing.

Role:

- Student,
- Maintenance Staff,
- Facility Admin,
- Super Admin.

Jangan membuat tiga aplikasi terpisah untuk MVP. Itu akan melipatgandakan effort UI, testing, dan deployment.

## 4.2 Suggested Flutter Structure

```text
lib/
  app/
    router/
    theme/
    auth_guard.dart
  core/
    api/
    errors/
    utils/
  features/
    auth/
    reports/
    incidents/
    assignments/
    notifications/
    dashboard/
    admin/
  shared/
    widgets/
    models/
```

## 4.3 State Management

Rekomendasi:

- Riverpod, atau
- Provider jika ingin lebih sederhana.

Yang penting:

- auth state jelas,
- role-based navigation konsisten,
- form reporting tidak mudah kehilangan state.

## 4.4 Offline Support MVP

Offline penuh tidak wajib untuk MVP.

Minimal:

- simpan draft report lokal sebelum submit,
- tampilkan error upload yang jelas,
- user dapat retry submit.

Gunakan:

- SharedPreferences untuk draft sederhana,
- Hive jika butuh menyimpan queue lokal.

---

## 5. Backend Architecture

## 5.1 Architecture Style

Gunakan modular monolith.

Satu backend, beberapa module:

- Auth/RBAC,
- Location,
- Report,
- Incident,
- Assignment,
- Notification,
- Analytics,
- Audit.

Microservices tidak digunakan pada MVP karena menambah deployment, debugging, dan biaya mental tanpa manfaat nyata untuk demo.

## 5.2 Module Boundaries

```text
Backend
  Auth Module
  User & Role Module
  Location Module
  Report Module
  Incident Module
  Deduplication Service
  Assignment Module
  Notification Module
  Analytics Module
  Audit Module
```

Deduplication dan priority engine dibuat sebagai service internal, bukan service terpisah.

---

## 6. Core Backend Modules

## 6.1 Auth & RBAC Module

Responsibilities:

- login,
- session validation,
- role check,
- route guard,
- permission mapping.

MVP role matrix:

| Action | Student | Staff | Admin | Super Admin |
|---|---:|---:|---:|---:|
| Create report | yes | yes | yes | yes |
| Confirm incident | yes | yes | yes | yes |
| View public incidents | yes | yes | yes | yes |
| View assigned tasks | no | yes | yes | yes |
| Assign incident | no | no | yes | yes |
| Change status to Closed | no | no | yes | yes |
| Manage users | no | no | no | yes |

## 6.2 Location Module

Handles:

- campuses,
- buildings,
- floors,
- rooms,
- areas.

Untuk MVP, location hierarchy cukup:

```text
Building -> Floor -> Room/Area
```

## 6.3 Report Module

Handles:

- report submission,
- photo upload reference,
- report metadata,
- linking report to incident.

Rule:

- report append-only,
- report tidak menjadi task langsung untuk admin,
- report selalu masuk ke incident existing atau incident baru.

## 6.4 Incident Module

Handles:

- incident lifecycle,
- status timeline,
- priority,
- closure,
- reopen request,
- manual merge/link correction.

Incident adalah object utama dashboard admin.

## 6.5 Deduplication Service

MVP menggunakan rule-based candidate matching yang berjalan secara atomik di tingkat database guna menghindari balapan submit (*concurrency submit race condition*):

1. **Transaction & Row Locking (`FOR UPDATE`)**: Mengunci baris incident aktif yang cocok di lokasi dan kategori yang sama.
2. **Scoring Logic**:
   - Same room/area: +50
   - Same floor: +30
   - Same building: +20
   - Same category: +30
   - Related category: +15
   - Updated within 24h: +20
   - Updated within 7d: +10
3. **Database Function (RPC)**: Fungsi server-side `submit_report_secure` bertindak sebagai *gatekeeper* untuk menduplikasi secara atomik.

Tidak perlu ML, image similarity, atau embedding untuk MVP.

## 6.6 Assignment Module

Handles:

- assign staff,
- assignment status,
- repair notes,
- completion evidence.

## 6.7 Notification Module

MVP:

- database-backed in-app notification.

Optional:

- Firebase Cloud Messaging.

## 6.8 Analytics Module

MVP analytics dihitung dari query PostgreSQL biasa.

Metrics:

- open incidents,
- resolved this week,
- average resolution time,
- top locations,
- top categories,
- overdue count,
- staff workload.

## 6.9 Audit Module

Audit log wajib untuk action penting.

Audit table append-only dan tidak diedit lewat UI.

---

## 7. Database Architecture

## 7.1 Primary Database

Gunakan PostgreSQL via InsForge database instance.

Alasan:
- relational data cocok untuk incident workflow,
- transaksi kuat dengan dukungan DDL & DML penuh,
- indexing cukup,
- storage dan auth terintegrasi secara semantik,
- gratis untuk trial/demo.

## 7.2 Core Tables

Minimum tables:

- users/profile,
- roles,
- locations,
- categories,
- incidents,
- reports,
- report_attachments,
- confirmations,
- assignments,
- status_history,
- maintenance_notes,
- notifications,
- audit_logs.

Optional:

- assets,
- reopen_requests,
- incident_links,
- priority_rules.

## 7.3 Data Ownership

Rules:

- reports tidak dihapus permanen,
- incident boleh archived,
- photo reference disimpan immutable,
- audit log append-only,
- status change selalu mencatat actor dan timestamp.

## 7.4 Indexing Strategy

Buat index untuk:

- incidents.status,
- incidents.location_id,
- incidents.category_id,
- incidents.updated_at,
- reports.created_at,
- assignments.staff_id,
- notifications.user_id,
- audit_logs.entity_id.

Deduplication MVP sangat bergantung pada index location/category/status.

---

## 8. Deduplication Architecture

## 8.1 Goal

Mengurangi laporan duplikat tanpa menggabungkan masalah yang sebenarnya berbeda.

## 8.2 Pipeline

```text
Incoming Report
       |
       v
Find Active Incidents
       |
       v
Filter Same/Near Location
       |
       v
Filter Same/Related Category
       |
       v
Apply Time Window
       |
       v
Score Candidate
       |
       v
Suggest / Create New Incident
```

## 8.3 Scoring MVP

| Signal | Score Example |
|---|---:|
| Same room | +50 |
| Same building/floor | +25 |
| Same category | +30 |
| Related category | +15 |
| Updated within 24 hours | +20 |
| Updated within 7 days | +10 |
| Similar keywords | +10 |

Threshold:

- 70+ strong suggestion,
- 40-69 possible suggestion,
- below 40 create new.

Strong suggestion tetap ditampilkan ke user. Auto-merge dapat dihindari pada MVP agar aman.

---

## 9. Notification Architecture

## 9.1 Event Source

Notification dibuat saat:

- report linked to incident,
- incident assigned,
- status changed,
- incident resolved,
- incident closed,
- reopen requested.

## 9.2 MVP Delivery

Simpan ke table `notifications`.

Flutter mengambil:

- unread count,
- notification list,
- detail target.

## 9.3 Optional Push

FCM digunakan setelah in-app notification stabil.

---

## 10. File Storage Architecture

Gunakan InsForge Storage (S3-compatible).

Rules:
- kompresi gambar wajib dilakukan di Flutter sebelum diunggah (target ukuran berkas < 500KB dengan resolusi maks 1080p JPEG) untuk mitigasi jaringan lemah di area kampus.
- maksimal ukuran file setelah kompresi dibatasi (misalnya 1 MB).
- hanya image MIME type.
- path berdasarkan report/incident id.
- URL publik terbatas atau signed URL bila perlu.
- simpan metadata upload di database.

---

## 11. Search Architecture

MVP:

- filter location/category/status,
- search by title/description dengan `ILIKE`,
- index sederhana.

Phase 2:

- PostgreSQL Full Text Search.

Tidak perlu Elasticsearch untuk project demo.

---

## 12. Background Jobs

Background worker tidak wajib untuk MVP.

Proses synchronous yang masih aman:

- deduplication scoring,
- notification record creation,
- basic analytics query.

Gunakan scheduled job hanya bila perlu untuk:

- overdue marking,
- daily summary,
- cleanup temporary upload.

Jika memakai InsForge, gunakan scheduled edge functions. Jika backend custom, cron sederhana cukup.

---

## 13. Security Architecture

## 13.1 Authentication

- InsForge Auth (GoTrue).
- Session harus divalidasi di server/API.

## 13.2 Authorization

- RBAC wajib di backend/database.
- UI hiding bukan pengganti authorization.

## 13.3 Upload Security

- validasi MIME,
- limit ukuran,
- jangan percaya filename user,
- simpan path generated.

## 13.4 Abuse Prevention

- cooldown submit report serupa,
- confirmation satu kali per user per incident,
- admin dapat reject/report abuse,
- audit log untuk action sensitif.

---

## 14. Observability for Demo

Tidak perlu Prometheus/Grafana untuk MVP.

Gunakan:

- backend logs,
- InsForge logs,
- simple error messages,
- optional Sentry free tier.

Yang penting untuk demo:

- error submit dapat dibaca,
- failed upload tidak silent,
- admin tahu bila action gagal.

---

## 15. Scalability Strategy

## 15.1 Demo Scale

Single app + InsForge cukup.

## 15.2 Early Production

Tambahkan:

- backend custom,
- cache optional,
- scheduled jobs,
- FCM,
- better analytics views.

## 15.3 Future Scale

Baru pertimbangkan:

- queue system,
- Redis,
- dedicated search,
- background workers,
- microservices,

jika traffic dan kebutuhan operasional sudah nyata.

---

## 16. CI/CD

Untuk project mahasiswa:

- lint Flutter,
- test service critical,
- migration SQL tersimpan,
- seed data demo,
- README setup jelas.

CI GitHub Actions optional, tetapi bagus untuk nilai engineering.

---

## 17. Backup and Recovery

Untuk demo:

- export schema SQL,
- seed data,
- backup manual InsForge database.

Untuk production:

- scheduled backup,
- storage backup,
- restore procedure.

---

## 18. Architecture Principles

Arsitektur yang benar untuk project ini bukan yang paling kompleks, tetapi yang:

- menjaga incident integrity,
- mengurangi pekerjaan admin,
- aman dari laporan duplikat berlebihan,
- mudah dibangun mahasiswa,
- berjalan gratis untuk demo,
- dan bisa tumbuh secara bertahap.

Fondasi sistem tetap serius: RBAC, transaksi, audit log, deduplication, lifecycle, dan dashboard operasional. Yang disederhanakan hanya infrastrukturnya, bukan cara berpikir sistemnya.
