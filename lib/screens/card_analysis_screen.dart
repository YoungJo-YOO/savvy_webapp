import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_screen.dart';
import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../app/tax_calculator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/page_background.dart';
import '../widgets/progress_bar.dart';

class CardAnalysisScreen extends StatelessWidget {
  const CardAnalysisScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final profile = appState.userProfile;
    final usage = appState.taxData.cardUsage;
    final totalUsage = usage.creditCard + usage.debitCard + usage.cashReceipt;
    final minUsage = profile.annualIncome * 0.25;
    final progress = totalUsage / math.max(minUsage, 1.0);

    final remainingMonths = 12 - profile.currentMonth;
    final recommendedMonthlySpending = remainingMonths > 0
        ? math.max(0.0, (minUsage - totalUsage) / remainingMonths)
        : 0.0;

    final rows = <_UsageRow>[
      _UsageRow(
        label: '신용카드',
        deductionRate: '15%',
        value: usage.creditCard,
        color: const Color(0xFF1E88E5),
      ),
      _UsageRow(
        label: '체크카드',
        deductionRate: '30%',
        value: usage.debitCard,
        color: const Color(0xFF42A5F5),
      ),
      _UsageRow(
        label: '현금영수증',
        deductionRate: '30%',
        value: usage.cashReceipt,
        color: const Color(0xFF90CAF9),
      ),
    ];

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _SimpleHeader(
                title: '카드 사용 분석',
                onBack: () => appState.setCurrentScreen(AppScreen.dashboard),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('공제 기준 달성률', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 12),
                                Row(
                                  children: <Widget>[
                                    Text('총급여의 25% 기준', style: Theme.of(context).textTheme.bodyMedium),
                                    const Spacer(),
                                    Text(
                                      TaxCalculator.formatCurrency(minUsage),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AppProgressBar(
                                  current: totalUsage,
                                  total: minUsage,
                                  tone: progress >= 1
                                      ? ProgressTone.success
                                      : (progress >= 0.5
                                          ? ProgressTone.warning
                                          : ProgressTone.danger),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '현재 사용액: ${TaxCalculator.formatCurrency(totalUsage)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      progress >= 1
                                          ? '목표 달성'
                                          : '${TaxCalculator.formatCurrency(minUsage - totalUsage)} 남음',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: progress >= 1
                                        ? AppTheme.primaryLight
                                        : const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    progress >= 1
                                        ? '공제 기준을 넘겼습니다. 남은 기간에는 체크카드/현금영수증 비중을 높이세요.'
                                        : '앞으로 $remainingMonths개월 동안 월 ${TaxCalculator.formatMillions(recommendedMonthlySpending)} 사용 시 기준을 충족할 수 있습니다.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('사용 비율', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 10),
                                ...rows.map((row) {
                                  final ratio = totalUsage > 0 ? row.value / totalUsage : 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: row.color,
                                                borderRadius: BorderRadius.circular(99),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(row.label),
                                            const SizedBox(width: 6),
                                            Text(
                                              '공제율 ${row.deductionRate}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(color: AppTheme.textMuted),
                                            ),
                                            const Spacer(),
                                            Text(
                                              TaxCalculator.formatCurrency(row.value),
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(999),
                                          child: LinearProgressIndicator(
                                            minHeight: 8,
                                            value: ratio,
                                            color: row.color,
                                            backgroundColor: const Color(0xFFEFF5FA),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('최적화 가이드', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 10),
                                _tipCard(
                                  context,
                                  icon: progress >= 1 ? Icons.check_circle : Icons.flag,
                                  title: progress >= 1 ? '기준 충족 완료' : '우선 기준 충족',
                                  body: progress >= 1
                                      ? '현재 기준을 넘겼으므로 남은 결제는 공제율이 높은 수단(체크카드/현금영수증) 중심으로 사용하세요.'
                                      : '먼저 총급여의 25% 기준을 채워야 카드 소득공제가 적용됩니다.',
                                ),
                                if (remainingMonths > 0)
                                  _tipCard(
                                    context,
                                    icon: Icons.calendar_month,
                                    title: '월별 목표',
                                    body:
                                        '남은 $remainingMonths개월 동안 월 ${TaxCalculator.formatMillions(recommendedMonthlySpending)} 사용을 목표로 설정하세요.',
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            fullWidth: true,
                            onPressed: () => appState.setCurrentScreen(AppScreen.dashboard),
                            child: const Text('대시보드로 돌아가기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageRow {
  const _UsageRow({
    required this.label,
    required this.deductionRate,
    required this.value,
    required this.color,
  });

  final String label;
  final String deductionRate;
  final double value;
  final Color color;
}
