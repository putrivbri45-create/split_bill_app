import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/core/database/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseService SQLite Tests', () {
    test('Initializes database and verifies seeded tables and users', () async {
      final dbService = DatabaseService.instance;
      final db = await dbService.init();
      expect(db.isOpen, isTrue);

      // Verify tables exist
      final tablesResult = await dbService.query(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;",
      );
      final tableNames = tablesResult.map((row) => row[0].toString()).toList();
      expect(tableNames, contains('users'));
      expect(tableNames, contains('groups'));
      expect(tableNames, contains('group_members'));
      expect(tableNames, contains('expenses'));
      expect(tableNames, contains('expense_splits'));
      expect(tableNames, contains('settlements'));

      // Verify seeded user
      final userResult = await dbService.executeParams(
        "SELECT id, email, full_name FROM users WHERE id = \$1;",
        ['user-putri-01'],
      );
      expect(userResult.isNotEmpty, isTrue);
      expect(userResult.first[0], equals('user-putri-01'));
      expect(userResult.first[1], equals('putrivbri@splitbill.id'));
      expect(userResult.first[2], equals('putrivbri'));

      // Verify seeded groups
      final groupsResult = await dbService.query(
        "SELECT id, name FROM groups WHERE id = \$1;",
        parameters: ['group-makan-malam-reuni'],
      );
      expect(groupsResult.isNotEmpty, isTrue);
      expect(groupsResult.first[1], equals('Makan Malam Reuni'));
    });

    test('Supports parameter substitution with repeated \$1 and typed values', () async {
      final dbService = DatabaseService.instance;
      
      // Query with repeated positional parameter
      final res = await dbService.executeParams(
        "SELECT id, full_name FROM users WHERE (email = \$1 OR phone_number = \$1) LIMIT 1;",
        ['putrivbri@splitbill.id'],
      );
      expect(res.isNotEmpty, isTrue);
      expect(res.first[1], equals('putrivbri'));

      // Test inserting and querying a new expense
      final testExpId = 'test-exp-sqlite';
      await dbService.executeParams(
        "INSERT INTO expenses (id, group_id, title, total_amount, split_type) VALUES (\$1, \$2, \$3, \$4, \$5);",
        [testExpId, 'group-makan-malam-reuni', 'Test Kopi SQLite', 25000.0, 'EQUAL'],
      );

      final expQuery = await dbService.executeParams(
        "SELECT title, total_amount FROM expenses WHERE id = \$1;",
        [testExpId],
      );
      expect(expQuery.isNotEmpty, isTrue);
      expect(expQuery.first[0], equals('Test Kopi SQLite'));
      expect(expQuery.first[1], equals(25000.0));

      // Clean up
      await dbService.executeParams("DELETE FROM expenses WHERE id = \$1;", [testExpId]);
    });
  });
}

