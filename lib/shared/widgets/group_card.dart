import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/groups/domain/models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    // Category icon styling
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (group.category.toLowerCase()) {
      case 'makanan':
      case 'makanan & minuman':
        icon = Icons.restaurant_rounded;
        iconColor = AppColors.foodAccent;
        iconBg = isDark ? const Color(0xFF3E1F11) : AppColors.foodContainer;
        break;
      case 'liburan':
      case 'travel':
        icon = Icons.flight_takeoff_rounded;
        iconColor = AppColors.travelAccent;
        iconBg = isDark ? const Color(0xFF102D3B) : AppColors.travelContainer;
        break;
      case 'rumah tangga':
      case 'kost':
      case 'rumah/kost':
        icon = Icons.home_rounded;
        iconColor = AppColors.homeAccent;
        iconBg = isDark ? const Color(0xFF1E1F3D) : AppColors.homeContainer;
        break;
      default:
        icon = Icons.group_rounded;
        iconColor = AppColors.workAccent;
        iconBg = isDark ? const Color(0xFF2C193D) : AppColors.workContainer;
    }

    // Status pill
    Widget statusBadge;
    if (group.userDebt > 0) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF4A1818) : AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '${CurrencyFormatter.format(group.userDebt)} harus dibayar',
          style: AppText.labelSm.copyWith(
            color: isDark ? const Color(0xFFFFB4AB) : AppColors.onErrorContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (group.userCredit > 0) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF103B2E) : const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '${CurrencyFormatter.format(group.userCredit)} harus diterima',
          style: AppText.labelSm.copyWith(
            color: isDark ? AppColors.primaryFixed : AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF103B2E) : const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 12, color: isDark ? AppColors.primaryFixed : AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Semua lunas ✓',
              style: AppText.labelSm.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

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
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: AppText.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.memberCount} anggota  •  ${group.expenseCount} pengeluaran',
                    style: AppText.bodySm.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  statusBadge,
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.outlineVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
