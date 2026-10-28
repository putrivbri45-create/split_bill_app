-- ====================================================================
-- PATUNGAN - SQLite Database Schema & Complete Seed Dataset
-- File: schema_and_dataset.sql
-- Database: SQLite 3.x
-- Description: Skema tabel dan data awal untuk aplikasi split-bill Patungan
-- ====================================================================

PRAGMA foreign_keys = ON;

-- --------------------------------------------------------------------
-- 1. TABEL: users (Pengguna Aplikasi)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    avatar_url TEXT,
    password_hash TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

-- --------------------------------------------------------------------
-- 2. TABEL: groups (Grup Patungan / Pengeluaran Bersama)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS groups (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT DEFAULT 'General',
    icon_name TEXT DEFAULT 'group',
    created_by TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    description TEXT
);

-- --------------------------------------------------------------------
-- 3. TABEL: group_members (Anggota dalam Setiap Grup)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS group_members (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    role TEXT DEFAULT 'member',
    joined_at TEXT DEFAULT (datetime('now')),
    display_name TEXT,
    phone_number TEXT,
    UNIQUE(group_id, user_id),
    FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 4. TABEL: expenses (Pengeluaran / Tagihan Tagihan Pembelian)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS expenses (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
    payer_id TEXT,
    title TEXT NOT NULL,
    total_amount REAL NOT NULL,
    split_type TEXT DEFAULT 'EQUAL',
    tax_amount REAL DEFAULT 0.00,
    service_charge REAL DEFAULT 0.00,
    bill_image_url TEXT,
    expense_date TEXT DEFAULT (datetime('now')),
    created_at TEXT DEFAULT (datetime('now')),
    category TEXT,
    note TEXT,
    FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 5. TABEL: expense_splits (Rincian Beban Tagihan per Anggota)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS expense_splits (
    id TEXT PRIMARY KEY,
    expense_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    amount_owed REAL NOT NULL,
    is_settled INTEGER DEFAULT 0,
    settled_at TEXT,
    FOREIGN KEY(expense_id) REFERENCES expenses(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 6. TABEL: settlements (Riwayat Pelunasan Utang Antar-Anggota)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS settlements (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
    debtor_id TEXT NOT NULL,
    creditor_id TEXT NOT NULL,
    amount REAL NOT NULL,
    proof_image_url TEXT,
    status TEXT DEFAULT 'COMPLETED',
    settled_at TEXT DEFAULT (datetime('now')),
    method TEXT,
    FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- INDEKS PENCARIAN (Indexes)
-- --------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_expenses_group ON expenses(group_id);
CREATE INDEX IF NOT EXISTS idx_splits_expense ON expense_splits(expense_id);
CREATE INDEX IF NOT EXISTS idx_settlements_group ON settlements(group_id);
CREATE INDEX IF NOT EXISTS idx_members_group ON group_members(group_id);

-- ====================================================================
-- SEED DATASET LENGKAP
-- ====================================================================

-- 1. Data Pengguna (Users)
INSERT OR IGNORE INTO users (id, email, full_name, phone_number, avatar_url, password_hash, created_at, updated_at) VALUES 
('user-putri-01', 'putrivbri@splitbill.id', 'putrivbri', '081234567890', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', 'pbkdf2$12000$default$hash', '2026-10-28 08:00:00', '2026-10-28 08:00:00'),
('user-ani-02', 'ani@splitbill.id', 'Ani', '0812-9988-7766', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80', 'pbkdf2$12000$default$hash', '2026-10-28 08:00:00', '2026-10-28 08:00:00'),
('user-budi-03', 'budi@splitbill.id', 'Budi', '0813-1122-3344', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', 'pbkdf2$12000$default$hash', '2026-10-28 08:00:00', '2026-10-28 08:00:00'),
('user-citra-04', 'citra@splitbill.id', 'Citra', '0815-5566-7788', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80', 'pbkdf2$12000$default$hash', '2026-10-28 08:00:00', '2026-10-28 08:00:00');

-- 2. Data Grup (Groups)
INSERT OR IGNORE INTO groups (id, name, category, icon_name, created_by, created_at, description) VALUES 
('group-makan-malam-reuni', 'Makan Malam Reuni', 'Makanan', 'restaurant', 'user-putri-01', '2026-10-28 17:00:00', 'Split bill makan bersama setelah reuni angkatan.'),
('group-liburan-jogja', 'Liburan Jogja', 'Liburan', 'flight', 'user-putri-01', '2026-10-26 10:00:00', 'Trip akhir pekan ke Malioboro dan pantai Selatan.'),
('group-kost-bulanan', 'Kost Bulanan & Wifi', 'Rumah Tangga', 'home', 'user-citra-04', '2026-10-13 12:00:00', 'Split bill iuran wifi indihome & air galon bulanan kost.');

-- 3. Data Anggota Grup (Group Members)
INSERT OR IGNORE INTO group_members (id, group_id, user_id, role, display_name, phone_number, joined_at) VALUES 
('mem-1', 'group-makan-malam-reuni', 'user-ani-02', 'admin', 'Ani', '0812-9988-7766', '2026-10-28 17:00:00'),
('mem-2', 'group-makan-malam-reuni', 'user-budi-03', 'member', 'Budi', '0813-1122-3344', '2026-10-28 17:00:00'),
('mem-3', 'group-makan-malam-reuni', 'user-citra-04', 'member', 'Citra', '0815-5566-7788', '2026-10-28 17:00:00'),
('mem-4', 'group-makan-malam-reuni', 'user-putri-01', 'member', 'Putri (Anda)', '0812-3456-7890', '2026-10-28 17:00:00'),
('mem-j1', 'group-liburan-jogja', 'user-putri-01', 'admin', 'Putri (Anda)', '0812-3456-7890', '2026-10-26 10:00:00'),
('mem-j2', 'group-liburan-jogja', 'user-budi-03', 'member', 'Budi', '0813-1122-3344', '2026-10-26 10:00:00'),
('mem-j3', 'group-liburan-jogja', 'user-citra-04', 'member', 'Citra', '0815-5566-7788', '2026-10-26 10:00:00'),
('mem-k1', 'group-kost-bulanan', 'user-putri-01', 'member', 'Putri (Anda)', '0812-3456-7890', '2026-10-13 12:00:00'),
('mem-k2', 'group-kost-bulanan', 'user-citra-04', 'admin', 'Citra', '0815-5566-7788', '2026-10-13 12:00:00');

-- 4. Data Pengeluaran (Expenses)
INSERT OR IGNORE INTO expenses (id, group_id, payer_id, title, total_amount, split_type, category, note, expense_date, created_at) VALUES 
('exp-1', 'group-makan-malam-reuni', 'user-ani-02', 'Makan di Restoran', 200000.00, 'EQUAL', 'Makanan & Minuman', 'Makan malam di restoran Seafood.', '2026-10-28 18:00:00', '2026-10-28 18:00:00'),
('exp-2', 'group-makan-malam-reuni', 'user-budi-03', 'Minuman & Dessert', 120000.00, 'EQUAL', 'Makanan & Minuman', 'Minuman manis.', '2026-10-28 18:45:00', '2026-10-28 18:45:00'),
('exp-3', 'group-makan-malam-reuni', 'user-putri-01', 'Biaya Parkir & Tips', 30000.00, 'EQUAL', 'Transport', 'Parkir mobil.', '2026-10-28 19:30:00', '2026-10-28 19:30:00'),
('exp-4', 'group-makan-malam-reuni', 'user-citra-04', 'Camilan Tambahan', 50000.00, 'EQUAL', 'Makanan & Minuman', 'Camilan setelah makan.', '2026-10-28 20:15:00', '2026-10-28 20:15:00'),
('exp-5', 'group-liburan-jogja', 'user-putri-01', 'Tiket Kereta PP', 300000.00, 'EQUAL', 'Transport', 'Tiket Kereta Api Eksekutif PP.', '2026-10-26 11:00:00', '2026-10-26 11:00:00'),
('exp-6', 'group-liburan-jogja', 'user-budi-03', 'Bensin & Tol', 105000.00, 'EQUAL', 'Transport', 'Bensin perjalanan Yogyakarta.', '2026-10-27 15:00:00', '2026-10-27 15:00:00');

-- 5. Data Pembagian Tagihan (Expense Splits)
INSERT OR IGNORE INTO expense_splits (id, expense_id, user_id, amount_owed, is_settled) VALUES 
('sp-1', 'exp-1', 'user-ani-02', 50000.00, 0),
('sp-2', 'exp-1', 'user-budi-03', 50000.00, 0),
('sp-3', 'exp-1', 'user-citra-04', 50000.00, 0),
('sp-4', 'exp-1', 'user-putri-01', 50000.00, 0),
('sp-5', 'exp-2', 'user-ani-02', 30000.00, 0),
('sp-6', 'exp-2', 'user-budi-03', 30000.00, 0),
('sp-7', 'exp-2', 'user-citra-04', 30000.00, 0),
('sp-8', 'exp-2', 'user-putri-01', 30000.00, 0),
('sp-9', 'exp-3', 'user-ani-02', 7500.00, 0),
('sp-10', 'exp-3', 'user-budi-03', 7500.00, 0),
('sp-11', 'exp-3', 'user-citra-04', 7500.00, 0),
('sp-12', 'exp-3', 'user-putri-01', 7500.00, 0),
('sp-13', 'exp-4', 'user-ani-02', 16666.60, 0),
('sp-14', 'exp-4', 'user-citra-04', 16666.70, 0),
('sp-15', 'exp-4', 'user-putri-01', 16666.70, 0),
('sp-16', 'exp-5', 'user-putri-01', 100000.00, 0),
('sp-17', 'exp-5', 'user-budi-03', 100000.00, 0),
('sp-18', 'exp-5', 'user-citra-04', 100000.00, 0),
('sp-19', 'exp-6', 'user-putri-01', 35000.00, 0),
('sp-20', 'exp-6', 'user-budi-03', 35000.00, 0),
('sp-21', 'exp-6', 'user-citra-04', 35000.00, 0);

-- 6. Data Pelunasan Utang (Settlements)
INSERT OR IGNORE INTO settlements (id, group_id, debtor_id, creditor_id, amount, status, method, settled_at) VALUES 
('stl-1', 'group-makan-malam-reuni', 'user-budi-03', 'user-ani-02', 50000.00, 'PENDING', 'Transfer', '2026-10-28 19:00:00'),
('stl-2', 'group-makan-malam-reuni', 'user-citra-04', 'user-ani-02', 75000.00, 'PENDING', 'Transfer', '2026-10-28 19:00:00'),
('stl-3', 'group-makan-malam-reuni', 'user-putri-01', 'user-budi-03', 25000.00, 'COMPLETED', 'QRIS / Transfer BCA', '2026-10-28 20:15:00'),
('stl-4', 'group-liburan-jogja', 'user-budi-03', 'user-putri-01', 75000.00, 'COMPLETED', 'QRIS Gopay', '2026-10-27 18:00:00');

