# CIVIC Campus Design System & UX Documentation

Dokumen ini mendefinisikan filosofi desain, aturan UX, arsitektur informasi, serta sistem visual (tokens) untuk proyek CIVIC Campus (Aplikasi Manajemen Insiden Fasilitas Kampus). Desain ini mengadopsi estetika TripGlide yang modern, bersih, dan mewah dengan fokus operasional yang tegas.

Untuk mempercepat proses pengkodean (*speed up coding*) dan mempermudah pemeliharaan kode (*simplify codebase*), antarmuka aplikasi ini dibangun menggunakan pustaka bawaan **Material Design (Material 3)** di Flutter. Dengan memodifikasi tema bawaan (`ThemeData` dan token warna/bentuk Material 3), kita dapat mewujudkan desain premium TripGlide (seperti sudut melengkung ekstrem dan skema warna obsidian) menggunakan komponen standar Flutter (seperti `Card`, `FloatingActionButton`, dan `NavigationBar`) secara efisien.

---

## 1. Design Philosophy

CIVIC Campus adalah aplikasi operasional berkinerja tinggi, bukan media sosial kampus dan bukan sekadar tabel data administratif tanpa arah.

Desain ini menggabungkan dua pilar utama:
* **Efisiensi Operasional:** Mengurangi koordinasi manual secara drastis melalui kejelasan tugas.
* **Estetika Premium (TripGlide-Inspired):** Menggunakan gaya visual modern, minimalis, bersih, dengan sudut melengkung ekstrem (*highly rounded corners*) dan kontras tinggi untuk memberikan pengalaman penggunaan yang menyenangkan (*delightful UX*).

---

## 2. Visual Design System (TripGlide Style Tokens)

Untuk mereproduksi estetika yang modern dan bersih secara konsisten, seluruh komponen harus mematuhi token desain berikut:

### 2.1 Skema Warna (Color Palette)

Aplikasi menggunakan Light Mode dengan kontras tinggi dari elemen gelap obsidian dan latar belakang abu-abu sangat muda untuk kedalaman visual (*visual depth*).

* **Latar Belakang Utama (Canvas):** `#F4F5F7` (Abu-abu sangat muda / cool gray).
* **Latar Belakang Kartu (Card Background):** `#FFFFFF` (Putih murni).
* **Warna Primer (Primary/Dark Neutral):** `#111827` (Hitam Obsidian). Digunakan untuk teks judul utama, tombol aksi utama, chip kategori aktif, dan dermaga navigasi mengambang (*floating dock*).
* **Warna Sekunder/Muted:** `#6B7280` (Abu-abu medium). Digunakan untuk deskripsi, ikon tidak aktif, dan teks pembantu.
* **Warna Aksen & Status:**
  * Kuning Warning/Overdue/Pending: `#FBBF24` (Emas hangat).
  * Hijau Success/Resolved: `#10B981` (Hijau emerald).
  * Biru Open/Assigned: `#3B82F6` (Biru terang).
  * Orange In Progress: `#F97316` (Oranye menyala).
  * Merah Critical/Reopen: `#EF4444` (Merah tegas).

### 2.2 Geometri & Bentuk (Shapes & Borders)

Karakteristik utama estetika ini adalah kelembutan bentuk sudut yang ekstrem.

* **Sudut Melengkung (Border Radius):**
  * Layar Utama (Device Canvas): `40px` (Kelengkungan fisik bingkai layar).
  * Kartu Utama / Panel Konten: `24px` hingga `32px` (`rounded-3xl` pada Tailwind CSS).
  * Tombol Utama & Bar Pencarian: `9999px` / Bulat Sempurna (`rounded-full`).
  * Gambar, Thumbnail & Kartu Kecil: `16px` hingga `20px` (`rounded-2xl`).
* **Efek Bayangan (Drop Shadows):**
  * Menggunakan bayangan sangat halus, menyebar, dan tidak tajam.
  * Spesifikasi CSS: `box-shadow: 0px 10px 30px rgba(0, 0, 0, 0.03), 0px 2px 8px rgba(0, 0, 0, 0.02);`

### 2.3 Tipografi (Typography)

Menggunakan font sans-serif geometris modern (seperti Plus Jakarta Sans, SF Pro Display, atau Inter).

* **Header Utama / Nama Layar:** `24px - 28px`, Bold/Extra Bold (Contoh: *"Hello, Vanessa"*).
* **Section Heading:** `18px - 20px`, Semi-Bold (Contoh: *"Pilih Kategori Laporan"*).
* **Card Title / Sub-heading:** `14px - 16px`, Semi-Bold/Medium (Contoh: *"Fasilitas Olahraga"*).
* **Body Text:** `12px - 14px`, Regular (Contoh: *"Kerusakan pipa air menyebabkan banjir kecil..."*).
* **Micro Text (Ratings/Dates/Labels):** `10px - 11px`, Medium/Semi-Bold (Contoh: *"Hari ini, 09:41"*).

---

