# SYS_DESIGN.md

# CIVIC Campus System Design

## 1. System Design Goals

Sistem dirancang untuk menjaga satu prinsip utama:

Satu masalah fasilitas nyata harus menjadi satu incident operasional.

Report, confirmation, foto, komentar, assignment, dan status update adalah informasi pendukung untuk incident tersebut.

Tujuan desain sistem:

- mengurangi duplicate clutter,
- menjaga data historis,
- membuat workflow admin ringkas,
- memberi teknisi tugas yang jelas,
- memberi mahasiswa transparansi,
- menjaga implementasi tetap realistis untuk mahasiswa informatika.

---

## 2. Core Domain Model

## 2.1 User

User adalah akun yang dapat masuk ke sistem.

Role:

- Student,
- Maintenance Staff,
- Facility Admin,
- Super Admin.

## 2.2 Location

Lokasi fisik kampus.

Hierarchy MVP:
```text
Building -> Floor -> Room/Area (Termasuk tipe area umum seperti Koridor, Lobi, Toilet)
```

Location wajib ada pada setiap report dan incident.

Untuk mendukung pelaporan di area non-spesifik, master data lokasi harus menyertakan entitas "Area Umum" per lantai, dan form pelaporan menyertakan kolom wajib `location_details` (deskripsi tambahan petunjuk lokasi fisik).

## 2.3 Category

Jenis masalah fasilitas.

Contoh:

- Air Conditioner,
- Lighting,
- Electrical,
- Projector,
- Plumbing,
- Toilet,
- Furniture,
- Internet/WiFi,
- Cleanliness,
- Structural Damage.

## 2.4 Asset

Asset adalah objek fasilitas spesifik. Pada MVP, asset opsional.

Jika data asset belum lengkap, sistem tetap bisa berjalan dengan location + category.

## 2.5 Report

Report adalah observasi dari user.

Report menyimpan:

- user,
- location,
- location_details (detail lokasi fisik tambahan),
- category,
- photo (wajib, dikompresi di sisi gawai < 500KB sebelum diunggah),
- description,
- timestamp,
- linked incident.

Report bersifat historis dan tidak diedit menjadi ticket kerja.

## 2.6 Incident

Incident adalah satu masalah operasional nyata.

Incident menyimpan:

- title,
- location,
- category,
- status,
- priority,
- assigned staff,
- linked reports,
- confirmations,
- timeline.

## 2.7 Confirmation

Confirmation adalah sinyal bahwa user mengalami masalah yang sama.

Constraint:

- satu user hanya boleh confirm satu incident satu kali,
- confirmation dapat menambahkan komentar/foto opsional.

## 2.8 Assignment

Assignment menghubungkan incident dengan staff.

Assignment menyimpan:

- assigned staff,
- assigned by,
- assigned at,
- due date optional,
- status,
- notes.

## 2.9 Audit Log

Audit log menyimpan action penting secara append-only.

---

## 3. Incident Lifecycle Design

## 3.1 MVP State Machine

```text
Open
  |
  v
Assigned
  |
  v
In Progress
  |
  v
Resolved
  |
  v
Closed
```

Alternative flows:

```text
Open/Assigned/In Progress -> Rejected
Closed/Resolved -> Reopen Requested -> Open
Any Active State -> Waiting Parts flag
```

## 3.2 State Definitions

| Status | Definition | Owner |
|---|---|---|
| Open | Incident baru, belum ditugaskan | Admin |
| Assigned | Sudah ada staff bertanggung jawab | Admin |
| In Progress | Staff sedang menangani | Staff |
| Resolved | Staff menandai selesai dengan bukti | Staff |
| Closed | Admin menyetujui penyelesaian | Admin |

## 3.3 Flags

Untuk menghindari lifecycle terlalu rumit, beberapa kondisi menjadi flag:

- `is_rejected`,
- `reopen_requested`,
- `waiting_parts`,
- `needs_review`,
- `is_overdue`.

Flag memberi konteks tanpa menambah terlalu banyak status.

## 3.4 Transition Rules

- Student tidak dapat mengubah status incident.
- Staff hanya dapat update incident yang ditugaskan.
- Admin dapat assign, reassign, close, reject, dan reopen.
- Resolved harus menyertakan completion note atau evidence.
- Closed menyimpan actor dan timestamp.
- Reopen harus menyertakan reason.

---

## 4. Reporting Flow

## 4.1 Main Flow

```text
Student opens Report
      |
      v
Select Location
      |
      v
Select Category
      |
      v
Upload Photo
      |
      v
Optional Description
      |
      v
Check Possible Duplicate
      |
      +-----------------------------+
      |                             |
      v                             v
Confirm Existing Incident      Create New Incident
```

## 4.2 Server-Side Submit Flow

Pembuatan report harus aman terhadap race condition.

