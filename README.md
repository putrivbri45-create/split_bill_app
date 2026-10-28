# 💸 Patungan — Smart Split-Bill & Expense-Sharing App

> *"Biar adil, nggak ribet."*

**Patungan** adalah aplikasi modern pencatat pengeluaran kelompok dan pembagi tagihan (*split-bill*) otomatis berbasis **Flutter**, dirancang dengan prinsip **Clean Architecture**, desain visual Material 3 bernuansa Emerald & Mint, serta algoritma optimasi pelunasan utang (*Greedy Debt Simplification*).

---

## 🚀 Cara Menjalankan di Microsoft Edge

Anda dapat menjalankan aplikasi langsung di peramban **Microsoft Edge** menggunakan file script yang telah disediakan:

### Cara 1: Menggunakan `run.bat` (Paling Cepat)
1. **Klik 2x** file `run.bat` di File Explorer, atau
2. Jalankan perintah berikut di PowerShell / Command Prompt:
   ```cmd
   .\run.bat
   ```

### Cara 2: Menggunakan Terminal Manual
```bash
# 1. Unduh dependensi
flutter pub get

# 2. Jalankan pada target Edge
flutter run -d edge
```

> **Catatan Interaksi Terminal saat Aplikasi Berjalan:**
> - Tekan `r` pada terminal untuk **Hot Reload** (memperbarui perubahan kode secara instan).
> - Tekan `R` pada terminal untuk **Hot Restart**.
> - Tekan `q` pada terminal untuk menghentikan aplikasi.

---

## 👥 Akun Dummy / Demo Credentials

Aplikasi menyediakan akun dummy siap pakai untuk memudahkan pengujian berbagai peran (Host pembuat grup, anggota dengan utang, maupun anggota yang harus menerima pelunasan):

| No | Nama Pengguna | Peran / Skenario | Email | No. WhatsApp | Password |
|:--:|:---|:---|:---|:---|:---|
| 1 | **Putri** *(Default)* | **Host & Pembuat Grup**<br>Membayar tagihan utama, memiliki piutang | `putri@patungan.id` | `081234567890` | `password123` |
| 2 | **Budi Santoso** | **Anggota (Debtor)**<br>Memiliki tanggungan tagihan makan & liburan | `budi@patungan.id` | `081298765432` | `password123` |
| 3 | **Citra Lestari** | **Anggota (Roommate)**<br>Ikut patungan kost bulanan & makanan | `citra@patungan.id` | `081311223344` | `password123` |
| 4 | **Dimas Pratama** | **Anggota (Settled)**<br>Sudah melunasi tagihan melalui QRIS | `dimas@patungan.id` | `081355667788` | `password123` |

---

## ✨ 12 Layar Fungsional Lengkap

1. **01. Splash Screen**: Animasi brand Patungan dengan validasi sesi login otomatis.
2. **02. Onboarding Screen**: 3 kartu panduan interaktif dengan live badge tagihan dan simulasi split bill.
3. **03. Authentication (Login / Register)**: Toggle login & daftar, verifikasi identitas, dan opsi login sosial (Google & Apple).
4. **04. Home / Dashboard**: Kartu saldo Bento (`Kamu harus bayar` vs `Kamu harus terima`), aksi cepat, dan daftar grup aktif.
5. **05. Create New Group**: Pembuatan grup, kategori (Liburan, Makanan, Rumah Tangga, Kantor), dan pemilihan anggota interaktif.
6. **06. Group Detail**: Rangkuman pengeluaran grup, tab pengeluaran kronologis, saldo per anggota, dan navigasi aksi.
7. **07. Add Expense**: Form multi-split canggih (Sama Rata, Nominal Kustom, Persentase, Itemized), quick nominal increment pills (`+10k`, `+50k`, `+100k`), pajak & service charge.
8. **08. Split Summary & Debt Simplification**: Visualisasi greedy graph algorithm yang memangkas jumlah transaksi antar-anggota hingga seminimal mungkin, modal bayar instan QRIS, dan tombol bagikan WhatsApp dinamis.
9. **09. Transaction History**: Riwayat transaksi filterable (Semua, Grup, Tanggal) dengan ekspor laporan mutasi format CSV / PDF.
10. **10. User Profile**: Profil pengguna, identitas, kartu metode pembayaran tertaut (BCA, Mandiri, GoPay, OVO, QRIS), dan preferensi.
11. **11. Notifications Feed**: Notifikasi aktivitas pengeluaran baru, permintaan pembayaran teman, dan konfirmasi pelunasan tagihan.
12. **12. Settings & Security**: Pengaturan tema (Terang / Gelap), keamanan PIN & Biometrik, bahasa, bersihkan cache, dan keluar akun.

---

## 🧠 Algoritma Inti

### 1. Greedy Debt Simplification (`DebtSimplifier`)
Menghilangkan transfer melingkar antar anggota (misal: A bayar B, B bayar C, C bayar A) menjadi transaksi pembayaran seminimal mungkin:
$$\text{Net Balance}_i = \sum \text{Paid}_i - \sum \text{Owed}_i$$
Algoritma mencocokkan debitur terbesar dengan kreditur terbesar secara serakah (*greedy*), memangkas transaksi transfer lebih dari 50%.

### 2. Multi-Split Calculator (`SplitCalculator`)
- **Equal**: Pembagian rata tanpa kehilangan selisih desimal (*penny rounding preservation*).
- **Exact**: Nominal kustom per orang dengan validasi kecocokan total.
- **Percentage**: Alokasi persentase bebas dengan kalkulasi proporsional.
- **Per-Item**: Penugasan item spesifik beserta distribusi pajak & biaya layanan otomatis.

---

## 🧪 Pengujian Otomatis

Seluruh logika bisnis dan komponen widget telah divalidasi dengan unit & widget test:

```bash
flutter test
```
*Hasil: **17/17 tests lulus (100% Passed)**.*

```bash
flutter analyze
```
*Hasil: **No issues found!***
