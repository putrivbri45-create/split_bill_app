import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/core/algorithm/split_calculator.dart';

void main() {
  group('SplitCalculator Tests', () {
    test('Equal split divides whole total without losing pennies', () {
      final res = SplitCalculator.calculate(
        method: SplitMethod.equal,
        participantIds: ['u1', 'u2', 'u3'],
        subtotal: 100000,
      );

      expect(res.isValid, isTrue);
      expect(res.grandTotal, 100000);
      final sum = res.shares.values.fold<double>(0, (s, v) => s + v);
      expect(sum, 100000);
      // One gets 33334, two get 33333
      expect(res.shares['u1'], 33334);
      expect(res.shares['u2'], 33333);
      expect(res.shares['u3'], 33333);
    });

    test('Exact split matches total', () {
      final res = SplitCalculator.calculate(
        method: SplitMethod.exact,
        participantIds: ['u1', 'u2'],
        subtotal: 150000,
        exactAmounts: {'u1': 100000, 'u2': 50000},
      );

      expect(res.isValid, isTrue);
      expect(res.shares['u1'], 100000);
      expect(res.shares['u2'], 50000);
    });

    test('Exact split returns error when amounts mismatch', () {
      final res = SplitCalculator.calculate(
        method: SplitMethod.exact,
        participantIds: ['u1', 'u2'],
        subtotal: 150000,
        exactAmounts: {'u1': 90000, 'u2': 50000},
      );

      expect(res.isValid, isFalse);
      expect(res.error, contains('kurang'));
    });

    test('Percentage split with tax and service calculation', () {
      final res = SplitCalculator.calculate(
        method: SplitMethod.percentage,
        participantIds: ['u1', 'u2'],
        subtotal: 100000,
        servicePercent: 5, // 5.000
        taxPercent: 10,    // 10% of 105.000 = 10.500 => Total 115.500
        percentages: {'u1': 60, 'u2': 40},
      );

      expect(res.isValid, isTrue);
      expect(res.serviceAmount, 5000);
      expect(res.taxAmount, 10500);
      expect(res.grandTotal, 115500);
      expect(res.shares['u1'], 69300);
      expect(res.shares['u2'], 46200);
      expect(res.shares['u1']! + res.shares['u2']!, 115500);
    });

    test('Per-Item split correctly assigns items and distributes tax', () {
      final items = [
        const SplitItem(name: 'Steak', price: 100000, participantIds: ['u1']),
        const SplitItem(name: 'Pizza', price: 80000, participantIds: ['u1', 'u2']),
      ];

      final res = SplitCalculator.calculate(
        method: SplitMethod.item,
        participantIds: ['u1', 'u2'],
        items: items,
      );

      expect(res.isValid, isTrue);
      expect(res.subtotal, 180000);
      expect(res.shares['u1'], 140000); // 100k + 40k
      expect(res.shares['u2'], 40000);  // 40k
    });
  });
}
