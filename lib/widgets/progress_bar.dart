import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_theme.dart';

enum ProgressTone { primary, success, warning, danger }

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.label,
    this.showPercentage = true,
    this.tone = ProgressTone.primary,
  });

  final double current;
  final double total;
  final String? label;
  final bool showPercentage;
  final ProgressTone tone;

  @override
  Widget build(BuildContext context) {
    final safeTotal = total <= 0 ? 1.0 : total;
    final percent = math.min(current / safeTotal, 1.0).clamp(0.0, 1.0);
    final color = switch (tone) {
      ProgressTone.primary => AppTheme.primary,
      ProgressTone.success => AppTheme.success,
      ProgressTone.warning => AppTheme.warning,
      ProgressTone.danger => AppTheme.danger,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Row(
            children: <Widget>[
              Text(
                label!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textMuted),
              ),
              const Spacer(),
              if (showPercentage)
                Text(
                  '${(percent * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: percent,
            color: color,
            backgroundColor: const Color(0xFFEFF5FA),
          ),
        ),
      ],
    );
  }
}
