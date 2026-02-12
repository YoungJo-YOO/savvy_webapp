import 'package:flutter/material.dart';

import '../app/app_screen.dart';
import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../app/tax_calculator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/page_background.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final profile = appState.userProfile;
    final situations = profile.specialSituations;
    final tags = <String>[
      if (situations.isSMEYouthTaxReduction) '중소기업 청년 소득세 감면',
      if (situations.hasReligiousDonation) '종교단체 기부금 납부',
      if (situations.hasRent) '월세 납부',
      if (situations.hasChildren) '자녀 있음',
      if (situations.hasDisabledDependent) '장애인 부양가족',
      if (situations.hasElderlyDependent) '경로우대 부양가족',
    ];

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(onBack: () => appState.setCurrentScreen(AppScreen.dashboard)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Icon(Icons.person, color: AppTheme.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('사용자님', style: Theme.of(context).textTheme.titleLarge),
                                          Text(
                                            '${profile.age}세 · 연봉 ${TaxCalculator.formatMillions(profile.annualIncome)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _MetricCard(
                                        label: '부양가족',
                                        value: '${profile.dependents}명',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _MetricCard(
                                        label: '현재 월',
                                        value: '${profile.currentMonth}월',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(Icons.settings, size: 18),
                                    const SizedBox(width: 6),
                                    Text('특수 상황', style: Theme.of(context).textTheme.titleMedium),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (tags.isEmpty)
                                  Text(
                                    '설정된 특수 상황이 없습니다.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  )
                                else
                                  ...tags.map((String tag) {
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(tag)),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ActionTile(
                            icon: Icons.edit_outlined,
                            title: '기본 정보 수정',
                            subtitle: '나이, 연봉, 부양가족 정보 변경',
                            onTap: () => appState.setCurrentScreen(AppScreen.onboarding),
                          ),
                          const SizedBox(height: 10),
                          _ActionTile(
                            icon: Icons.delete_outline,
                            title: '데이터 초기화',
                            subtitle: '입력한 데이터 전체 삭제',
                            danger: true,
                            onTap: () => _showResetDialog(context),
                          ),
                          const SizedBox(height: 12),
                          AppCard(
                            child: Column(
                              children: <Widget>[
                                Text('Savvy · 연말정산 최적화 도구', style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 4),
                                Text('버전 1.0.0', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 6),
                                Text(
                                  '표시되는 금액은 예측치이며 실제 결과와 차이가 있을 수 있습니다.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            fullWidth: true,
                            variant: AppButtonVariant.outline,
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

  void _showResetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('데이터 초기화'),
          content: const Text('입력한 모든 데이터가 삭제됩니다.\n정말 초기화할까요?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                appState.resetAllData();
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

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
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Text('마이페이지', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.danger : AppTheme.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: danger ? AppTheme.danger : null,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
