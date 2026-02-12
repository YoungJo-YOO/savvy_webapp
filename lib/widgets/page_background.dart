import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class PageBackground extends StatelessWidget {
  const PageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
      child: child,
    );
  }
}
