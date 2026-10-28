import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Reusable polished App Logo widget with ambient emerald glow and theme adaptation.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final double? borderRadius;
  final double? padding;

  const AppLogo({
    super.key,
    this.size = 112,
    this.showGlow = true,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? (size * 0.25);
    final pad = padding ?? (size * 0.12);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162521) : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? const Color(0xFF234037)
              : const Color(0xFFBBCABF).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryContainer.withOpacity(isDark ? 0.32 : 0.22),
                  blurRadius: size * 0.32,
                  spreadRadius: size * 0.04,
                  offset: Offset(0, size * 0.08),
                ),
                BoxShadow(
                  color: AppColors.secondaryContainer.withOpacity(isDark ? 0.18 : 0.14),
                  blurRadius: size * 0.42,
                  spreadRadius: 1,
                  offset: Offset(0, -size * 0.04),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: EdgeInsets.all(pad),
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.payments_rounded,
              size: size * 0.5,
              color: AppColors.primaryContainer,
            ),
          );
        },
      ),
    );
  }
}
