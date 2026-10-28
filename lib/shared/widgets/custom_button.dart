import 'package:flutter/material.dart';
import '../../config/theme.dart';

enum ButtonVariant { primary, secondary, outline, text, danger }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? height;
  final double? width;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.width,
    this.fullWidth = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case ButtonVariant.primary:
        bg = AppColors.primaryContainer;
        fg = AppColors.onPrimary;
        shadows = AppShadows.buttonGlow;
        break;
      case ButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest;
        fg = AppColors.primary;
        border = BorderSide(color: AppColors.primaryContainer.withOpacity(0.3), width: 1.5);
        break;
      case ButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.primaryFixedDim : AppColors.primary;
        border = BorderSide(color: isDark ? AppColors.primary : const Color(0xFFA7EBD0), width: 1.5);
        break;
      case ButtonVariant.text:
        bg = Colors.transparent;
        fg = isDark ? AppColors.primaryFixedDim : AppColors.primary;
        break;
      case ButtonVariant.danger:
        bg = AppColors.errorContainer;
        fg = AppColors.onErrorContainer;
        break;
    }

    Widget content = widget.isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: AppText.labelLg.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.height,
            width: widget.fullWidth ? double.infinity : widget.width,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: border != BorderSide.none ? Border.fromBorderSide(border) : null,
              boxShadow: shadows,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
