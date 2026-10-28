import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/settlements/domain/models/settlement_model.dart';

class SettlementCard extends StatelessWidget {
  final SettlementModel settlement;
  final VoidCallback? onRemind;
  final VoidCallback? onPay;

  const SettlementCard({
    super.key,
    required this.settlement,
    this.onRemind,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final isPaid = settlement.status == 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isPaid ? AppColors.primaryContainer : AppColors.warning,
                width: 5,
              ),
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status badge & Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? (isDark ? const Color(0xFF103B2E) : const Color(0xFFD1FAE5))
                          : (isDark ? const Color(0xFF3F2B12) : AppColors.warningContainer),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle_outline_rounded : Icons.access_time_rounded,
                          size: 13,
                          color: isPaid ? (isDark ? AppColors.primaryFixed : AppColors.primary) : AppColors.onWarningContainer,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isPaid ? 'Sudah dibayar' : 'Belum dibayar',
                          style: AppText.labelSm.copyWith(
                            color: isPaid ? (isDark ? AppColors.primaryFixed : AppColors.primary) : AppColors.onWarningContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(settlement.amount),
                    style: AppText.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Debtor -> Creditor Flow
              Row(
                children: [
                  // Debtor
                  _buildUserAvatar(settlement.debtorName, palette),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengirim',
                          style: AppText.bodySm.copyWith(
                            color: palette.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          settlement.debtorName,
                          style: AppText.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: palette.surfaceLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: palette.outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Creditor
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Penerima',
                          style: AppText.bodySm.copyWith(
                            color: palette.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          settlement.creditorName,
                          style: AppText.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildUserAvatar(settlement.creditorName, palette),
                ],
              ),
              const SizedBox(height: 16),
              // Action or Proof
              if (isPaid)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162422) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded, size: 16, color: AppColors.primaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          settlement.method != null
                              ? 'Lunas via ${settlement.method}'
                              : 'Lunas via QRIS / Transfer Bank',
                          style: AppText.bodySm.copyWith(
                            color: isDark ? AppColors.primaryFixed : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRemind,
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: const Text('Kirim Pengingat'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          side: BorderSide(color: palette.cardBorder),
                          foregroundColor: palette.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPay,
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                        label: const Text('Bayar QRIS'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String name, AppPalette palette) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primaryFixedDim.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: palette.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
