import 'package:equatable/equatable.dart';

/// Split methods supported by the Add Expense screen (PRD §4.07).
enum SplitMethod {
  equal('EQUAL', 'Sama Rata'),
  exact('EXACT', 'Nominal'),
  percentage('PERCENTAGE', 'Persentase'),
  item('ITEM', 'Per-Item');

  final String code;
  final String label;
  const SplitMethod(this.code, this.label);

  static SplitMethod fromCode(String code) =>
      SplitMethod.values.firstWhere((m) => m.code == code, orElse: () => SplitMethod.equal);
}

/// A line item for [SplitMethod.item]; its price is shared by [participantIds].
class SplitItem extends Equatable {
  final String name;
  final double price;
  final List<String> participantIds;

  const SplitItem({required this.name, required this.price, required this.participantIds});

  @override
  List<Object?> get props => [name, price, participantIds];
}

class SplitResult extends Equatable {
  /// userId -> final amount owed (includes proportional tax & service). Integer rupiah.
  final Map<String, double> shares;
  final double subtotal;
  final double serviceAmount;
  final double taxAmount;
  final double grandTotal;
  final String? error;

  const SplitResult({
    required this.shares,
    required this.subtotal,
    required this.serviceAmount,
    required this.taxAmount,
    required this.grandTotal,
    this.error,
  });

  bool get isValid => error == null;

  factory SplitResult.invalid(String message, {double subtotal = 0}) => SplitResult(
        shares: const {},
        subtotal: subtotal,
        serviceAmount: 0,
        taxAmount: 0,
        grandTotal: 0,
        error: message,
      );

  @override
  List<Object?> get props => [shares, subtotal, serviceAmount, taxAmount, grandTotal, error];
}

/// Pure-Dart split engine. All outputs are whole rupiah and always sum exactly
/// to the grand total (largest-remainder allocation — no lost/extra rupiah).
class SplitCalculator {
  /// Service charge is applied to the subtotal; tax (PB1) is applied on
  /// subtotal + service, matching Indonesian restaurant receipts.
  static SplitResult calculate({
    required SplitMethod method,
    required List<String> participantIds,
    double subtotal = 0,
    double taxPercent = 0,
    double servicePercent = 0,
    Map<String, double> exactAmounts = const {},
    Map<String, double> percentages = const {},
    List<SplitItem> items = const [],
  }) {
    if (participantIds.isEmpty) {
      return SplitResult.invalid('Pilih minimal 1 anggota yang ikut split bill.', subtotal: subtotal);
    }
    if (taxPercent < 0 || servicePercent < 0) {
      return SplitResult.invalid('Pajak dan layanan tidak boleh negatif.', subtotal: subtotal);
    }

    Map<String, double> weights;
    double base = subtotal.roundToDouble();

    switch (method) {
      case SplitMethod.equal:
        weights = {for (final id in participantIds) id: 1};
        break;
      case SplitMethod.exact:
        final sum = participantIds.fold<double>(0, (s, id) => s + (exactAmounts[id] ?? 0));
        if ((sum - base).abs() > 0.5) {
          final diff = base - sum;
          return SplitResult.invalid(
            diff > 0
                ? 'Masih kurang Rp${diff.round()} dari total.'
                : 'Kelebihan Rp${(-diff).round()} dari total.',
            subtotal: base,
          );
        }
        weights = {for (final id in participantIds) id: exactAmounts[id] ?? 0};
        break;
      case SplitMethod.percentage:
        final sum = participantIds.fold<double>(0, (s, id) => s + (percentages[id] ?? 0));
        if ((sum - 100).abs() > 0.01) {
          return SplitResult.invalid('Total persentase harus 100% (saat ini ${_fmtPct(sum)}%).', subtotal: base);
        }
        weights = {for (final id in participantIds) id: percentages[id] ?? 0};
        break;
      case SplitMethod.item:
        if (items.isEmpty) {
          return SplitResult.invalid('Tambahkan minimal 1 item.', subtotal: 0);
        }
        final perPerson = <String, double>{for (final id in participantIds) id: 0};
        double itemsTotal = 0;
        for (final item in items) {
          final assigned = item.participantIds.where(perPerson.containsKey).toList();
          if (assigned.isEmpty) {
            return SplitResult.invalid('Item "${item.name}" belum punya penanggung.', subtotal: itemsTotal);
          }
          final alloc = allocate(item.price.round(), {for (final id in assigned) id: 1});
          alloc.forEach((id, v) => perPerson[id] = perPerson[id]! + v);
          itemsTotal += item.price.roundToDouble();
        }
        base = itemsTotal;
        weights = perPerson;
        break;
    }

    if (base <= 0) {
      return SplitResult.invalid('Nominal harus lebih dari Rp0.', subtotal: base);
    }

    final service = (base * servicePercent / 100).roundToDouble();
    final tax = ((base + service) * taxPercent / 100).roundToDouble();
    final grand = base + service + tax;

    final shares = allocate(grand.round(), weights).map((k, v) => MapEntry(k, v.toDouble()));

    return SplitResult(
      shares: shares,
      subtotal: base,
      serviceAmount: service,
      taxAmount: tax,
      grandTotal: grand,
    );
  }

  /// Largest-remainder (Hamilton) allocation of an integer [total] by [weights].
  /// Guarantees `sum(result) == total`. Ties resolved by insertion order.
  static Map<String, int> allocate(int total, Map<String, double> weights) {
    final keys = weights.keys.toList();
    if (keys.isEmpty) return {};
    final weightSum = weights.values.fold<double>(0, (s, w) => s + (w > 0 ? w : 0));
    if (weightSum <= 0) {
      // Fallback: equal split
      return allocate(total, {for (final k in keys) k: 1});
    }

    final result = <String, int>{};
    final remainders = <MapEntry<String, double>>[];
    var allocated = 0;
    for (final k in keys) {
      final w = weights[k]! > 0 ? weights[k]! : 0.0;
      final exact = total * w / weightSum;
      final floor = exact.floor();
      result[k] = floor;
      allocated += floor;
      remainders.add(MapEntry(k, exact - floor));
    }

    var leftover = total - allocated;
    if (leftover > 0) {
      final order = List.generate(remainders.length, (i) => i)
        ..sort((a, b) {
          final cmp = remainders[b].value.compareTo(remainders[a].value);
          return cmp != 0 ? cmp : a.compareTo(b);
        });
      for (final i in order) {
        if (leftover == 0) break;
        result[remainders[i].key] = result[remainders[i].key]! + 1;
        leftover--;
      }
    }
    return result;
  }

  static String _fmtPct(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
