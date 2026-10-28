import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/core/algorithm/debt_simplifier.dart';

void main() {
  group('DebtSimplifier Algorithm Tests', () {
    test('Scenario 1: Simple 3-party equal bill where A pays 300,000 for A, B, and C', () {
      // Total bill: 300,000. Share per person: 100,000.
      // Net balances:
      // A (paid 300,000, share 100,000) => +200,000
      // B (paid 0, share 100,000) => -100,000
      // C (paid 0, share 100,000) => -100,000

      final netBalances = {
        'user_a': 200000.0,
        'user_b': -100000.0,
        'user_c': -100000.0,
      };

      final userNames = {
        'user_a': 'Ani',
        'user_b': 'Budi',
        'user_c': 'Citra',
      };

      final result = DebtSimplifier.simplify(
        netBalances: netBalances,
        userNames: userNames,
      );

      expect(result.length, 2);
      expect(result.any((d) => d.debtorId == 'user_b' && d.creditorId == 'user_a' && d.amount == 100000.0), isTrue);
      expect(result.any((d) => d.debtorId == 'user_c' && d.creditorId == 'user_a' && d.amount == 100000.0), isTrue);
    });

    test('Scenario 2: Complex 4-party cyclic debt reduced to minimum transactions', () {
      // Suppose:
      // Ani net balance: +150,000
      // Budi net balance: +50,000
      // Citra net balance: -120,000
      // Dimas net balance: -80,000
      // Sum = 0

      final netBalances = {
        'ani': 150000.0,
        'budi': 50000.0,
        'citra': -120000.0,
        'dimas': -80000.0,
      };

      final result = DebtSimplifier.simplify(netBalances: netBalances);

      // Verify that total cleared debts equals total debtor obligations (200,000)
      final totalPaid = result.fold<double>(0.0, (sum, item) => sum + item.amount);
      expect(totalPaid, closeTo(200000.0, 0.01));

      // Debtors should only pay, Creditors should only receive
      for (final debt in result) {
        expect(['citra', 'dimas'].contains(debt.debtorId), isTrue);
        expect(['ani', 'budi'].contains(debt.creditorId), isTrue);
      }

      // Max possible transactions is 3 (N-1 where N=4)
      expect(result.length <= 3, isTrue);
    });

    test('Scenario 3: Zero balances when all debts are settled', () {
      final netBalances = {
        'user_1': 0.0,
        'user_2': 0.0,
        'user_3': 0.0,
      };

      final result = DebtSimplifier.simplify(netBalances: netBalances);
      expect(result.isEmpty, isTrue);
    });
  });
}
