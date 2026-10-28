import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/core/database/database_service.dart';
import 'package:patungan/features/expenses/data/expense_repository.dart';
import 'package:patungan/features/expenses/domain/models/expense_model.dart';
import 'package:patungan/features/groups/data/group_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Persistence Integration Tests', () {
    test('Adding an expense updates group total spending, expense count, and appears in history', () async {
      final dbService = DatabaseService.instance;
      await dbService.init();

      final groupRepo = GroupRepositoryImpl();
      final expenseRepo = ExpenseRepositoryImpl();

      // 1. Get initial groups
      final initialGroups = await groupRepo.getGroups();
      expect(initialGroups.isNotEmpty, isTrue);

      final targetGroup = initialGroups.firstWhere(
        (g) => g.id == 'group-makan-malam-reuni',
        orElse: () => initialGroups.first,
      );

      final initialSpending = targetGroup.totalSpending;
      final initialExpenseCount = targetGroup.expenseCount;

      // 2. Add a new expense to this group
      final newExpense = ExpenseModel(
        id: '',
        groupId: targetGroup.id,
        payerId: 'user-putri-01',
        payerName: 'Putri (Anda)',
        title: 'Kopi Kenangan Mantan',
        totalAmount: 50000.0,
        splitType: 'EQUAL',
        category: 'Makanan & Minuman',
        expenseDate: DateTime.now(),
        createdAt: DateTime.now(),
        splits: const [
          ExpenseSplitModel(
            id: '',
            expenseId: '',
            userId: 'user-putri-01',
            userName: 'Putri (Anda)',
            amountOwed: 25000.0,
          ),
          ExpenseSplitModel(
            id: '',
            expenseId: '',
            userId: 'user-ani-02',
            userName: 'Ani',
            amountOwed: 25000.0,
          ),
        ],
      );

      final savedExpense = await expenseRepo.addExpense(newExpense);
      expect(savedExpense.id.isNotEmpty, isTrue);

      // 3. Verify in getExpensesByGroup
      final groupExpenses = await expenseRepo.getExpensesByGroup(targetGroup.id);
      final foundInGroup = groupExpenses.any((e) => e.id == savedExpense.id);
      expect(foundInGroup, isTrue);

      final fetchedExp = groupExpenses.firstWhere((e) => e.id == savedExpense.id);
      expect(fetchedExp.title, equals('Kopi Kenangan Mantan'));
      expect(fetchedExp.totalAmount, equals(50000.0));
      expect(fetchedExp.payerName, isNotEmpty);
      expect(fetchedExp.splits.length, equals(2));

      // 4. Verify in getAllExpenses (Transaction History)
      final allExpenses = await expenseRepo.getAllExpenses();
      final foundInAll = allExpenses.any((e) => e.id == savedExpense.id);
      expect(foundInAll, isTrue);

      // 5. Verify group spending and count updated dynamically from SQLite
      final updatedGroups = await groupRepo.getGroups();
      final updatedGroup = updatedGroups.firstWhere((g) => g.id == targetGroup.id);

      expect(updatedGroup.expenseCount, equals(initialExpenseCount + 1));
      expect(updatedGroup.totalSpending, equals(initialSpending + 50000.0));
    });
  });
}
