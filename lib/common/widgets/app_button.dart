import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppButtonVariant { primary, dark, soft, ghost, outline, outlineWhite, white, danger, success }
enum AppButtonSize { lg, md, sm }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.fullWidth = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final (height, fontSize, radius, px) = switch (size) {
      AppButtonSize.lg => (54.0, 16.0, 16.0, 20.0),
      AppButtonSize.md => (46.0, 15.0, 14.0, 16.0),
      AppButtonSize.sm => (38.0, 13.5, 11.0, 13.0),
    };

    final (bg, fg, shadow, border) = _resolveStyle();
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: disabled || isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: height,
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: px),
          decoration: BoxDecoration(
            gradient: variant == AppButtonVariant.primary ? AppColors.primaryGradient : null,
            color: variant != AppButtonVariant.primary ? bg : null,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadow,
            border: border,
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                ),
                const SizedBox(width: 9),
              ] else if (icon != null) ...[
                icon!,
                const SizedBox(width: 9),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, List<BoxShadow>, Border?) _resolveStyle() {
    return switch (variant) {
      AppButtonVariant.primary => (
          AppColors.primaryGold,
          AppColors.bg,
          AppColors.shadowPrimary,
          null,
        ),
      AppButtonVariant.dark => (AppColors.surface, AppColors.textPrimary, [], null),
      AppButtonVariant.soft => (AppColors.darkGray, AppColors.primaryGold, [], null),
      AppButtonVariant.ghost => (Colors.transparent, AppColors.textSecondary, [], null),
      AppButtonVariant.outline => (
          Colors.transparent,
          AppColors.primaryGold,
          [],
          Border.all(color: AppColors.primaryGold, width: 1.5),
        ),
      AppButtonVariant.outlineWhite => (
          Colors.transparent,
          AppColors.textPrimary,
          [],
          Border.all(color: AppColors.textPrimary.withValues(alpha: 0.7), width: 1.5),
        ),
      AppButtonVariant.white => (
          AppColors.textPrimary,
          AppColors.bg,
          [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 20, offset: const Offset(0, 8))],
          null,
        ),
      AppButtonVariant.danger => (AppColors.error, AppColors.textPrimary, [], null),
      AppButtonVariant.success => (AppColors.success, AppColors.textPrimary, [], null),
    };
  }
}
