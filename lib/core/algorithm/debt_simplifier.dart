import 'package:equatable/equatable.dart';

class SimplifiedDebt extends Equatable {
  final String debtorId;
  final String debtorName;
  final String creditorId;
  final String creditorName;
  final double amount;
  final bool isSettled;

  const SimplifiedDebt({
    required this.debtorId,
    required this.debtorName,
    required this.creditorId,
    required this.creditorName,
    required this.amount,
    this.isSettled = false,
  });

  SimplifiedDebt copyWith({
    String? debtorId,
    String? debtorName,
    String? creditorId,
    String? creditorName,
    double? amount,
    bool? isSettled,
  }) {
    return SimplifiedDebt(
      debtorId: debtorId ?? this.debtorId,
      debtorName: debtorName ?? this.debtorName,
      creditorId: creditorId ?? this.creditorId,
      creditorName: creditorName ?? this.creditorName,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  @override
  List<Object?> get props => [
        debtorId,
        debtorName,
        creditorId,
        creditorName,
        amount,
        isSettled,
      ];
}

class _BalanceEntry {
  final String userId;
  final String userName;
  double balance;

  _BalanceEntry({
    required this.userId,
    required this.userName,
    required this.balance,
  });
}

class DebtSimplifier {
  /// Solves the pairwise debt graph using a greedy matching / two-pointer approach.
  /// Given a map of `userId -> netBalance` where:
  /// - netBalance > 0 means the user is owed money (creditor)
  /// - netBalance < 0 means the user owes money (debtor)
  static List<SimplifiedDebt> simplify({
    required Map<String, double> netBalances,
    Map<String, String>? userNames,
  }) {
    final List<_BalanceEntry> debtors = [];
    final List<_BalanceEntry> creditors = [];

    netBalances.forEach((userId, balance) {
      final name = userNames?[userId] ?? userId;
      // Round to 2 decimal places to avoid floating point precision issues
      final rounded = double.parse(balance.toStringAsFixed(2));
      if (rounded < -0.01) {
        debtors.add(_BalanceEntry(userId: userId, userName: name, balance: -rounded));
      } else if (rounded > 0.01) {
        creditors.add(_BalanceEntry(userId: userId, userName: name, balance: rounded));
      }
    });

    final List<SimplifiedDebt> simplified = [];

    // Sort debtors and creditors descending by balance for greedy matching
    debtors.sort((a, b) => b.balance.compareTo(a.balance));
    creditors.sort((a, b) => b.balance.compareTo(a.balance));

    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      final debtor = debtors[debtorIndex];
      final creditor = creditors[creditorIndex];

      final minAmount = debtor.balance < creditor.balance ? debtor.balance : creditor.balance;
      final roundedAmount = double.parse(minAmount.toStringAsFixed(2));

      if (roundedAmount > 0.009) {
        simplified.add(
          SimplifiedDebt(
            debtorId: debtor.userId,
            debtorName: debtor.userName,
            creditorId: creditor.userId,
            creditorName: creditor.userName,
            amount: roundedAmount,
          ),
        );
      }

      debtor.balance -= minAmount;
      creditor.balance -= minAmount;

      if (debtor.balance < 0.01) {
        debtorIndex++;
      }
      if (creditor.balance < 0.01) {
        creditorIndex++;
      }
    }

    return simplified;
  }
}
