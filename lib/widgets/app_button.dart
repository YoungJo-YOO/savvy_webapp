import 'package:flutter/material.dart';

import '../app/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, danger }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.fullWidth = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final padding = switch (size) {
      AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    };
    final textStyle = TextStyle(
      fontSize: switch (size) {
        AppButtonSize.sm => 13,
        AppButtonSize.md => 15,
        AppButtonSize.lg => 17,
      },
      fontWeight: FontWeight.w600,
    );

    final button = switch (variant) {
      AppButtonVariant.outline => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary, width: 1.6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: padding,
            textStyle: textStyle,
          ),
          child: child,
        ),
      AppButtonVariant.secondary => FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.surfaceAlt,
            foregroundColor: AppTheme.textPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: padding,
            textStyle: textStyle,
            elevation: 0,
          ),
          child: child,
        ),
      AppButtonVariant.danger => FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: padding,
            textStyle: textStyle,
            elevation: 0,
          ),
          child: child,
        ),
      AppButtonVariant.primary => FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: padding,
            textStyle: textStyle,
            elevation: 0,
          ),
          child: child,
        ),
    };

    return SizedBox(width: fullWidth ? double.infinity : null, child: button);
  }
}
