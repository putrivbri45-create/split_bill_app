// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Map<String, String> _loadEnv() {
  final file = File('.env');
  if (!file.existsSync()) {
    print('ERROR: .env not found.');
    exit(1);
  }
  final env = <String, String>{};
  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#') || !line.contains('=')) continue;
    final idx = line.indexOf('=');
    env[line.substring(0, idx).trim()] = line.substring(idx + 1).trim();
  }
  return env;
}

void main() async {
  final env = _loadEnv();
  print('Connecting to Neon PostgreSQL for database: ${env['DB_NAME']}...');

  final host = env['DB_HOST'] ?? '';
  final username = env['DB_USER'] ?? '';
  final password = env['DB_PASSWORD'] ?? '';
  final database = env['DB_NAME'] ?? 'neondb';

  if (host.isEmpty || username.isEmpty || password.isEmpty) {
    print('ERROR: Missing DB_HOST, DB_USER, or DB_PASSWORD in .env');
    exit(1);
  }

  final url = Uri.parse('https://$host/sql');
  final connectionString =
      'postgresql://$username:$password@$host/$database?sslmode=require';
  final client = http.Client();

  final statements = [
    '''CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(100) PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        full_name VARCHAR(150) NOT NULL,
        phone_number VARCHAR(30),
        avatar_url TEXT,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );''',
    '''CREATE TABLE IF NOT EXISTS groups (
        id VARCHAR(100) PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
        category VARCHAR(50) DEFAULT 'General',
        icon_name VARCHAR(50) DEFAULT 'group',
        created_by VARCHAR(100),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        description TEXT
    );''',
    '''CREATE TABLE IF NOT EXISTS group_members (
        id VARCHAR(100) PRIMARY KEY,
        group_id VARCHAR(100) REFERENCES groups(id) ON DELETE CASCADE,
        user_id VARCHAR(100),
        role VARCHAR(20) DEFAULT 'member',
        joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        display_name VARCHAR(150),
        phone_number VARCHAR(30),
        UNIQUE(group_id, user_id)
    );''',
    '''CREATE TABLE IF NOT EXISTS expenses (
        id VARCHAR(100) PRIMARY KEY,
        group_id VARCHAR(100) REFERENCES groups(id) ON DELETE CASCADE,
        payer_id VARCHAR(100),
        title VARCHAR(200) NOT NULL,
        total_amount NUMERIC(15, 2) NOT NULL,
        split_type VARCHAR(30) DEFAULT 'EQUAL',
        tax_amount NUMERIC(15, 2) DEFAULT 0.00,
        service_charge NUMERIC(15, 2) DEFAULT 0.00,
        bill_image_url TEXT,
        expense_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        category VARCHAR(50),
        note TEXT
    );''',
    '''CREATE TABLE IF NOT EXISTS expense_splits (
        id VARCHAR(100) PRIMARY KEY,
        expense_id VARCHAR(100) REFERENCES expenses(id) ON DELETE CASCADE,
        user_id VARCHAR(100),
        amount_owed NUMERIC(15, 2) NOT NULL,
        is_settled BOOLEAN DEFAULT FALSE,
        settled_at TIMESTAMP WITH TIME ZONE
    );''',
    '''CREATE TABLE IF NOT EXISTS settlements (
        id VARCHAR(100) PRIMARY KEY,
        group_id VARCHAR(100) REFERENCES groups(id) ON DELETE CASCADE,
        debtor_id VARCHAR(100),
        creditor_id VARCHAR(100),
        amount NUMERIC(15, 2) NOT NULL,
        proof_image_url TEXT,
        status VARCHAR(30) DEFAULT 'COMPLETED',
        settled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        method VARCHAR(50)
    );''',
    'CREATE INDEX IF NOT EXISTS idx_expenses_group ON expenses(group_id);',
    'CREATE INDEX IF NOT EXISTS idx_splits_expense ON expense_splits(expense_id);',
    'CREATE INDEX IF NOT EXISTS idx_settlements_group ON settlements(group_id);',
    'CREATE INDEX IF NOT EXISTS idx_members_group ON group_members(group_id);',

    // Seed default users
    '''INSERT INTO users (id, email, full_name, phone_number, avatar_url, password_hash)
       VALUES 
       ('user-putri-01', 'putrivbri@splitbill.id', 'putrivbri', '081234567890', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash'),
       ('user-ani-02', 'ani@splitbill.id', 'Ani', '0812-9988-7766', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash'),
       ('user-budi-03', 'budi@splitbill.id', 'Budi', '0813-1122-3344', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash'),
       ('user-citra-04', 'citra@splitbill.id', 'Citra', '0815-5566-7788', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash')
       ON CONFLICT (id) DO NOTHING;''',

    // Seed default groups
    '''INSERT INTO groups (id, name, category, icon_name, created_by, description)
       VALUES 
       ('group-makan-malam-reuni', 'Makan Malam Reuni', 'Makanan', 'restaurant', 'user-putri-01', 'Split bill makan bersama setelah reuni angkatan.'),
       ('group-liburan-jogja', 'Liburan Jogja', 'Liburan', 'flight', 'user-putri-01', 'Trip akhir pekan ke Malioboro dan pantai Selatan.'),
       ('group-kost-bulanan', 'Kost Bulanan & Wifi', 'Rumah Tangga', 'home', 'user-citra-04', 'Split bill iuran wifi indihome & air galon bulanan kost.')
       ON CONFLICT (id) DO NOTHING;''',

    // Seed group members
    '''INSERT INTO group_members (id, group_id, user_id, role, display_name, phone_number)
       VALUES 
       ('mem-1', 'group-makan-malam-reuni', 'user-ani-02', 'admin', 'Ani', '0812-9988-7766'),
       ('mem-2', 'group-makan-malam-reuni', 'user-budi-03', 'member', 'Budi', '0813-1122-3344'),
       ('mem-3', 'group-makan-malam-reuni', 'user-citra-04', 'member', 'Citra', '0815-5566-7788'),
       ('mem-4', 'group-makan-malam-reuni', 'user-putri-01', 'member', 'Putri (Anda)', '0812-3456-7890'),
       ('mem-j1', 'group-liburan-jogja', 'user-putri-01', 'admin', 'Putri (Anda)', '0812-3456-7890'),
       ('mem-j2', 'group-liburan-jogja', 'user-budi-03', 'member', 'Budi', '0813-1122-3344'),
       ('mem-j3', 'group-liburan-jogja', 'user-citra-04', 'member', 'Citra', '0815-5566-7788'),
       ('mem-k1', 'group-kost-bulanan', 'user-putri-01', 'member', 'Putri (Anda)', '0812-3456-7890'),
       ('mem-k2', 'group-kost-bulanan', 'user-citra-04', 'admin', 'Citra', '0815-5566-7788')
       ON CONFLICT (id) DO NOTHING;''',

    // Seed expenses
    '''INSERT INTO expenses (id, group_id, payer_id, title, total_amount, split_type, category, note)
       VALUES 
       ('exp-1', 'group-makan-malam-reuni', 'user-ani-02', 'Makan di Restoran', 200000.00, 'EQUAL', 'Makanan & Minuman', 'Makan malam di restoran Seafood.'),
       ('exp-2', 'group-makan-malam-reuni', 'user-budi-03', 'Minuman & Dessert', 120000.00, 'EQUAL', 'Makanan & Minuman', 'Minuman manis.'),
       ('exp-3', 'group-makan-malam-reuni', 'user-putri-01', 'Biaya Parkir & Tips', 30000.00, 'EQUAL', 'Transport', 'Parkir.'),
       ('exp-4', 'group-makan-malam-reuni', 'user-citra-04', 'Camilan Tambahan', 50000.00, 'EQUAL', 'Makanan & Minuman', 'Camilan.'),
       ('exp-5', 'group-liburan-jogja', 'user-putri-01', 'Tiket Kereta PP', 300000.00, 'EQUAL', 'Transport', 'Tiket KA.'),
       ('exp-6', 'group-liburan-jogja', 'user-budi-03', 'Bensin & Tol', 105000.00, 'EQUAL', 'Transport', 'Bensin & Tol')
       ON CONFLICT (id) DO NOTHING;''',

    // Seed expense splits
    '''INSERT INTO expense_splits (id, expense_id, user_id, amount_owed, is_settled)
       VALUES 
       ('sp-1', 'exp-1', 'user-ani-02', 50000.00, FALSE),
       ('sp-2', 'exp-1', 'user-budi-03', 50000.00, FALSE),
       ('sp-3', 'exp-1', 'user-citra-04', 50000.00, FALSE),
       ('sp-4', 'exp-1', 'user-putri-01', 50000.00, FALSE),
       ('sp-5', 'exp-2', 'user-ani-02', 30000.00, FALSE),
       ('sp-6', 'exp-2', 'user-budi-03', 30000.00, FALSE),
       ('sp-7', 'exp-2', 'user-citra-04', 30000.00, FALSE),
       ('sp-8', 'exp-2', 'user-putri-01', 30000.00, FALSE),
       ('sp-9', 'exp-3', 'user-ani-02', 7500.00, FALSE),
       ('sp-10', 'exp-3', 'user-budi-03', 7500.00, FALSE),
       ('sp-11', 'exp-3', 'user-citra-04', 7500.00, FALSE),
       ('sp-12', 'exp-3', 'user-putri-01', 7500.00, FALSE),
       ('sp-13', 'exp-4', 'user-ani-02', 16666.60, FALSE),
       ('sp-14', 'exp-4', 'user-citra-04', 16666.70, FALSE),
       ('sp-15', 'exp-4', 'user-putri-01', 16666.70, FALSE),
       ('sp-16', 'exp-5', 'user-putri-01', 100000.00, FALSE),
       ('sp-17', 'exp-5', 'user-budi-03', 100000.00, FALSE),
       ('sp-18', 'exp-5', 'user-citra-04', 100000.00, FALSE),
       ('sp-19', 'exp-6', 'user-putri-01', 35000.00, FALSE),
       ('sp-20', 'exp-6', 'user-budi-03', 35000.00, FALSE),
       ('sp-21', 'exp-6', 'user-citra-04', 35000.00, FALSE)
       ON CONFLICT (id) DO NOTHING;''',

    // Seed settlements
    '''INSERT INTO settlements (id, group_id, debtor_id, creditor_id, amount, status, method)
       VALUES 
       ('stl-1', 'group-makan-malam-reuni', 'user-budi-03', 'user-ani-02', 50000.00, 'PENDING', 'Transfer'),
       ('stl-2', 'group-makan-malam-reuni', 'user-citra-04', 'user-ani-02', 75000.00, 'PENDING', 'Transfer'),
       ('stl-3', 'group-makan-malam-reuni', 'user-putri-01', 'user-budi-03', 25000.00, 'COMPLETED', 'QRIS / Transfer BCA'),
       ('stl-4', 'group-liburan-jogja', 'user-budi-03', 'user-putri-01', 75000.00, 'COMPLETED', 'QRIS Gopay')
       ON CONFLICT (id) DO NOTHING;''',
  ];

  try {
    print('Migrating database schema & seeding data...');
    for (int i = 0; i < statements.length; i++) {
      final resp = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Neon-Connection-String': connectionString,
        },
        body: jsonEncode({'query': statements[i]}),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('Executed statement #${i + 1}');
      } else {
        print('Error on statement #${i + 1} (${resp.statusCode}): ${resp.body}');
      }
    }

    // Verify row counts
    final tables = ['users', 'groups', 'group_members', 'expenses', 'expense_splits', 'settlements'];
    print('\nVerifying record counts:');
    for (final tbl in tables) {
      final res = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Neon-Connection-String': connectionString,
          'Neon-Array-Mode': 'true',
        },
        body: jsonEncode({'query': 'SELECT COUNT(*) FROM $tbl;'}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final count = (data['rows'] as List).first[0];
        print(' - $tbl: $count rows');
      }
    }

    client.close();
    print('\nDatabase setup and seeding completed successfully!');
  } catch (e, stack) {
    print('Failed to setup database: $e');
    print(stack);
    exit(1);
  }
}
