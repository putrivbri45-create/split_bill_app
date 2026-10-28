import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/utils/currency_formatter.dart';

enum BalanceCardType { debt, credit }

class BalanceCard extends StatelessWidget {
  final BalanceCardType type;
  final double amount;
  final int count;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.type,
    required this.amount,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final isDebt = type == BalanceCardType.debt;

    final title = isDebt ? 'Kamu harus bayar' : 'Kamu harus terima';
    final countLabel = isDebt ? '$count tagihan' : '$count piutang';
    final countIcon = isDebt ? Icons.receipt_long_rounded : Icons.account_balance_wallet_outlined;

    final badgeBg = isDebt
        ? (isDark ? const Color(0xFF4A1818) : AppColors.errorContainer)
        : (isDark ? const Color(0xFF103B2E) : const Color(0xFFD1FAE5));

    final badgeFg = isDebt
        ? (isDark ? const Color(0xFFFFB4AB) : AppColors.onErrorContainer)
        : (isDark ? AppColors.primaryFixed : AppColors.primary);

    final indicatorBg = isDebt
        ? (isDark ? const Color(0xFF3F1919) : const Color(0xFFFDE8E8))
        : (isDark ? const Color(0xFF133B2E) : AppColors.secondaryContainer.withOpacity(0.5));

    final indicatorFg = isDebt ? AppColors.error : AppColors.primary;
    final indicatorIcon = isDebt ? Icons.north_east_rounded : Icons.south_west_rounded;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.cardBorder, width: 1.2),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppText.bodySm.copyWith(
                        color: palette.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: indicatorBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(indicatorIcon, size: 16, color: indicatorFg),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Amount display
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CurrencyFormatter.format(amount),
                  style: AppText.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDebt ? (isDark ? const Color(0xFFFFB4AB) : const Color(0xFFC53030)) : (isDark ? AppColors.primaryFixed : const Color(0xFF006C49)),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(countIcon, size: 12, color: badgeFg),
                    const SizedBox(width: 4),
                    Text(
                      countLabel,
                      style: AppText.labelSm.copyWith(
                        color: badgeFg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