## 3. UX Principles

* **Report Fast (Kurang dari 30 Detik):** Alur lapor mahasiswa dibuat sangat linear. Satu keputusan utama per langkah.
* **Incident First:** Mengelompokkan banyak laporan mentah serupa menjadi satu insiden tunggal di sisi admin untuk menghindari penumpukan data (*low noise*).
* **Clear Next Action:** Setiap peran (Mahasiswa, Staff, Admin) langsung dihadapkan pada satu tombol aksi utama yang tebal dan bulat penuh di layar mereka.
* **Trust Through Visibility:** Mahasiswa dapat melihat proses perbaikan melalui komponen lini masa (*timeline*) visual yang transparan.

---

## 4. Arsitektur Informasi & Navigasi

### 4.1 Single App, Role-Based Floating Navigation Dock

Navigasi bawah menggunakan komponen *Floating Bottom Navigation Dock* berwarna hitam pekat (`#111827`) dengan sudut bulat sempurna (`rounded-full`), memberikan kesan melayang di atas konten utama dengan margin bawah yang cukup longgar.

* **Navigasi Mahasiswa (Student):**
  * Home (Ikon Rumah - Aktif secara default)
  * New Report (Ikon Tambah +)
  * My Incidents (Ikon Dokumen/Laporan)
  * Profile (Ikon User)
* **Navigasi Staf (Staff):**
  * Tugas Saya (Ikon Daftar Kerja)
  * Notifications (Ikon Notifikasi/Lonceng)
  * Profile (Ikon User)
* **Navigasi Admin (Admin):**
  * Overview (Ikon Dashboard/Metrik)
  * Incidents (Ikon List Insiden)
  * Staff Workload (Ikon Grafik Batang)
  * Master Data (Ikon Database/Master Data)
* **Navigasi Super Admin (Super Admin):**
  * Overview (Ikon Dashboard/Metrik)
  * Incidents (Ikon List Insiden)
  * System Config (Ikon Database/Master Data)
  * Users (Ikon Kelompok User)
  * Profile (Ikon User)

---

## 5. Panduan Desain Antarmuka Layar (Screen Interface)

### 5.1 Layar Utama Mahasiswa (Student Home Screen)

Mengadopsi tata letak beranda TripGlide yang bersih dan berfokus pada visual.

* **Header Area:** Teks kiri: *"Halo, [Nama]"* (Bold, Hitam) dengan sub-teks abu-abu *"Selamat datang di CIVIC Campus"*. Sisi kanan: Foto profil sirkular (`rounded-full`) dengan border halus.
* **Pencarian & Pintasan Cepat (Quick Search & Filter):** Bar pencarian `rounded-full` putih dengan tombol filter bulat hitam di ujung kanannya. Di bawahnya terdapat barisan kategori horizontal (misal: *"Gedung Kuliah"*, *"Asrama"*, *"Fasilitas Sosial"*) berupa chip dengan sudut bulat penuh. Chip aktif berwarna hitam pekat dengan teks putih.
* **Tombol Aksi Utama (Hero CTA):** Kartu besar dengan visual foto kampus yang indah. Di atas gambar terdapat tombol love melayang transparan (*glassmorphism*) di pojok kanan atas, serta tombol pill hitam besar *"Laporkan Masalah"* dengan tombol lingkaran putih berpanah kanan (→) di bagian bawahnya.
* **Daftar Laporan Aktif Saya (My Active Reports):** Daftar kartu horizontal yang menonjolkan visual masalah (gambar kerusakan), nama insiden, status berwarna, dan tingkat keparahan (*priority badge*).

### 5.2 Alur Lapor & Cek Duplikat (Report Flow & Duplicate Check)

```text
Lokasi -> Kategori -> Foto Bukti -> Deskripsi -> Cek Duplikat -> Selesai
```

**Duplicate Suggestion UX (Penting):**
Jika sistem mendeteksi adanya laporan serupa di lokasi terdekat, tampilkan dialog berbentuk kartu melengkung (`rounded-3xl`) dengan teks pembuka yang ramah:
> *"Kami menemukan masalah serupa di lokasi ini."*

Tampilkan kartu informasi insiden lama yang sedang ditangani beserta fotonya. Berikan dua opsi aksi utama berupa tombol bulat penuh:
* **Tombol Hitam (Primary):** *"Ini masalah yang sama (Ikut Memantau)"* -> Akan menambahkan hitungan konfirmasi (*confirmation count*).
* **Tombol Putih/Border Abu-abu (Secondary):** *"Buat laporan baru"* -> Melanjutkan proses pelaporan baru.

### 5.3 Layar Kerja Staf (Staff Task List & Detail)

Staf membutuhkan fokus pada tugas harian mereka tanpa elemen dekoratif yang mengalihkan perhatian.

