import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Cross-platform SQLite Database Service for Patungan App.
/// Supports Web (Wasm + IndexedDB), Desktop (Windows, macOS, Linux via FFI),
/// and Mobile (Android, iOS native SQLite).
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  Database? _db;
  Completer<Database>? _initCompleter;

  DatabaseService._();

  /// Always true since SQLite is an embedded local database (no external host needed).
  bool get isConfigured => true;

  /// Ensures database is initialized and tables/seeds exist.
  Future<Database> init() async {
    return database;
  }

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<Database>();
    try {
      final db = await _openAppDatabase();
      _db = db;
      _initCompleter!.complete(db);
      return db;
    } catch (e, st) {
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<Database> _openAppDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (kIsWeb) {
      dbPath = 'split_bill.db';
    } else {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        dbPath = p.join(docsDir.path, 'split_bill.db');
      } catch (_) {
        final defaultDir = await getDatabasesPath();
        dbPath = p.join(defaultDir, 'split_bill.db');
      }
    }

    final db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
          await _seedInitialData(db);
        },
      ),
    );

    // Ensure foreign keys are enabled in SQLite
    try {
      await db.execute('PRAGMA foreign_keys = ON;');
    } catch (_) {}

    // Verify if tables exist (e.g. if database file existed before migration)
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='users';",
    );
    if (tables.isEmpty) {
      await _createTables(db);
      await _seedInitialData(db);
    }

    return db;
  }

  Future<void> _createTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        phone_number TEXT,
        avatar_url TEXT,
        password_hash TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT DEFAULT 'General',
        icon_name TEXT DEFAULT 'group',
        created_by TEXT,
        created_at TEXT,
        description TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS group_members (
        id TEXT PRIMARY KEY,
        group_id TEXT,
        user_id TEXT,
        role TEXT DEFAULT 'member',
        joined_at TEXT,
        display_name TEXT,
        phone_number TEXT,
        UNIQUE(group_id, user_id),
        FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        group_id TEXT,
        payer_id TEXT,
        title TEXT NOT NULL,
        total_amount REAL NOT NULL,
        split_type TEXT DEFAULT 'EQUAL',
        tax_amount REAL DEFAULT 0.00,
        service_charge REAL DEFAULT 0.00,
        bill_image_url TEXT,
        expense_date TEXT,
        created_at TEXT,
        category TEXT,
        note TEXT,
        FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expense_splits (
        id TEXT PRIMARY KEY,
        expense_id TEXT,
        user_id TEXT,
        amount_owed REAL NOT NULL,
        is_settled INTEGER DEFAULT 0,
        settled_at TEXT,
        FOREIGN KEY(expense_id) REFERENCES expenses(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settlements (
        id TEXT PRIMARY KEY,
        group_id TEXT,
        debtor_id TEXT,
        creditor_id TEXT,
        amount REAL NOT NULL,
        proof_image_url TEXT,
        status TEXT DEFAULT 'COMPLETED',
        settled_at TEXT,
        method TEXT,
        FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_group ON expenses(group_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_splits_expense ON expense_splits(expense_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_settlements_group ON settlements(group_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_members_group ON group_members(group_id);');
  }

  Future<void> _seedInitialData(DatabaseExecutor db) async {
    final now = DateTime.now().toIso8601String();

    // Default users
    await db.rawInsert('''
      INSERT OR IGNORE INTO users (id, email, full_name, phone_number, avatar_url, password_hash, created_at, updated_at)
      VALUES 
      ('user-putri-01', 'putrivbri@splitbill.id', 'putrivbri', '081234567890', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash', ?, ?),
      ('user-ani-02', 'ani@splitbill.id', 'Ani', '0812-9988-7766', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash', ?, ?),
      ('user-budi-03', 'budi@splitbill.id', 'Budi', '0813-1122-3344', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash', ?, ?),
      ('user-citra-04', 'citra@splitbill.id', 'Citra', '0815-5566-7788', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80', 'pbkdf2\$12000\$default\$hash', ?, ?);
    ''', [now, now, now, now, now, now, now, now]);

    // Default groups
    await db.rawInsert('''
      INSERT OR IGNORE INTO groups (id, name, category, icon_name, created_by, created_at, description)
      VALUES 
      ('group-makan-malam-reuni', 'Makan Malam Reuni', 'Makanan', 'restaurant', 'user-putri-01', ?, 'Split bill makan bersama setelah reuni angkatan.'),
      ('group-liburan-jogja', 'Liburan Jogja', 'Liburan', 'flight', 'user-putri-01', ?, 'Trip akhir pekan ke Malioboro dan pantai Selatan.'),
      ('group-kost-bulanan', 'Kost Bulanan & Wifi', 'Rumah Tangga', 'home', 'user-citra-04', ?, 'Split bill iuran wifi indihome & air galon bulanan kost.');
    ''', [
      DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    ]);

    // Group members
    await db.rawInsert('''
      INSERT OR IGNORE INTO group_members (id, group_id, user_id, role, display_name, phone_number, joined_at)
      VALUES 
      ('mem-1', 'group-makan-malam-reuni', 'user-ani-02', 'admin', 'Ani', '0812-9988-7766', ?),
      ('mem-2', 'group-makan-malam-reuni', 'user-budi-03', 'member', 'Budi', '0813-1122-3344', ?),
      ('mem-3', 'group-makan-malam-reuni', 'user-citra-04', 'member', 'Citra', '0815-5566-7788', ?),
      ('mem-4', 'group-makan-malam-reuni', 'user-putri-01', 'member', 'Putri (Anda)', '0812-3456-7890', ?),
      ('mem-j1', 'group-liburan-jogja', 'user-putri-01', 'admin', 'Putri (Anda)', '0812-3456-7890', ?),
      ('mem-j2', 'group-liburan-jogja', 'user-budi-03', 'member', 'Budi', '0813-1122-3344', ?),
      ('mem-j3', 'group-liburan-jogja', 'user-citra-04', 'member', 'Citra', '0815-5566-7788', ?),
      ('mem-k1', 'group-kost-bulanan', 'user-putri-01', 'member', 'Putri (Anda)', '0812-3456-7890', ?),
      ('mem-k2', 'group-kost-bulanan', 'user-citra-04', 'admin', 'Citra', '0815-5566-7788', ?);
    ''', List.filled(9, now));

    // Seed expenses
    await db.rawInsert('''
      INSERT OR IGNORE INTO expenses (id, group_id, payer_id, title, total_amount, split_type, category, note, expense_date, created_at)
      VALUES 
      ('exp-1', 'group-makan-malam-reuni', 'user-ani-02', 'Makan di Restoran', 200000.00, 'EQUAL', 'Makanan & Minuman', 'Makan malam di restoran Seafood.', ?, ?),
      ('exp-2', 'group-makan-malam-reuni', 'user-budi-03', 'Minuman & Dessert', 120000.00, 'EQUAL', 'Makanan & Minuman', 'Minuman manis.', ?, ?),
      ('exp-3', 'group-makan-malam-reuni', 'user-putri-01', 'Biaya Parkir & Tips', 30000.00, 'EQUAL', 'Transport', 'Parkir.', ?, ?),
      ('exp-4', 'group-makan-malam-reuni', 'user-citra-04', 'Camilan Tambahan', 50000.00, 'EQUAL', 'Makanan & Minuman', 'Camilan.', ?, ?),
      ('exp-5', 'group-liburan-jogja', 'user-putri-01', 'Tiket Kereta PP', 300000.00, 'EQUAL', 'Transport', 'Tiket KA.', ?, ?),
      ('exp-6', 'group-liburan-jogja', 'user-budi-03', 'Bensin & Tol', 105000.00, 'EQUAL', 'Transport', 'Bensin & Tol', ?, ?);
    ''', [
      DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      DateTime.now().subtract(const Duration(hours: 2, minutes: 15)).toIso8601String(),
      DateTime.now().subtract(const Duration(hours: 2, minutes: 15)).toIso8601String(),
      DateTime.now().subtract(const Duration(hours: 1, minutes: 30)).toIso8601String(),
      DateTime.now().subtract(const Duration(hours: 1, minutes: 30)).toIso8601String(),
      DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
      DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
      DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    ]);

    // Seed expense splits
    await db.rawInsert('''
      INSERT OR IGNORE INTO expense_splits (id, expense_id, user_id, amount_owed, is_settled)
      VALUES 
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
    ''');

    // Seed settlements
    await db.rawInsert('''
      INSERT OR IGNORE INTO settlements (id, group_id, debtor_id, creditor_id, amount, status, method, settled_at)
      VALUES 
      ('stl-1', 'group-makan-malam-reuni', 'user-budi-03', 'user-ani-02', 50000.00, 'PENDING', 'Transfer', ?),
      ('stl-2', 'group-makan-malam-reuni', 'user-citra-04', 'user-ani-02', 75000.00, 'PENDING', 'Transfer', ?),
      ('stl-3', 'group-makan-malam-reuni', 'user-putri-01', 'user-budi-03', 25000.00, 'COMPLETED', 'QRIS / Transfer BCA', ?),
      ('stl-4', 'group-liburan-jogja', 'user-budi-03', 'user-putri-01', 75000.00, 'COMPLETED', 'QRIS Gopay', ?);
    ''', [
      DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
      DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    ]);
  }

  Object? _sanitizeArg(Object? arg) {
    if (arg == null) return null;
    if (arg is DateTime) return arg.toIso8601String();
    if (arg is bool) return arg ? 1 : 0;
    return arg;
  }

  /// Executes a query and returns rows formatted as List<List<dynamic>>.
  Future<List<List<dynamic>>> query(
    String sql, {
    List<Object?>? parameters,
    int maxRetries = 2,
  }) async {
    final db = await database;

    String sqlToRun = sql;
    List<Object?> args = [];

    if (parameters != null && parameters.isNotEmpty) {
      if (sql.contains(RegExp(r'\$\d+'))) {
        // Map positional parameters $1, $2, ... to SQLite ?
        sqlToRun = sql.replaceAllMapped(RegExp(r'\$(\d+)'), (match) {
          final index = int.parse(match.group(1)!) - 1;
          if (index >= 0 && index < parameters.length) {
            args.add(_sanitizeArg(parameters[index]));
            return '?';
          }
          return match.group(0)!;
        });
      } else {
        args = parameters.map(_sanitizeArg).toList();
      }
    }

    final trimmed = sqlToRun.trim().toUpperCase();

    if (trimmed.startsWith('SELECT') || trimmed.startsWith('PRAGMA')) {
      final rows = await db.rawQuery(sqlToRun, args);
      return rows.map((r) => r.values.toList()).toList();
    } else if (trimmed.startsWith('INSERT')) {
      await db.rawInsert(sqlToRun, args);
      return <List<dynamic>>[];
    } else if (trimmed.startsWith('UPDATE')) {
      await db.rawUpdate(sqlToRun, args);
      return <List<dynamic>>[];
    } else if (trimmed.startsWith('DELETE')) {
      await db.rawDelete(sqlToRun, args);
      return <List<dynamic>>[];
    } else {
      await db.execute(sqlToRun, args);
      return <List<dynamic>>[];
    }
  }

  /// Executes parameterized SQL statements with positional substitutions
  Future<List<List<dynamic>>> executeParams(
    String sql,
    List<Object?> parameters, {
    int maxRetries = 2,
  }) async {
    return query(sql, parameters: parameters, maxRetries: maxRetries);
  }

  /// Direct query returning Map list
  Future<List<Map<String, dynamic>>> queryMaps(
    String sql, [
    List<Object?>? parameters,
  ]) async {
    final db = await database;
    final args = parameters?.map(_sanitizeArg).toList();
    return await db.rawQuery(sql, args);
  }

  /// Closes database connection
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
      _initCompleter = null;
    }
  }
}
