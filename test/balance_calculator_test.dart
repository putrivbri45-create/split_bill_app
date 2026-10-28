import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/core/algorithm/balance_calculator.dart';
import 'package:patungan/features/expenses/domain/models/expense_model.dart';
import 'package:patungan/features/settlements/domain/models/settlement_model.dart';

void main() {
  group('BalanceCalculator Tests', () {
    test('Calculates correct net balances from expenses and settlements', () {
      final expenses = [
        ExpenseModel(
          id: 'exp1',
          groupId: 'g1',
          payerId: 'u1',
          payerName: 'User 1',
          title: 'Dinner',
          totalAmount: 150000,
          expenseDate: DateTime.now(),
          createdAt: DateTime.now(),
          splits: const [
            ExpenseSplitModel(id: 's1', expenseId: 'exp1', userId: 'u1', userName: 'User 1', amountOwed: 50000),
            ExpenseSplitModel(id: 's2', expenseId: 'exp1', userId: 'u2', userName: 'User 2', amountOwed: 50000),
            ExpenseSplitModel(id: 's3', expenseId: 'exp1', userId: 'u3', userName: 'User 3', amountOwed: 50000),
          ],
        ),
      ];

      final settlements = [
        SettlementModel(
          id: 'st1',
          groupId: 'g1',
          debtorId: 'u2',
          debtorName: 'User 2',
          creditorId: 'u1',
          creditorName: 'User 1',
          amount: 50000,
          status: 'COMPLETED',
          settledAt: DateTime.now(),
        ),
      ];

      final balances = BalanceCalculator.netBalances(
        memberIds: ['u1', 'u2', 'u3'],
        expenses: expenses,
        settlements: settlements,
      );

      // u1 paid 150k, owed 50k, received 50k settlement => net = 150k - 50k - 50k = +50k
      expect(balances['u1'], 50000);
      // u2 paid 0k, owed 50k, sent 50k settlement => net = -50k + 50k = 0k
      expect(balances['u2'], 0);
      // u3 paid 0k, owed 50k => net = -50k
      expect(balances['u3'], -50000);
    });
  });
}
