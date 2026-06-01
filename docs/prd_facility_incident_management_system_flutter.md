# PRD.md

# CIVIC Campus Facility Incident Management System

## 1. Overview

CIVIC Campus adalah aplikasi mobile-first untuk melaporkan, mengelompokkan, memantau, dan menyelesaikan kerusakan fasilitas kampus secara terstruktur.

Masalah utama yang diselesaikan bukan sekadar "mahasiswa bisa komplain", tetapi bagaimana satu kerusakan nyata di kampus tidak berubah menjadi puluhan chat, laporan ganda, dan follow-up manual yang menambah pekerjaan admin.

Sistem ini dirancang agar:

- mahasiswa dapat melapor dengan cepat,
- laporan serupa otomatis diarahkan ke insiden yang sama,
- admin mengelola insiden, bukan tumpukan laporan mentah,
- teknisi menerima pekerjaan yang jelas,
- riwayat tindakan tercatat,
- pimpinan kampus mendapat ringkasan operasional yang berguna.

Target project ini adalah MVP/demo yang realistis untuk mahasiswa informatika dengan bantuan AI dan biaya operasional Rp0 untuk demo.

---

## 2. Problem Statement

### 2.1 Kondisi Saat Ini

Pelaporan kerusakan fasilitas kampus sering tersebar di:

- grup WhatsApp,
- laporan lisan,
- pesan pribadi ke dosen/staf,
- media sosial,
- form manual,
- catatan administrasi.

Akibatnya:

- laporan mudah terlewat,
- masalah yang sama dilaporkan berkali-kali,
- admin harus membaca dan menggabungkan informasi secara manual,
- teknisi kurang mendapat konteks lokasi dan bukti,
- mahasiswa tidak tahu apakah laporan diproses,
- kampus tidak punya data historis yang rapi.

### 2.2 Prinsip Masalah

Satu kerusakan nyata seharusnya menjadi satu insiden operasional.

Semua laporan tambahan tentang masalah yang sama harus menjadi:

- konfirmasi,
- bukti tambahan,
- komentar pendukung,
- atau riwayat kejadian,

bukan tiket baru yang menambah beban admin.

---

## 3. Goals

### Primary Goals

- Memusatkan pelaporan kerusakan fasilitas kampus.
- Mengurangi laporan duplikat dengan deduplication sederhana namun efektif.
- Membantu admin memprioritaskan dan menugaskan pekerjaan.
- Memberi mahasiswa visibilitas status laporan.
- Mencatat riwayat tindakan untuk accountability.
- Menyediakan dashboard ringkas tanpa membuat admin harus bekerja dua kali.

### Secondary Goals

- Mengurangi waktu tunggu perbaikan.
- Membuat data fasilitas lebih mudah dianalisis.
- Menemukan lokasi/kategori masalah yang sering berulang.
- Meningkatkan kepercayaan mahasiswa terhadap kanal pelaporan resmi.

---

## 4. Non-Goals MVP

Untuk MVP/demo, sistem tidak akan:

- menggunakan machine learning untuk image similarity,
- memakai microservices,
- memakai Elasticsearch,
- memakai background worker wajib,
- menggantikan sistem pengadaan barang kampus,
- menjadi media sosial diskusi publik,
- mendukung multi-kampus kompleks,
- membuat analytics prediktif,
- mengelola inventory spare part secara penuh.

Fitur tersebut dapat menjadi phase 2 atau riset lanjutan setelah MVP stabil.

---

## 5. Target Users

## 5.1 Student

Mahasiswa sebagai pelapor utama.

Kebutuhan:

- lapor cepat,
- tidak perlu mengisi form panjang,
- tahu apakah masalah sudah ada yang melaporkan,
- bisa melihat status perbaikan,
- bisa mengonfirmasi masalah yang sama.

## 5.2 Maintenance Staff

Petugas/teknisi yang menangani perbaikan.

Kebutuhan:

- daftar tugas yang jelas,
- lokasi dan foto bukti,
- update status sederhana,
- catatan pekerjaan,
- bukti selesai.

## 5.3 Facility Admin

Admin fasilitas yang mengatur validasi, prioritas, dan penugasan.

Kebutuhan:

- melihat insiden yang perlu tindakan,
- menggabungkan laporan serupa bila perlu,
- menugaskan teknisi,
- memantau status,
- melihat ringkasan masalah tanpa menelusuri chat manual.

## 5.4 Super Admin

