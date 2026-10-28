import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../domain/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getExpensesByGroup(String groupId);
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel> addExpense(ExpenseModel expense);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  // Mock expenses matching Stitch design screenshot #6 (Group Detail) and #9 (History)
  static final List<ExpenseModel> _mockExpenses = [
    ExpenseModel(
      id: 'exp-1',
      groupId: 'group-makan-malam-reuni',
      payerId: 'user-ani-02',
      payerName: 'Ani',
      title: 'Makan di Restoran',
      totalAmount: 200000.0,
      splitType: 'EQUAL',
      category: 'Makanan & Minuman',
      note: 'Makan malam di restoran Seafood.',
      expenseDate: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      splits: const [
        ExpenseSplitModel(id: 'sp-1', expenseId: 'exp-1', userId: 'user-ani-02', userName: 'Ani', amountOwed: 50000.0),
        ExpenseSplitModel(id: 'sp-2', expenseId: 'exp-1', userId: 'user-budi-03', userName: 'Budi', amountOwed: 50000.0),
        ExpenseSplitModel(id: 'sp-3', expenseId: 'exp-1', userId: 'user-citra-04', userName: 'Citra', amountOwed: 50000.0),
        ExpenseSplitModel(id: 'sp-4', expenseId: 'exp-1', userId: 'user-putri-01', userName: 'Putri (Anda)', amountOwed: 50000.0),
      ],
    ),
    ExpenseModel(
      id: 'exp-2',
      groupId: 'group-makan-malam-reuni',
      payerId: 'user-budi-03',
      payerName: 'Budi',
      title: 'Minuman & Dessert',
      totalAmount: 120000.0,
      splitType: 'EQUAL',
      category: 'Makanan & Minuman',
      expenseDate: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      splits: const [
        ExpenseSplitModel(id: 'sp-5', expenseId: 'exp-2', userId: 'user-ani-02', userName: 'Ani', amountOwed: 30000.0),
        ExpenseSplitModel(id: 'sp-6', expenseId: 'exp-2', userId: 'user-budi-03', userName: 'Budi', amountOwed: 30000.0),
        ExpenseSplitModel(id: 'sp-7', expenseId: 'exp-2', userId: 'user-citra-04', userName: 'Citra', amountOwed: 30000.0),
        ExpenseSplitModel(id: 'sp-8', expenseId: 'exp-2', userId: 'user-putri-01', userName: 'Putri (Anda)', amountOwed: 30000.0),
      ],
    ),
    ExpenseModel(
      id: 'exp-3',
      groupId: 'group-makan-malam-reuni',
      payerId: 'user-putri-01',
      payerName: 'Putri (Anda)',
      title: 'Biaya Parkir & Tips',
      totalAmount: 30000.0,
      splitType: 'EQUAL',
      category: 'Transport',
      expenseDate: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      splits: const [
        ExpenseSplitModel(id: 'sp-9', expenseId: 'exp-3', userId: 'user-ani-02', userName: 'Ani', amountOwed: 7500.0),
        ExpenseSplitModel(id: 'sp-10', expenseId: 'exp-3', userId: 'user-budi-03', userName: 'Budi', amountOwed: 7500.0),
        ExpenseSplitModel(id: 'sp-11', expenseId: 'exp-3', userId: 'user-citra-04', userName: 'Citra', amountOwed: 7500.0),
        ExpenseSplitModel(id: 'sp-12', expenseId: 'exp-3', userId: 'user-putri-01', userName: 'Putri (Anda)', amountOwed: 7500.0),
      ],
    ),
    ExpenseModel(
      id: 'exp-4',
      groupId: 'group-makan-malam-reuni',
      payerId: 'user-citra-04',
      payerName: 'Citra',
      title: 'Camilan Tambahan',
      totalAmount: 50000.0,
      splitType: 'EQUAL',
      category: 'Makanan & Minuman',
      expenseDate: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      splits: const [
        ExpenseSplitModel(id: 'sp-13', expenseId: 'exp-4', userId: 'user-ani-02', userName: 'Ani', amountOwed: 16666.6),
        ExpenseSplitModel(id: 'sp-14', expenseId: 'exp-4', userId: 'user-citra-04', userName: 'Citra', amountOwed: 16666.7),
        ExpenseSplitModel(id: 'sp-15', expenseId: 'exp-4', userId: 'user-putri-01', userName: 'Putri (Anda)', amountOwed: 16666.7),
      ],
    ),
    // Past expenses for History view
    ExpenseModel(
      id: 'exp-5',
      groupId: 'group-liburan-jogja',
      payerId: 'user-putri-01',
      payerName: 'Putri (Anda)',
      title: 'Tiket Kereta PP',
      totalAmount: 300000.0,
      splitType: 'EQUAL',
      category: 'Transport',
      expenseDate: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      splits: const [
        ExpenseSplitModel(id: 'sp-16', expenseId: 'exp-5', userId: 'user-putri-01', userName: 'Putri', amountOwed: 100000.0),
        ExpenseSplitModel(id: 'sp-17', expenseId: 'exp-5', userId: 'user-budi-03', userName: 'Budi', amountOwed: 100000.0),
        ExpenseSplitModel(id: 'sp-18', expenseId: 'exp-5', userId: 'user-citra-04', userName: 'Citra', amountOwed: 100000.0),
      ],
    ),
    ExpenseModel(
      id: 'exp-6',
      groupId: 'group-liburan-jogja',
      payerId: 'user-budi-03',
      payerName: 'Budi',
      title: 'Bensin & Tol',
      totalAmount: 105000.0,
      splitType: 'EQUAL',
      category: 'Transport',
      expenseDate: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      splits: const [
        ExpenseSplitModel(id: 'sp-19', expenseId: 'exp-6', userId: 'user-putri-01', userName: 'Putri', amountOwed: 35000.0),
        ExpenseSplitModel(id: 'sp-20', expenseId: 'exp-6', userId: 'user-budi-03', userName: 'Budi', amountOwed: 35000.0),
        ExpenseSplitModel(id: 'sp-21', expenseId: 'exp-6', userId: 'user-citra-04', userName: 'Citra', amountOwed: 35000.0),
      ],
    ),
  ];

  @override
  Future<List<ExpenseModel>> getExpensesByGroup(String groupId) async {
    if (_db.isConfigured) {
      try {
        final res = await _db.executeParams(
          '''
          SELECT 
            e.id, 
            e.group_id, 
            e.payer_id, 
            COALESCE(u.full_name, m.display_name, 'Ani') AS payer_name,
            e.title, 
            e.total_amount, 
            e.split_type, 
            e.tax_amount, 
            e.service_charge, 
            e.bill_image_url, 
            e.expense_date, 
            e.created_at, 
            e.category, 
            e.note 
          FROM expenses e
          LEFT JOIN users u ON e.payer_id = u.id
          LEFT JOIN group_members m ON (e.group_id = m.group_id AND e.payer_id = m.user_id)
          WHERE e.group_id = \$1 
          ORDER BY e.expense_date DESC;
          ''',
          [groupId],
        );
        if (res.isNotEmpty) {
          final List<ExpenseModel> list = [];
          for (final row in res) {
            final expId = row[0].toString();
            final spRes = await _db.executeParams(
              '''
              SELECT 
                s.id, 
                s.expense_id, 
                s.user_id, 
                COALESCE(u.full_name, 'Member') AS user_name,
                s.amount_owed, 
                s.is_settled, 
                s.settled_at 
              FROM expense_splits s
              LEFT JOIN users u ON s.user_id = u.id
              WHERE s.expense_id = \$1;
              ''',
              [expId],
            );
            final splits = spRes.map((s) => ExpenseSplitModel(
              id: s[0].toString(),
              expenseId: s[1].toString(),
              userId: s[2].toString(),
              userName: s[3]?.toString() ?? 'Member',
              amountOwed: double.tryParse(s[4]?.toString() ?? '0') ?? 0.0,
              isSettled: s[5] == true || s[5] == 1 || s[5] == '1' || s[5] == 'true',
            )).toList();

            list.add(ExpenseModel(
              id: expId,
              groupId: row[1].toString(),
              payerId: row[2]?.toString(),
              payerName: row[3]?.toString() ?? 'Ani',
              title: row[4].toString(),
              totalAmount: double.tryParse(row[5]?.toString() ?? '0') ?? 0.0,
              splitType: row[6]?.toString() ?? 'EQUAL',
              taxAmount: double.tryParse(row[7]?.toString() ?? '0') ?? 0.0,
              serviceCharge: double.tryParse(row[8]?.toString() ?? '0') ?? 0.0,
              billImageUrl: row[9]?.toString(),
              expenseDate: row[10] != null ? DateTime.tryParse(row[10].toString()) ?? DateTime.now() : DateTime.now(),
              createdAt: row[11] != null ? DateTime.tryParse(row[11].toString()) ?? DateTime.now() : DateTime.now(),
              category: row[12]?.toString() ?? 'Makanan & Minuman',
              note: row[13]?.toString(),
              splits: splits,
            ));
          }
          return list;
        } else {
          // If group exists in database but has no expenses yet, return empty list
          final groupExists = await _db.executeParams(
            "SELECT id FROM groups WHERE id = \$1 LIMIT 1;",
            [groupId],
          );
          if (groupExists.isNotEmpty) {
            return [];
          }
        }
      } catch (e) {
        debugPrint('Error getting expenses by group: $e');
      }
    }
    return _mockExpenses.where((e) => e.groupId == groupId).toList();
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    if (_db.isConfigured) {
      try {
        final res = await _db.query(
          '''
          SELECT 
            e.id, 
            e.group_id, 
            e.payer_id, 
            COALESCE(u.full_name, m.display_name, 'Ani') AS payer_name,
            e.title, 
            e.total_amount, 
            e.split_type, 
            e.tax_amount, 
            e.service_charge, 
            e.bill_image_url, 
            e.expense_date, 
            e.created_at, 
            e.category, 
            e.note 
          FROM expenses e
          LEFT JOIN users u ON e.payer_id = u.id
          LEFT JOIN group_members m ON (e.group_id = m.group_id AND e.payer_id = m.user_id)
          ORDER BY e.expense_date DESC;
          ''',
        );
        if (res.isNotEmpty) {
          final List<ExpenseModel> list = [];
          for (final row in res) {
            final expId = row[0].toString();
            final spRes = await _db.executeParams(
              '''
              SELECT 
                s.id, 
                s.expense_id, 
                s.user_id, 
                COALESCE(u.full_name, 'Member') AS user_name,
                s.amount_owed, 
                s.is_settled, 
                s.settled_at 
              FROM expense_splits s
              LEFT JOIN users u ON s.user_id = u.id
              WHERE s.expense_id = \$1;
              ''',
              [expId],
            );
            final splits = spRes.map((s) => ExpenseSplitModel(
              id: s[0].toString(),
              expenseId: s[1].toString(),
              userId: s[2].toString(),
              userName: s[3]?.toString() ?? 'Member',
              amountOwed: double.tryParse(s[4]?.toString() ?? '0') ?? 0.0,
              isSettled: s[5] == true || s[5] == 1 || s[5] == '1' || s[5] == 'true',
            )).toList();

            list.add(ExpenseModel(
              id: expId,
              groupId: row[1].toString(),
              payerId: row[2]?.toString(),
              payerName: row[3]?.toString() ?? 'Ani',
              title: row[4].toString(),
              totalAmount: double.tryParse(row[5]?.toString() ?? '0') ?? 0.0,
              splitType: row[6]?.toString() ?? 'EQUAL',
              taxAmount: double.tryParse(row[7]?.toString() ?? '0') ?? 0.0,
              serviceCharge: double.tryParse(row[8]?.toString() ?? '0') ?? 0.0,
              billImageUrl: row[9]?.toString(),
              expenseDate: row[10] != null ? DateTime.tryParse(row[10].toString()) ?? DateTime.now() : DateTime.now(),
              createdAt: row[11] != null ? DateTime.tryParse(row[11].toString()) ?? DateTime.now() : DateTime.now(),
              category: row[12]?.toString() ?? 'Makanan & Minuman',
              note: row[13]?.toString(),
              splits: splits,
            ));
          }
          return list;
        }
      } catch (e) {
        debugPrint('Error getting all expenses: $e');
      }
    }
    return List.from(_mockExpenses);
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final expId = expense.id.isEmpty ? 'exp-${_uuid.v4().substring(0, 8)}' : expense.id;
    final populatedSplits = expense.splits.map((s) {
      return s.copyWith(
        id: s.id.isEmpty ? 'sp-${_uuid.v4().substring(0, 6)}' : s.id,
        expenseId: expId,
      );
    }).toList();

    final newExpense = expense.copyWith(
      id: expId,
      splits: populatedSplits,
    );

    // Keep memory fallback in sync
    _mockExpenses.removeWhere((e) => e.id == expId);
    _mockExpenses.insert(0, newExpense);

    if (_db.isConfigured) {
      try {
        await _db.executeParams(
          "INSERT INTO expenses (id, group_id, payer_id, title, total_amount, split_type, tax_amount, service_charge, bill_image_url, expense_date, created_at, category, note) VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13);",
          [
            expId,
            newExpense.groupId,
            newExpense.payerId,
            newExpense.title,
            newExpense.totalAmount,
            newExpense.splitType,
            newExpense.taxAmount,
            newExpense.serviceCharge,
            newExpense.billImageUrl,
            newExpense.expenseDate,
            newExpense.createdAt,
            newExpense.category,
            newExpense.note,
          ],
        );

        for (final sp in populatedSplits) {
          await _db.executeParams(
            "INSERT INTO expense_splits (id, expense_id, user_id, amount_owed, is_settled) VALUES (\$1, \$2, \$3, \$4, \$5);",
            [sp.id, expId, sp.userId, sp.amountOwed, sp.isSettled ? 1 : 0],
          );
        }
      } catch (e) {
        debugPrint('Error saving expense to SQLite: $e');
      }
    }

    return newExpense;
  }
}
