# Product Requirements Document (PRD)
## Project: Patungan (Smart Split-Bill & Expense-Sharing App)

---

### 1. Executive Summary
**Patungan** is a modern, high-performance, and secure mobile application built with Flutter, designed to solve the friction of tracking, calculating, and settling shared expenses among friends, roommates, family, and colleagues. With tagline **"Biar adil, nggak ribet."**, Patungan delivers a frictionless split-bill experience with fair calculations, debt minimization, QRIS instant payments, and transparent ledger tracking.

---

### 2. Objectives & Success Metrics
- **Seamless Split**: Reduce the time required to calculate and settle shared bills to under 60 seconds.
- **Minimized Transactions**: Reduce pairwise payments by over 50% using an optimal greedy debt simplification graph algorithm.
- **Flawless UI/UX**: Provide an ultra-sleek, modern design system matching the `stitch_patungan_split_bill_app_ui` design specification (Plus Jakarta Sans, Emerald/Mint tones, clear typography, micro-interactions).
- **Security & Reliability**: End-to-end TLS/SSL connections to Neon PostgreSQL, Argon2/BCrypt encrypted passwords, secure biometric authentication (`local_auth`), and protected secrets storage (`flutter_secure_storage`).

---

### 3. User Personas
1. **The Trip Organizer (Reza, 24)**: Frequently organizes weekend trips and cafe hangouts with 4-8 friends. Spends too much time manually calculating Excel sheets and chasing friends for bank transfers.
2. **The Roommate (Citra, 21)**: Shares a boarding house (kost) with 3 others; needs a painless way to split monthly WiFi, electricity, water, and cleaning supplies.
3. **The Casual Diner (Budi, 26)**: Hates awkward payment moments after dining out; wants to scan QRIS immediately or see exactly what he owes without guessing tax and service charges.

---

### 4. 12-Screen Functional Breakdown

#### 01. Splash Screen
- **Visuals**: Animated Patungan emerald logo with subtle pulse, version string (`v1.0.0`), clean brand tagline.
- **Logic**: Inspects local secure storage for existing user authentication session; routes to **Dashboard** if valid, otherwise routes to **Onboarding** or **Login**.

#### 02. Onboarding Screen
- **Visuals**: 3-step interactive carousel featuring real-world split bill illustrations, live financial pill badges (`Total Tagihan`, `Alokasi Anggota`, `Lunas ✓`), dynamic indicator dots, and preview cards.
- **Actions**: "Mulai Sekarang" (Primary CTA) and "Lewati" (Skip CTA) leading to Authentication.

#### 03. Authentication (Login / Register)
- **Features**: Segmented toggle between **Masuk** (Login) and **Daftar** (Register).
- **Form Fields**: Full name, WhatsApp/phone number, email/identifier, password with visibility toggle, and password confirmation.
- **Extras**: "Ingat saya" checkbox, forgot password link, Biometric fingerprint prompt trigger, and Google/Apple social sign-in buttons.
- **Security**: Parameterized queries, password encryption, secure session token handling.

#### 04. Home / Dashboard
- **Header**: User avatar, greeting ("Halo, [User] 👋"), dynamic subtitle, notification bell with unread counter.
- **Balance Cards**:
  - *Kamu harus bayar (Debts)*: Highlighted in soft red/coral container with total unpaid bills and count.
  - *Kamu harus terima (Credits)*: Highlighted in emerald container with total receivables and count.
- **Quick Action Buttons**: `+ Buat Grup Baru` and `Catat Pengeluaran Cepat`.
- **Active Groups**: Card list displaying group icon, member count, expense count, and personalized settlement state badge.
- **Bottom Navigation**: Persistent navigation bar (Home, Grup, Riwayat, Profil).

#### 05. Create New Group
- **Inputs**: Group name, Category chips (`Liburan`, `Makanan`, `Rumah Tangga`, `Kantor`), Icon/Emoji selector.
- **Members**: Dynamic member selector with search bar, phone contact invite simulation, and selected member chips.
- **Action**: "Simpan Grup" validating inputs and registering group in Neon PostgreSQL.

#### 06. Group Detail
- **Header**: Group category icon, title, member count, creation timestamp.
- **Summary**: Total group spending banner, settled vs pending ratio badge.
- **Tabs**:
  - *Pengeluaran (Expenses)*: Chronological list of recorded expenses, payer avatar, date, amount.
  - *Anggota (Members)*: List of participants with net balance indicator (Positive/Negative/Settled).
- **Floating / Sticky Action**: `+ Tambah Pengeluaran` and `Selesaikan Pembayaran`.

#### 07. Add Expense
- **Inputs**:
  - Total Bill input with IDR currency formatting and quick increment pills (`+10k`, `+50k`, `+100k`, `Pas`).
  - Expense title (e.g. "Makan di Restoran").
  - Category selector (`Makanan & Minuman`, `Transport`, `Hiburan`, `Belanja`, etc.).
  - Payer selector dropdown (who paid the bill).
  - Multi-split methods: **Sama Rata (Equal)**, **Nominal Kustom (Exact)**, **Persentase (%)**, **Per-Item**.
  - Tax & Service charge toggles.
  - Optional note and receipt photo attachment (`+ Lampirkan Foto Struk`).
- **Footer CTA**: "Simpan Pengeluaran".

#### 08. Split Summary & Debt Simplification
- **Visuals**: Total group bill banner with simplified transaction counter ("Disederhanakan menjadi N transaksi termudah").
- **Settlement Cards**: Flow cards showing `Payer -> Recipient`, amount owed, payment status (`Belum dibayar` vs `Sudah dibayar`), and payment method proof.
- **Actions**:
  - "Kirim Pengingat" (WhatsApp/Push reminder trigger).
  - "Bayar via QRIS" opens interactive QRIS code modal with amount and merchant details.
  - "Bagikan Rincian (PDF / WA)".

#### 09. Transaction History
- **Filters**: Period tabs (`Semua`, `Harian`, `Mingguan`, `Bulanan`), Status filters (`Lunas`, `Belum Lunas`).
- **Ledger Cards**: Timestamped logs of bills created, payments sent, and settlements confirmed.
- **Actions**: Export transactions to CSV / PDF summary report.

#### 10. User Profile
- **Details**: Profile photo, full name, email, phone number, member since date.
- **Payment Methods**: Linked bank accounts (BCA, Mandiri, BRI) and e-Wallets (GoPay, OVO, Dana) with QRIS display.
- **Quick Preferences**: Currency format preference (IDR, USD, SGD), biometric security toggle.

#### 11. Notifications
- **Activity Feed**: Real-time notifications for newly added expenses, reminder pings from friends, and settlement confirmations.
- **Filter**: All, Unread, Mentions.
- **Actions**: "Tandai sudah dibaca" (Mark all as read).

#### 12. Settings
- **Preferences**:
  - Security: PIN change, Biometric fingerprint/Face ID toggle.
  - Appearance: Light mode / Dark mode selector.
  - Language: Bahasa Indonesia / English.
- **Data & Support**: Clear local cache, Terms of Service, Privacy Policy, Help Center.
- **Account**: Logout action with confirmation dialog.

---

### 5. Technical Requirements & Non-Functional Specifications
- **Target OS**: Android 8.0+, iOS 14.0+, Web (Modern browsers).
- **Latency**: App startup < 1.5s; Local navigation < 16ms (60fps); DB query response < 600ms with pooling.
- **Security**: No plaintext credentials in storage; prepared SQL statements; TLS 1.3 enforced.
- **Accessibility**: High-contrast text compliance, touch target minimum of 48x48 dp.
