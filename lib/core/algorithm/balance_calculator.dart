import '../../features/expenses/domain/models/expense_model.dart';
import '../../features/settlements/domain/models/settlement_model.dart';

/// Computes per-member net balances for a group.
///
/// net_balance_i = Σ paid_i − Σ owed_i  (+ settlements sent − settlements received)
/// Positive = creditor (should receive), negative = debtor (should pay).
class BalanceCalculator {
  static Map<String, double> netBalances({
    required Iterable<String> memberIds,
    required Iterable<ExpenseModel> expenses,
    required Iterable<SettlementModel> settlements,
  }) {
    final balances = <String, double>{for (final id in memberIds) id: 0};

    for (final e in expenses) {
      final payer = e.payerId;
      if (payer != null) {
        balances[payer] = (balances[payer] ?? 0) + e.totalAmount;
      }
      for (final s in e.splits) {
        balances[s.userId] = (balances[s.userId] ?? 0) - s.amountOwed;
      }
    }

    for (final s in settlements) {
      if (s.status != 'COMPLETED') continue;
      balances[s.debtorId] = (balances[s.debtorId] ?? 0) + s.amount;
      balances[s.creditorId] = (balances[s.creditorId] ?? 0) - s.amount;
    }

    // Normalise floating-point noise to whole rupiah.
    return balances.map((k, v) => MapEntry(k, v.roundToDouble() == -0.0 ? 0.0 : v.roundToDouble()));
  }
}
