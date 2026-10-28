# LAPORAN PENGEMBANGAN APLIKASI
# PATUNGAN — SMART SPLIT-BILL & EXPENSE-SHARING APP

---

**Informasi Proyek:**
- **Nama Aplikasi:** Patungan (Split Bill App)
- **Tagline:** *"Biar adil, nggak ribet."*
- **Versi:** 1.0.0+1
- **Platform:** Cross-Platform (Android, iOS, Web/Microsoft Edge, Windows Desktop)
- **Teknologi Utama:** Flutter SDK, Dart, BLoC Pattern, Clean Architecture, SQLite (`sqflite`, `sqflite_common_ffi`, `sqflite_common_ffi_web`)
- **Tautan Repositori GitHub:** [https://github.com/putrivbri45-create/split_bill_app](https://github.com/putrivbri45-create/split_bill_app)

---

## BAB I: PENDAHULUAN

### 1.1 Latar Belakang
Aktivitas makan bersama, liburan berkelompok, atau iuran tempat tinggal (kost) merupakan hal lumrah dalam kehidupan sehari-hari. Namun, proses pembagian tagihan (*split-bill*) dan penagihan utang seringkali menghadapi beberapa hambatan praktis:
1. **Perhitungan Manual yang Rentan Kesalahan:** Perhitungan pajak restoran (*tax*), biaya layanan (*service charge*), dan diskon seringkali membingungkan bila dihitung manual menggunakan kalkulator biasa.
2. **Transaksi Melingkar yang Tidak Efisien (*Cyclic Debts*):** Ketika beberapa anggota saling membayari kebutuhan yang berbeda, seringkali timbul transaksi melingkar (misal: A berutang ke B, B berutang ke C, dan C berutang ke A), yang merepotkan dan menambah biaya transfer antar-bank.
3. **Ketergantungan Jaringan Internet (Konektivitas):** Banyak aplikasi pencatat keuangan mengharuskan koneksi internet aktif setiap saat, sehingga gagal digunakan di tempat dengan sinyal minim seperti restoran bawah tanah atau destinasi wisata alam.

Untuk menyelesaikan permasalahan tersebut, dikembangkanlah aplikasi **Patungan**, sebuah solusi pencatat dan pembagi tagihan cerdas berbasis **Flutter** dan **SQLite** yang mampu berjalan secara *offline-first*, cepat, adil, serta memiliki algoritma penyederhanaan utang (*Greedy Debt Simplification*).

### 1.2 Rumusan Masalah
1. Bagaimana merancang arsitektur aplikasi mobile yang modular, mudah dirawat (*maintainable*), dan dapat dijalankan secara konsisten lintas platform (Mobile, Desktop, dan Web)?
2. Bagaimana mengimplementasikan basis data lokal SQLite yang memiliki persistensi tinggi tanpa membutuhkan ketergantungan server eksternal berbayar?
3. Bagaimana meminimalkan frekuensi transaksi pelunasan utang dalam kelompok menggunakan algoritma graf serakah (*Greedy Algorithm*)?

### 1.3 Tujuan & Manfaat
- **Tujuan:**
  - Membangun aplikasi *split-bill* yang intuitif dengan panduan desain modern Material 3 bernuansa *Emerald & Mint*.
  - Mengintegrasikan basis data lokal **SQLite** lintas platform (*Android, iOS, Windows, dan Web Assembly/IndexedDB*).
  - Mengimplementasikan algoritma otomatis untuk menghitung pembagian sama rata, nominal kustom, persentase, dan per-item (*itemized*).
  - Menyederhanakan transaksi pelunasan utang hingga lebih dari 50% transaksi menggunakan *Debt Simplifier Engine*.
- **Manfaat:**
  - Mempercepat proses hitung tagihan rombongan hingga di bawah 60 detik.
  - Menghilangkan rasa canggung antar-teman saat menagih atau melunasi utang.
  - Memberikan transparansi mutasi keuangan kelompok yang dapat diakses kapan saja tanpa kuota internet.

---

## BAB II: LANDASAN TEORI

### 2.1 Clean Architecture & BLoC Pattern
Aplikasi Patungan dibangun dengan paradigma **Clean Architecture** yang membagi kode menjadi tiga lapisan utama:
1. **Domain Layer:** Berisi entitas bisnis murni (`User`, `Group`, `Expense`, `Settlement`) dan use cases tanpa ketergantungan pada pustaka eksternal.
2. **Data Layer:** Berisi implementasi repositori dan sumber data (`DatabaseService` SQLite, *Secure Storage*, dan *Shared Preferences*).
3. **Presentation Layer:** Berisi antarmuka pengguna (Widget UI) dan State Management **BLoC (Business Logic Component)** untuk menjamin aliran data searah (*unidirectional data flow*).

### 2.2 Basis Data SQLite Cross-Platform
SQLite dipilih sebagai basis data utama karena sifatnya yang *self-contained, serverless, zero-configuration,* dan *transactional (ACID)*. Untuk mendukung seluruh target kompilasi Flutter, digunakan kombinasi pustaka:
- **`sqflite`:** Driver bawaan untuk native Android dan iOS.
- **`sqflite_common_ffi`:** Driver SQLite berbasis C-FFI untuk lingkungan Desktop Windows dan Unit Test.
- **`sqflite_common_ffi_web` & `web/sqlite3.wasm`:** Driver SQLite berbasis WebAssembly dan IndexedDB untuk browser Microsoft Edge dan Google Chrome.

---

## BAB III: METODOLOGI PENGEMBANGAN SISTEM

### 3.1 Model Pengembangan Perangkat Lunak (SDLC)
Pengembangan aplikasi Patungan menggunakan model **Agile Software Development** dengan pendekatan siklus iteratif dan bertahap:
1. **Analisis Kebutuhan:** Studi observasi masalah penghitungan tagihan bersama dan penyusunan dokumen PRD.
2. **Perancangan Sistem:** Desain arsitektur Clean Architecture, ERD relasional basis data, serta perancangan desain visual Material 3 (Emerald & Mint).
3. **Implementasi & Coding:** Pemrograman logika bisnis dalam bahasa Dart/Flutter, migrasi database SQLite cross-platform, dan integrasi algoritma graf.
4. **Pengujian Otomatis:** Menjalankan Automated Unit & Widget Test untuk menjamin 100% fungsionalitas algoritma dan database.
5. **Deployment & Versioning:** Pelacakan kode dengan Git dan integrasi remote repository di GitHub.

### 3.2 Metodologi Basis Data & Persistensi Lokal
Basis data dirancang dengan skema relasional terstruktur dan integrity constraints:
- `users`: Tabel pengguna dengan enkripsi kata sandi PBKDF2/SHA-256.
- `groups`: Tabel grup aktivitas patungan (makan, liburan, kost).
- `group_members`: Tabel asosiasi pengguna dan grup peran (*admin/member*).
- `expenses`: Tabel induk pengeluaran belanja beserta pajak dan service charge.
- `expense_splits`: Rincian utang per anggota untuk setiap transaksi belanja.
- `settlements`: Catatan pelunasan utang antar-anggota dengan metode pembayaran.

### 3.3 Metodologi Algoritma Inti

#### A. Algoritma Greedy Debt Simplification
1. Menghitung saldo bersih (*Net Balance*) setiap anggota:
   $$\text{Net Balance}_i = \sum \text{Nominal Dibayar}_i - \sum \text{Beban Utang}_i$$
2. Mengelompokkan anggota menjadi dua himpunan terurut:
   - **Debitur ($D$):** Anggota dengan utang ($\text{balance} < -0.01$).
   - **Kreditur ($C$):** Anggota dengan piutang ($\text{balance} > 0.01$).
3. Mengurutkan $D$ dan $C$ secara serakah (*descending*) berdasarkan besaran saldo absolut.
4. Menggunakan pendekatan dua titik (*Two-Pointer Matching*) untuk mencocokkan debitur terbesar dengan kreditur terbesar:
   $$A = \min(|D_j.\text{balance}|, |C_k.\text{balance}|)$$
   Transaksi dicatat dari $D_j$ ke $C_k$ sebesar $A$, saldo keduanya dikurangi, dan pointer digeser ketika saldo mencapai 0.
5. **Efisiensi:** Mengurangi kompleksitas transaksi dari $O(N(N-1))$ menjadi maksimal $(N-1)$ transfer.

#### B. Algoritma Multi-Split & Distribusi Pajak
Perhitungan struk standar restoran dihitung berjenjang:
$$\text{Service Amount} = \text{Subtotal} \times \frac{\text{Service}\%}{100}$$
$$\text{Tax Amount} = (\text{Subtotal} + \text{Service Amount}) \times \frac{\text{Tax}\%}{100}$$
$$\text{Grand Total} = \text{Subtotal} + \text{Service Amount} + \text{Tax Amount}$$

Faktor pengali proporsional:
$$R = \frac{\text{Grand Total}}{\text{Subtotal}}$$

Pembagian sama rata menggunakan *Largest Remainder Allocation* (metode Hare-Niemeyer) untuk menjamin total pembagian bernilai bulat rupiah tanpa ada sen yang hilang.

---

## BAB IV: IMPLEMENTASI FITUR & MODUL

Aplikasi Patungan mengimplementasikan **12 Modul Layar Fungsional**:

| No | Modul Layar | Fungsi Utama |
|:--:|:---|:---|
| 1 | **Splash Screen** | Animasi brand breathing emerald, validasi sesi login otomatis, inisialisasi SQLite. |
| 2 | **Onboarding Screen** | Carousel 3 langkah edukasi interaktif dengan simulasi split bill. |
| 3 | **Authentication** | Formulir Masuk & Daftar, enkripsi PBKDF2, biometrik sidik jari, akun demo. |
| 4 | **Home / Dashboard** | Kartu saldo Bento (*Kamu harus bayar* vs *Kamu harus terima*), aksi cepat buat grup. |
| 5 | **Create Group** | Pembuatan grup baru dengan pemilihan kategori (Makanan, Liburan, Kost, Kantor). |
| 6 | **Group Detail** | Statistik pengeluaran grup, tab transaksi kronologis, saldo per anggota. |
| 7 | **Add Expense** | Input pengeluaran 4 mode (Sama Rata, Persentase, Nominal, Itemized) + pajak/tips. |
| 8 | **Split Summary** | Visualisasi graf penyederhanaan utang (*Debt Simplifier*), modal bayar QRIS, share WhatsApp. |
| 9 | **Transaction History** | Buku besar riwayat transaksi pengeluaran dan pelunasan dengan filter kategori/tanggal. |
| 10 | **User Profile** | Profil pengguna, rekening bank/e-wallet tertaut (BCA, Mandiri, GoPay, OVO). |
| 11 | **Notifications** | Notifikasi transaksi baru, konfirmasi pembayaran, dan pengingat pelunasan. |
| 12 | **Settings** | Pengaturan tema (Terang / Gelap), preferensi bahasa, clear cache, logout. |

---

## BAB V: PENGUJIAN SISTEM & VALIDASI

Pengujian dilakukan menggunakan rangkaian **Flutter Test** otomatis (White-Box & Black-Box):
- **17/17 Test Cases Lulus 100%:**
  - `BalanceCalculator Tests` (Kalkulasi saldo bersih dari pengeluaran & pelunasan).
  - `DebtSimplifier Tests` (3 skenario: 3 pihak sama rata, 4 pihak utang melingkar, saldo nol saat lunas).
  - `SplitCalculator Tests` (5 kasus: equal, exact, percentage, itemized, penny rounding).
  - `DatabaseService SQLite Tests` (Inisialisasi tabel SQLite, auto-seeding, parameterized binding).
  - `Widget Tests` & `Screen Tests` (Render form, navigasi halaman, respons tombol).

---

## BAB VI: KESIMPULAN & SARAN

### 6.1 Kesimpulan
1. Aplikasi **Patungan** berhasil dibangun secara utuh berbasis Flutter dengan Clean Architecture dan BLoC pattern.
2. Basis data aplikasi telah berhasil dimigrasikan ke **SQLite cross-platform** sehingga beroperasi optimal secara *offline-first* di Mobile, Desktop, dan Web browser.
3. Algoritma *Greedy Debt Simplifier* terbukti mereduksi transaksi transfer antar-anggota menjadi bentuk paling ringkas tanpa selisih desimal.
4. Repositori kode, skema SQL, dataset, dan berkas database telah terunggah di GitHub.

### 6.2 Saran Pengembangan Lanjutan
1. Integrasi Optical Character Recognition (OCR) kamera ponsel untuk scan struk otomatis.
2. Sinkronisasi P2P via Wi-Fi lokal / Bluetooth antar-ponsel tanpa internet.
3. Deep-linking pembayaran langsung ke aplikasi mobile banking (BCA, Livin', GoPay).