Pengelola sistem untuk demo atau produksi internal.

Kebutuhan:

- mengelola user dan role,
- mengelola data lokasi/kategori,
- melihat audit log,
- menjaga konfigurasi dasar sistem.

---

## 6. Core Concepts

## 6.1 Location

Lokasi fisik kampus seperti gedung, lantai, ruangan, atau area umum.

Contoh:

- Gedung F / Lantai 2 / Ruang F201
- Perpustakaan / Area Baca
- Koridor Gedung A

Untuk MVP, location lebih penting daripada asset detail. Asset spesifik dapat ditambahkan bila tersedia.

## 6.2 Asset

Objek fasilitas spesifik di suatu lokasi.

Contoh:

- AC F201-01
- Proyektor Lab A
- Lampu Koridor C

Pada MVP, asset bersifat opsional. Sistem tetap berjalan walau kampus hanya punya data lokasi dan kategori.

## 6.3 Report

Laporan dari user tentang masalah yang dilihat.

Report menyimpan:

- pelapor,
- lokasi,
- kategori,
- foto,
- deskripsi opsional,
- waktu laporan,
- hasil deduplication.

Report tidak dihapus permanen karena menjadi bukti historis.

## 6.4 Incident

Satu masalah operasional nyata yang harus ditangani.

Satu incident dapat memiliki banyak report dan confirmation.

Contoh:

- "AC Ruang F201 tidak dingin"
- "Lampu koridor Gedung A mati"

## 6.5 Confirmation

Sinyal ringan dari user bahwa ia mengalami masalah yang sama.

Confirmation mengurangi laporan duplikat dan membantu priority score.

---

## 7. Product Principles

## 7.1 Admin Work Reduction

Sistem harus mengurangi pekerjaan admin, bukan membuat admin harus:

- membaca laporan ganda,
- memasukkan data yang sama berkali-kali,
- memindahkan laporan manual ke sistem lain,
- mengecek status lewat chat terpisah.

Desain produk harus selalu menjawab: "Apakah ini mengurangi beban koordinasi admin?"

## 7.2 Incident First, Report Second

Admin mengelola incident. Report hanya bahan bukti dan sinyal pendukung.

## 7.3 Low-Friction Reporting

Mahasiswa cukup memilih lokasi, kategori, upload foto, dan submit.

## 7.4 Visible Progress

Mahasiswa dan admin harus bisa melihat status tanpa bertanya manual.

## 7.5 Traceable Operations

Perubahan status, assignment, dan closure harus tercatat dalam audit log.

## 7.6 Simple Intelligence

MVP memakai rule-based deduplication dan priority scoring. Tidak perlu AI/ML untuk membuat sistem terasa cerdas.

---

## 8. MVP Scope

MVP yang realistis untuk mahasiswa informatika:

1. Authentication dan role-based access.
2. Data lokasi dan kategori.
3. Submit report dengan foto.
4. Rule-based deduplication.
5. Incident lifecycle sederhana.
6. Confirmation system.
7. Assignment ke maintenance staff.
8. Status update dengan timeline.
9. In-app notification dan FCM optional.
10. Admin dashboard ringkas.
11. Basic analytics.
12. Audit log.

---

## 9. Recommended Free Demo Stack

Biaya demo ditargetkan Rp0.

### Frontend

- Flutter
- Riverpod atau Provider
- Dio untuk HTTP
- SharedPreferences atau Hive untuk draft lokal sederhana

### Backend

Menggunakan platform backend agent-native **InsForge** (gratis untuk trial/demo):

- InsForge Auth (berbasis GoTrue)
- InsForge PostgreSQL Database
- InsForge Storage (S3-compatible object storage)
- InsForge Edge Functions (Deno-based serverless functions) untuk logika server-side

### Push Notification

- Firebase Cloud Messaging

### Search

- PostgreSQL `ILIKE` dan indexing sederhana
- PostgreSQL Full Text Search bila sempat

### Cache/Queue

Tidak wajib untuk MVP.

Jika diperlukan:

- Upstash Redis free tier untuk cache ringan

---

## 10. Major Features

## 10.1 Authentication

### MVP Features

- Login email/password.
- Role: Student, Staff, Admin, Super Admin.
- Session persistence.
- RBAC pada API dan UI.

### Demo Simplification

Untuk demo, akun dapat dibuat manual oleh Super Admin atau seed data.

Campus SSO tidak wajib.

---