```text
Begin Transaction
  Create report draft
  Recheck active incident candidates
  If user selected existing incident:
    link report to incident
    create confirmation if needed
  Else:
    create new incident
    link report to new incident
  create timeline event
  create audit log
Commit
```

## 4.3 Why Recheck on Server

Flutter boleh menampilkan suggestion, tetapi keputusan final tetap dicek ulang di backend/database. Ini mencegah dua user yang submit bersamaan membuat duplicate incident tanpa perlu.

---

## 5. Deduplication System Design

## 5.1 Design Principle

Deduplication MVP harus:

- murah dihitung,
- mudah dijelaskan,
- tidak memakai ML,
- menghindari false merge,
- memberi admin kontrol koreksi.

## 5.2 Candidate Query

Cari incident yang:

- status bukan Closed,
- location sama atau masih dalam parent location yang relevan,
- category sama atau related,
- updated dalam window aktif,
- tidak rejected.

## 5.3 Scoring Formula MVP

```text
score = location_score + category_score + time_score + keyword_score
```

Location:

- same room/area: 50
- same floor: 30
- same building: 20

Category:

- same category: 30
- related category: 15

Time:

- updated within 24h: 20
- updated within 7d: 10
- older active incident: 5

Keyword:

- simple keyword overlap: 0-10

## 5.4 Decision

| Score | System Behavior |
|---:|---|
| 70+ | Show strong existing incident suggestion |
| 40-69 | Show possible match |
| < 40 | Create new incident by default |

## 5.5 User Choice

Jika suggestion muncul, user melihat:

- lokasi,
- kategori,
- foto utama,
- status,
- jumlah confirmation,
- last update.

User memilih:

- "Masalah yang sama",
- "Buat laporan baru".

## 5.6 Admin Correction

Admin dapat:

- link report ke incident lain,
- merge incident yang jelas sama,
- split report bila salah gabung.

Untuk MVP, minimal manual link sudah cukup. Merge/split penuh bisa phase 2.

---

## 6. Priority Design

## 6.1 Priority Score

Priority dihitung sederhana:

```text
priority_score =
  severity_score +
  confirmation_score +
  location_criticality_score +
  age_score
```

## 6.2 Score Inputs

Severity:

- Critical safety issue: 50
- High operational disruption: 35
- Medium issue: 20
- Low issue: 10

Confirmation:

- 1-2 confirmations: 5
- 3-5 confirmations: 10
- more than 5: 20

Location criticality:

- classroom/lab/server room: 20
- public service area: 15
- corridor/common area: 10
- low impact area: 5

Age:

- open more than 1 day: 5
- open more than 3 days: 10
- open more than 7 days: 20

## 6.3 Priority Output

| Score | Priority |
|---:|---|
| 0-29 | Low |
| 30-59 | Medium |
| 60-89 | High |
| 90+ | Critical |

Admin dapat override priority dengan alasan.

---

## 7. Assignment System

## 7.1 Assignment Flow

```text
Open Incident
      |
      v
Admin reviews context
      |
      v
Admin assigns staff
      |
      v
Staff receives task
      |
      v
Staff updates progress
      |
      v
Staff marks resolved
      |
      v
Admin closes
```

## 7.2 Staff Task View

Staff tidak perlu melihat semua data admin.

Staff melihat:

- assigned incidents,
- location,
- category,
- photo evidence,
- priority,
- notes,
- status action.

## 7.3 Admin Workload Protection

Admin page harus menyediakan:

- quick assign,
- filter unassigned,
- filter high priority,
- bulk view,
- suggested duplicate indicator,
- overdue indicator.

Tujuannya agar admin tidak membuka terlalu banyak halaman untuk keputusan sederhana.

---

## 8. Notification System

## 8.1 Notification Events

| Event | Recipient |
|---|---|
| Incident created high/critical | Admin |
| Incident assigned | Staff |
| Status changed | Reporter and followers |
| Incident resolved | Reporter and followers |
| Incident closed | Reporter and followers |
| Reopen requested | Admin |

## 8.2 Notification Storage

Table `notifications`:

- id,
- user_id,
- type,
- title,
- body,
- entity_type,
- entity_id,
- read_at,
- created_at.

## 8.3 Push Strategy

MVP wajib in-app notification.

FCM optional:

- assignment,
- status resolved/closed,
- high priority alert.

---

## 9. Reopen System

## 9.1 Reopen Conditions

User dapat request reopen jika:

- masalah belum selesai,
- masalah muncul lagi,
- perbaikan tidak efektif.

## 9.2 Reopen Flow MVP

```text
Closed/Resolved Incident
      |
      v
User submits reopen reason + optional photo
      |
      v
Admin receives review notification
      |
      v
Admin accepts -> status Open
Admin rejects -> keep Closed with reason
```

## 9.3 Safeguards