* **Daftar Tugas Harian (Task List):** Kartu tugas menggunakan tata letak ringkas dengan sudut melengkung 24px (`rounded-3xl`). Menampilkan:
  * Indikator prioritas merah/oranye di pojok kiri atas.
  * Kategori masalah (misal: *"Pipa Bocor"*, *"Lampu Mati"*).
  * Thumbnail gambar bukti di sisi kanan.
  * Status chip berlatar belakang warna lembut sesuai status.
* **Detail Tugas & Tombol Sticky (Task Detail):**
  * Setengah layar bagian atas menampilkan foto kerusakan berukuran besar dengan tombol melayang bulat putih untuk kembali (`<`).
  * Setengah bagian bawah dibungkus dalam panel putih besar bersudut atas melengkung tajam (`rounded-t-[32px]`).
  * Di bagian paling bawah layar terdapat *Sticky Action Button* hitam lebar bulat penuh (`rounded-full`) bertuliskan *"Mulai Kerjakan"* atau *"Selesaikan Tugas"* yang melayang anggun di atas konten teks saat digeser (*scrolled*).

### 5.4 Layar Manajemen Admin (Admin Overview & Detail)

Admin membutuhkan efisiensi kerja cepat tanpa harus membuka detail data mentah secara berlebihan.

* **Widget Metrik Analytics:** Menampilkan metrik utama menggunakan kartu putih bersih dengan angka besar dan label abu-abu kecil di bawahnya:
  * *"Kritis / Butuh Penanganan"* (Angka Merah).
  * *"Belum Ditugaskan"* (Angka Biru).
  * *"Terlambat (Overdue)"* (Angka Kuning).
* **Manajemen Insiden Efisien (Quick Assignment Panel):** Admin dapat melakukan penugasan langsung dari kartu daftar insiden tanpa berpindah layar menggunakan tombol drop-down/popover kecil berujung bulat di samping status penugasan.
* **Layar Detail Insiden (Linked Reports & Evidence):**
  * Menampilkan galeri foto horizontal yang berisi semua bukti foto yang diunggah oleh mahasiswa yang berbeda untuk insiden yang sama.
  * Menampilkan jumlah konfirmasi (misal: *"Dikonfirmasi oleh 45 mahasiswa"*) untuk membantu admin menentukan skala prioritas tindakan.

---

## 6. Desain Status & Lencana (Status & Badge UI)

Penggunaan warna dan label yang ramah pengguna serta bebas dari jargon teknis yang membingungkan.

| Kode Status | Label User | Warna Latar Belakang | Warna Teks | Keterangan Visual |
| :--- | :--- | :--- | :--- | :--- |
| **Open** | Menunggu Penanganan | `#EFF6FF` (Biru Lembut) | `#1D4ED8` | Penilaian awal oleh admin |
| **Assigned** | Sudah Ditugaskan | `#EEF2F6` (Abu-abu Lembut) | `#374151` | Staf telah dipilih |
| **In Progress** | Sedang Dikerjakan | `#FFEDD5` (Oranye Lembut) | `#C2410C` | Staf sedang berada di lokasi |
| **Resolved** | Selesai Dikerjakan | `#D1FAE5` (Hijau Lembut) | `#047857` | Menunggu konfirmasi penutupan |
| **Closed** | Ditutup | `#F3F4F6` (Muted Gray) | `#6B7280` | Masalah tuntas teratasi |

---

## 7. Desain Lini Masa & Informasi Terbuka (Timeline UX)

Komponen lini masa (*timeline*) dibangun untuk meningkatkan kepercayaan mahasiswa terhadap kinerja pengelola kampus.

* **Desain Lini Masa Ringkas (Sisi Mahasiswa):** Menggunakan garis vertikal abu-abu tipis dengan titik-titik bulat berwarna sesuai status insiden.
  * `[Titik Hijau]` - Selesai Dikerjakan (Hari ini, 14:20) oleh Staf Budi.
  * `[Titik Oranye]` - Mulai Dikerjakan (Kemarin, 09:30).
  * `[Titik Biru]` - Laporan Diterima & Diverifikasi (23 Mei, 11:00).
* **Desain Lini Masa Audit (Sisi Admin):** Menampilkan riwayat lengkap termasuk penugasan ulang, perubahan prioritas, catatan internal admin, dan pergantian staf penanggung jawab.

---

## 8. Prinsip Aksesibilitas & Keandalan (Accessibility Checklist)

* **Ukuran Target Sentuh (Touch Targets):** Semua tombol interaktif, ikon navigasi bawah, dan tab kontrol segmen memiliki tinggi minimal 48px dengan ruang sentuh yang aman untuk layar sentuh ponsel.
* **Optimistic UI & Loading Indicator:** Tombol submit akan masuk ke status *disabled* dengan *spinner* pemuatan saat mengunggah foto laporan untuk mencegah pengiriman ganda.
* **Komponen Spanduk Kesalahan (Error Banner):** Tidak menggunakan dialog peringatan bawaan peramban web (*browser native alerts*), seluruh pesan kesalahan akan menggunakan komponen spanduk kesalahan internal yang menyatu dengan estetika aplikasi.