## 10.2 Report Submission

### Flow

1. User memilih lokasi (termasuk area umum seperti koridor/toilet jika ada).
2. User memilih kategori.
3. User upload foto (otomatis dikompresi oleh aplikasi Flutter sebelum diunggah).
4. User menambah deskripsi petunjuk lokasi tambahan dan deskripsi masalah.
5. Sistem mencari possible duplicate secara aman di server (RPC dengan row-locking).
6. User submit sebagai confirmation atau new report.

### Required Fields

- location,
- location_details (petunjuk lokasi spesifik tambahan),
- category,
- photo.

### Optional Fields

- description,
- urgency note.

---

## 10.3 Deduplication MVP

Deduplication harus efektif tanpa ML.

### Rule Candidate

Cari active incident dengan:

- lokasi sama atau parent location sama,
- kategori sama atau kategori terkait,
- status belum Closed/Rejected,
- dibuat atau di-update dalam window tertentu.

### Default Rule

Jika ada incident aktif dengan:

- same room,
- same category,
- created/updated dalam 7 hari,

maka tampilkan sebagai possible duplicate.

### Outcomes

#### Strong Match

Sistem menyarankan user untuk join/confirm incident existing.

#### Possible Match

User memilih:

- "Ini masalah yang sama"
- "Buat laporan baru"

#### No Match

Sistem membuat incident baru.

### Important Rule

MVP tidak melakukan auto-merge agresif. False merge lebih berbahaya daripada duplicate kecil.

---

## 10.4 Incident Lifecycle MVP

Gunakan 5 status utama:

1. Open
2. Assigned
3. In Progress
4. Resolved
5. Closed

Status tambahan tidak dijadikan state utama di MVP.

Gunakan flag/catatan:

- Rejected,
- Reopened,
- Waiting Parts,
- Needs Review.

### Status Meaning

| Status | Meaning |
|---|---|
| Open | Incident baru dan perlu ditinjau admin |
| Assigned | Sudah ditugaskan ke staff |
| In Progress | Sedang dikerjakan |
| Resolved | Staff menandai selesai dan upload bukti |
| Closed | Admin menutup setelah dianggap selesai |

---

## 10.5 Confirmation System

User dapat:

- confirm incident yang sudah ada,
- tambah foto pendukung,
- tambah komentar singkat,
- mengikuti update status.

Confirmation count menjadi sinyal prioritas.

---

## 10.6 Priority Scoring MVP

Priority tidak perlu kompleks. Gunakan skor sederhana:

| Factor | Example |
|---|---|
| Severity | electrical hazard lebih tinggi dari kursi rusak |
| Confirmation count | makin banyak user terdampak, makin tinggi |
| Location criticality | ruang kelas/lab lebih tinggi dari area non-kritis |
| Incident age | makin lama open, makin naik |

Output priority:

- Low
- Medium
- High
- Critical

Admin tetap bisa override priority.

---

## 10.7 Admin Dashboard

Admin dashboard harus fokus pada tindakan.

### MVP Dashboard

- incident open yang belum ditugaskan,
- incident high/critical,
- incident overdue,
- assignment workload,
- filter location/category/status,
- quick assign,
- quick status update,
- merge/link report manual bila deduplication kurang tepat.

### Anti-Burden Requirement

Admin tidak boleh dipaksa membuka setiap report satu per satu. Halaman utama harus langsung menunjukkan incident yang perlu keputusan.

---

## 10.8 Maintenance Workflow

Staff dapat:

- melihat assignment,
- membuka detail lokasi dan foto,
- mengubah status ke In Progress,
- menambah repair note,
- upload completion evidence,
- menandai Resolved.

Admin yang melakukan Closed agar kualitas tetap terkontrol.

---

## 10.9 Notifications

### MVP Notification

Minimal:

- in-app notification tersimpan di database,
- user mendapat update saat incident berubah status,
- staff mendapat assignment notification,
- admin mendapat alert untuk high/critical incident.

FCM dapat ditambahkan bila waktu cukup.

### Notification Discipline

Sistem tidak mengirim notifikasi untuk setiap perubahan kecil. Hanya event yang berguna.

---

## 10.10 Analytics MVP

Analytics cukup ringkas dan actionable:

- total open incidents,
- resolved this week,
- average resolution time,
- top problematic locations,
- top categories,
- overdue incidents,
- staff workload count.

Tidak perlu heatmap canggih untuk MVP.

---