- reopen request harus ditinjau oleh Admin (tidak berganti status langsung ke Open secara otomatis).
- reopen reason wajib.
- photo bukti kerusakan terbaru sangat disarankan.
- maksimal pengajuan reopen request dibatasi 2 kali per pengguna untuk satu insiden guna mencegah penyalahgunaan (*abuse reopen loop*).
- audit log selalu dibuat.

---

## 10. Audit System

## 10.1 Logged Events

- user login optional,
- report created,
- report linked,
- incident created,
- incident status changed,
- incident assigned,
- priority changed,
- staff note added,
- resolved,
- closed,
- reopen requested,
- rejected.

## 10.2 Audit Fields

- id,
- actor_id,
- action,
- entity_type,
- entity_id,
- previous_value,
- new_value,
- metadata,
- created_at.

## 10.3 Rule

Audit log tidak diedit dan tidak dihapus lewat aplikasi.

---

## 11. Analytics Design

## 11.1 MVP Analytics

Analytics harus membantu keputusan admin, bukan sekadar grafik cantik.

Metrics:

- open incidents,
- unassigned incidents,
- high/critical incidents,
- average resolution time,
- top categories,
- top locations,
- overdue incidents,
- staff active workload.

## 11.2 Query Strategy

Untuk MVP:

- hitung langsung dari PostgreSQL dengan index,
- gunakan view SQL jika query mulai panjang,
- tidak perlu scheduled aggregation.

Phase 2:

- materialized view,
- scheduled refresh,
- export report.

---

## 12. Concurrency Handling

## 12.1 Problem

Dua user bisa melaporkan masalah yang sama dalam waktu berdekatan.

## 12.2 MVP Solution

Saat submit:

1. backend mulai transaksi,
2. simpan report,
3. query ulang active incident candidate,
4. link ke incident existing jika user memilih/match kuat,
5. atau buat incident baru,
6. commit.

## 12.3 Database Constraint

Gunakan constraint untuk:

- satu confirmation per user per incident,
- status valid,
- assignment mengarah ke staff valid,
- required foreign key.

---

## 13. Search and Filtering

MVP search:

- by location name,
- by category,
- by incident title/description,
- by status,
- by priority.

Admin filters:

- unassigned,
- overdue,
- high priority,
- location,
- staff,
- date range.

---

## 14. Security Design

## 14.1 RBAC Rules

Backend/database wajib mengecek role.

Contoh:

- Student hanya boleh membuat report dan confirmation.
- Staff hanya update assignment miliknya.
- Admin dapat assign dan close.
- Super Admin dapat manage users and master data.

## 14.2 File Validation

Upload harus membatasi:

- MIME image,
- size,
- extension,
- generated filename.

## 14.3 Abuse Prevention

- report cooldown,
- confirmation uniqueness,
- reject reason,
- audit trail,
- admin review for reopen.

---

## 15. Data Retention

## 15.1 Historical Preservation

Report, incident, assignment, dan audit log tidak hard-delete pada penggunaan normal.

## 15.2 Soft Delete

Gunakan:

- `deleted_at`,
- `archived_at`,
- `is_active`.

Master data seperti location/category boleh di-nonaktifkan agar tidak merusak data lama.

---

## 16. Failure Handling

## 16.1 Upload Failure

Jika upload foto gagal:

- report tidak dikirim,
- user diberi retry,
- draft tetap tersimpan lokal.

## 16.2 Notification Failure

Jika FCM gagal:

- in-app notification tetap tersimpan,
- status operasional tidak gagal hanya karena push gagal.

## 16.3 Partial Submit Failure

Gunakan transaksi agar report dan incident link tidak setengah jadi.

---

## 17. Suggested Database Tables

Minimum schema:

```text
profiles
roles
locations
categories
incidents
reports
report_attachments
confirmations
assignments
status_history
maintenance_notes
notifications
reopen_requests
audit_logs
```

Optional schema:

```text
assets
incident_links
priority_overrides
```

---

## 18. Future System Evolution

Phase 2:

- better text similarity,
- manual merge/split,
- SLA configuration,
- FCM push,
- CSV/PDF export.

Phase 3:

- category suggestion,
- recurring incident detection,
- materialized analytics,
- preventive maintenance insight.

Phase 4:

- image similarity,
- IoT sensor integration,
- multi-campus support.

---

## 19. Final System Design Principles

Sistem ini sengaja dibuat sederhana di infrastruktur, tetapi tetap serius di domain model.

Yang tidak boleh dikorbankan:

- incident/report separation,
- deduplication before incident creation,
- role-based authorization,
- status timeline,
- audit log,
- admin-focused workflow,
- data integrity.

Yang boleh disederhanakan untuk MVP:

- AI,
- push notification,
- background worker,
- analytics berat,
- asset management detail,
- offline sync penuh.

Dengan batas ini, project tetap feasible untuk mahasiswa, tetapi rancangan sistemnya tidak berubah menjadi aplikasi laporan biasa.
