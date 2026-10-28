import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/expenses/domain/models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (expense.category.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        icon = Icons.restaurant_menu_rounded;
        iconColor = const Color(0xFF00897B);
        iconBg = isDark ? const Color(0xFF0A2E28) : const Color(0xFFE0F2F1);
        break;
      case 'transport':
        icon = Icons.directions_car_rounded;
        iconColor = const Color(0xFF0288D1);
        iconBg = isDark ? const Color(0xFF0D2838) : const Color(0xFFE1F5FE);
        break;
      default:
        icon = Icons.receipt_rounded;
        iconColor = const Color(0xFF8E24AA);
        iconBg = isDark ? const Color(0xFF2A1033) : const Color(0xFFF3E5F5);
    }

    final perPerson = expense.splits.isNotEmpty
        ? expense.totalAmount / expense.splits.length
        : expense.totalAmount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.cardBorder, width: 1.2),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: AppText.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.onSurface,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dibayar oleh ${expense.payerName}  •  Hari ini',
                    style: AppText.bodySm.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Participants badge row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.surfaceLow,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group_outlined, size: 12, color: palette.outline),
                            const SizedBox(width: 4),
                            Text(
                              '${expense.splits.length} orang',
                              style: AppText.labelSm.copyWith(
                                color: palette.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Member bubbles A B C D
                      ...expense.splits.take(4).map((s) {
                        final initial = s.userName.isNotEmpty ? s.userName[0].toUpperCase() : 'M';
                        return Container(
                          margin: const EdgeInsets.only(right: 3),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(expense.totalAmount),
                  style: AppText.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: palette.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.format(perPerson)}/org',
                  style: AppText.bodySm.copyWith(
                    color: palette.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