## 10.11 Audit Trail

Audit log wajib untuk action penting:

- incident created,
- report linked,
- status changed,
- assigned/reassigned,
- priority changed,
- resolved,
- closed,
- reopened,
- rejected.

Audit log bersifat append-only.

---

## 11. Functional Requirements

| ID | Requirement |
|---|---|
| FR-01 | User dapat login sesuai role |
| FR-02 | Student dapat membuat report |
| FR-03 | Sistem mencari possible duplicate sebelum membuat incident baru |
| FR-04 | User dapat confirm incident existing |
| FR-05 | Admin dapat melihat daftar incident, bukan hanya report mentah |
| FR-06 | Admin dapat assign incident ke staff |
| FR-07 | Staff dapat update progress dan upload bukti selesai |
| FR-08 | Admin dapat close incident |
| FR-09 | User dapat request reopen dengan alasan dan bukti |
| FR-10 | Sistem menyimpan timeline dan audit log |
| FR-11 | Sistem mengirim in-app notification |
| FR-12 | Admin dapat melihat basic analytics |

---

## 12. Non-Functional Requirements

### Reliability

Report tidak boleh hilang setelah submit berhasil.

### Performance

Flow submit report harus terasa cepat. Target demo: response mayoritas request di bawah 2 detik pada data kecil-menengah.

### Security

- RBAC wajib.
- User tidak boleh mengubah incident tanpa hak.
- Upload divalidasi tipe dan ukuran file.

### Maintainability

Kode harus modular dan mudah dijelaskan saat sidang/demo.

### Cost

MVP demo harus dapat berjalan di free tier.

### Data Integrity

Gunakan transaksi untuk pembuatan report dan incident agar deduplication tidak menghasilkan data kacau.

---

## 13. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Admin tetap merasa terbebani | Dashboard incident-first, quick actions, deduplication, filter prioritas |
| Laporan duplikat masih muncul | Possible duplicate prompt dan manual merge/link oleh admin |
| False merge | Jangan auto-merge agresif; user/admin diberi pilihan |
| FCM sulit saat demo | Gunakan in-app notification dulu |
| Free tier tidur/limit | Siapkan demo seed data dan mode local backend |
| Scope terlalu besar | Kunci MVP dan pindahkan AI/advanced analytics ke phase 2 |
| Data lokasi kampus tidak lengkap | Mulai dari gedung/ruangan sederhana, asset opsional |

---

## 14. Success Metrics

### Demo Success

- User dapat submit report sampai incident terbentuk.
- Report serupa diarahkan ke incident existing.
- Admin dapat assign ke staff.
- Staff dapat menyelesaikan assignment.
- Timeline dan notification terlihat.
- Dashboard menunjukkan ringkasan operasional.

### Product Success

- Duplicate report berkurang.
- Admin lebih cepat menemukan incident penting.
- Mahasiswa lebih percaya karena status terlihat.
- Riwayat perbaikan tersimpan rapi.

---

## 15. Phase Roadmap

### Phase 1: MVP Demo

- Auth + role.
- Location/category seed data.
- Report + photo (dikompresi di sisi gawai).
- Rule-based deduplication (dengan pengecekan concurrency di server).
- Incident lifecycle 5 status.
- Admin dashboard (dengan fitur manual merge/link).
- Staff task view.
- Reopen approval workflow (peninjauan reopen oleh Admin).
- In-app notification.
- Basic analytics.

### Phase 2: Better Operations

- FCM push notification.
- SLA rules automatic escalation.
- Better search.
- Export CSV/PDF summary.

### Phase 3: Intelligence

- Text similarity improvement.
- Category suggestion.
- Recurring incident detection.
- Preventive maintenance insights.

### Phase 4: Advanced

- Image similarity.
- IoT integration.
- Multi-campus deployment.
- Predictive maintenance.

---

## 16. Product Vision

CIVIC Campus bertujuan mengubah pelaporan fasilitas kampus dari proses reaktif dan tersebar menjadi sistem operasional yang:

- mudah dipakai mahasiswa,
- ringan untuk admin,
- jelas untuk teknisi,
- akuntabel untuk kampus,
- dan cukup rapi untuk dikembangkan bertahap.

MVP tidak harus terlihat seperti sistem enterprise besar. Namun fondasinya harus benar: satu masalah nyata menjadi satu incident, semua tindakan tercatat, dan setiap role melihat informasi yang memang mereka butuhkan.
