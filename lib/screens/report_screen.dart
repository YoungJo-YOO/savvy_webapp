import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_screen.dart';
import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../app/tax_calculator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/page_background.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final result = appState.taxResult;
    if (result == null) {
      return const Scaffold(
        body: PageBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final breakdown = <_Section>[
      _Section(
        title: '소득공제',
        rows: <_RowItem>[
          _RowItem(
            name: '신용/체크카드',
            amount: appState.taxData.cardUsage.creditCard +
                appState.taxData.cardUsage.debitCard +
                appState.taxData.cardUsage.cashReceipt,
            deduction: result.taxDeductions.cardUsage,
          ),
          _RowItem(
            name: '주택청약',
            amount: appState.taxData.housing.housingSubscription,
            deduction: result.taxDeductions.housingSubscription,
          ),
        ],
      ),
      _Section(
        title: '세액공제',
        rows: <_RowItem>[
          _RowItem(
            name: '연금저축/IRP',
            amount: appState.taxData.pension.pensionSavings + appState.taxData.pension.irp,
            deduction: result.taxDeductions.pension,
          ),
          _RowItem(
            name: '기부금',
            amount: appState.taxData.donations.religious +
                appState.taxData.donations.political +
                appState.taxData.donations.general,
            deduction: result.taxDeductions.religiousDonation,
          ),
        ],
      ),
      if (result.smeReduction > 0)
        _Section(
          title: '세액감면',
          rows: <_RowItem>[
            _RowItem(name: '중소기업 청년 감면', amount: 0, deduction: result.smeReduction),
          ],
        ),
    ];

    final optimizationTips = _buildOptimizationTips();

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _ReportHeader(
                onBack: () => appState.setCurrentScreen(AppScreen.dashboard),
                onDownload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF 다운로드는 다음 단계에서 연결할 수 있습니다.')),
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${DateTime.now().year}년 연말정산 리포트',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '생성일: ${DateFormat('yyyy.MM.dd').format(DateTime.now())}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppCard(
                            child: Column(
                              children: <Widget>[
                                const Icon(Icons.trending_up, color: AppTheme.primary, size: 36),
                                const SizedBox(height: 8),
                                Text('예상 환급액', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text(
                                  TaxCalculator.formatCurrency(result.refundAmount > 0 ? result.refundAmount : 0),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppTheme.primary),
                                ),
                                if (result.refundAmount <= 0) ...<Widget>[
                                  const SizedBox(height: 6),
                                  Text(
                                    '추가 납부 예상: ${TaxCalculator.formatCurrency(result.refundAmount.abs())}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.danger),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('공제 상세 내역', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 12),
                                ...breakdown.map((section) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          section.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 8),
                                        ...section.rows.where((row) => row.amount > 0 || row.deduction > 0).map((row) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(row.name),
                                                      if (row.amount > 0)
                                                        Text(
                                                          '납입액 ${TaxCalculator.formatCurrency(row.amount)}',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(color: AppTheme.textMuted),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  TaxCalculator.formatCurrency(row.deduction),
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: AppTheme.primary,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '총 공제/감면',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const Spacer(),
                                    Text(
                                      TaxCalculator.formatCurrency(
                                        result.taxDeductions.total + result.smeReduction,
                                      ),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w800,
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
                                Text('세금 계산 과정', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 10),
                                _calcRow(context, '총급여', appState.userProfile.annualIncome),
                                _calcRow(context, '과세표준', result.taxableIncome),
                                _calcRow(context, '산출세액', result.calculatedTax),
                                if (result.smeReduction > 0)
                                  _calcRow(context, '중소기업 감면', -result.smeReduction, highlight: AppTheme.success),
                                _calcRow(context, '세액공제 합계', -result.taxDeductions.total, highlight: AppTheme.success),
                                _calcRow(context, '결정세액', result.finalTax),
                                _calcRow(context, '기납부세액(추정)', result.prepaidTax),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Text('최종 환급액', style: Theme.of(context).textTheme.titleMedium),
                                    const Spacer(),
                                    Text(
                                      TaxCalculator.formatCurrency(result.refundAmount > 0 ? result.refundAmount : 0),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (optimizationTips.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 12),
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('추가 최적화 제안', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 10),
                                  ...optimizationTips.map((tip) {
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text(
                                            tip.description,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '+ ${TaxCalculator.formatCurrency(tip.benefit)}',
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: AppButton(
                                  variant: AppButtonVariant.outline,
                                  onPressed: () => appState.setCurrentScreen(AppScreen.dashboard),
                                  child: const Text('대시보드로'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  fullWidth: true,
                                  onPressed: () => appState.setCurrentScreen(AppScreen.cardAnalysis),
                                  child: const Text('카드 사용 최적화'),
                                ),
                              ),
                            ],
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

  List<_OptimizationTip> _buildOptimizationTips() {
    final profile = appState.userProfile;
    final taxData = appState.taxData;
    final tips = <_OptimizationTip>[];

    final currentPension = taxData.pension.pensionSavings + taxData.pension.irp;
    if (currentPension < 4000000) {
      final additional = 4000000 - currentPension;
      final rate = profile.annualIncome <= 55000000 ? 0.165 : 0.132;
      tips.add(
        _OptimizationTip(
          title: '연금저축 한도 채우기',
          description: '연금저축에 ${TaxCalculator.formatMillions(additional)} 추가 납입 시',
          benefit: additional * rate,
        ),
      );
    }

    if (taxData.housing.housingSubscription < 2400000) {
      final additional = 2400000 - taxData.housing.housingSubscription;
      tips.add(
        _OptimizationTip(
          title: '주택청약 한도 채우기',
          description: '주택청약에 ${TaxCalculator.formatMillions(additional)} 추가 납입 시',
          benefit: additional * 0.4,
        ),
      );
    }

    return tips;
  }

  Widget _calcRow(
    BuildContext context,
    String label,
    double value, {
    Color? highlight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted)),
          const Spacer(),
          Text(
            '${value < 0 ? '-' : ''}${TaxCalculator.formatCurrency(value.abs())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: highlight ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.onBack, required this.onDownload});

  final VoidCallback onBack;
  final VoidCallback onDownload;

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
          constraints: const BoxConstraints(maxWidth: 920),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Text('종합 리포트', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: const Text('PDF 다운로드'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_RowItem> rows;
}

class _RowItem {
  const _RowItem({
    required this.name,
    required this.amount,
    required this.deduction,
  });

  final String name;
  final double amount;
  final double deduction;
}

class _OptimizationTip {
  const _OptimizationTip({
    required this.title,
    required this.description,
    required this.benefit,
  });

  final String title;
  final String description;
  final double benefit;
}
