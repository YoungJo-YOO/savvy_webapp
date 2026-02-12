import 'package:flutter/material.dart';

import '../app/app_screen.dart';
import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../app/tax_calculator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/page_background.dart';
import '../widgets/tax_item_editor_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final taxResult = appState.taxResult;
    if (taxResult == null) {
      return const Scaffold(
        body: PageBackground(child: Center(child: CircularProgressIndicator())),
      );
    }
    final refundAmount = taxResult.refundAmount;
    final isRefund = refundAmount >= 0;
    final summaryLabel = isRefund ? '예상 환급액' : '예상 추가 납부액';
    final summaryColor = isRefund ? AppTheme.success : AppTheme.danger;

    final taxItems = <_TaxItem>[
      _TaxItem(
        id: 'card',
        title: '신용/체크카드',
        description: '카드 사용에 따른 소득공제',
        icon: Icons.credit_card,
        currentValue:
            appState.taxData.cardUsage.creditCard +
            appState.taxData.cardUsage.debitCard +
            appState.taxData.cardUsage.cashReceipt,
        estimatedDeduction: taxResult.taxDeductions.cardUsage,
        categoryLabel: '소득공제',
      ),
      _TaxItem(
        id: 'pension',
        title: '연금저축',
        description: '노후준비 + 세액공제',
        icon: Icons.savings,
        currentValue:
            appState.taxData.pension.pensionSavings +
            appState.taxData.pension.irp,
        estimatedDeduction: taxResult.taxDeductions.pension,
        categoryLabel: '세액공제',
      ),
      _TaxItem(
        id: 'donation',
        title: '기부금',
        description: '종교/정치/일반 기부금',
        icon: Icons.favorite_border,
        currentValue:
            appState.taxData.donations.religious +
            appState.taxData.donations.political +
            appState.taxData.donations.general,
        estimatedDeduction: taxResult.taxDeductions.religiousDonation,
        categoryLabel: '세액공제',
      ),
      _TaxItem(
        id: 'housing',
        title: '주택청약',
        description: '주택청약/월세 주거 공제',
        icon: Icons.home_outlined,
        currentValue:
            appState.taxData.housing.housingSubscription +
            appState.taxData.housing.monthlyRent,
        estimatedDeduction: taxResult.taxDeductions.housingSubscription,
        categoryLabel: '소득공제',
      ),
      _TaxItem(
        id: 'medical_education',
        title: '의료비/교육비',
        description: '특별세액공제 항목',
        icon: Icons.medical_information_outlined,
        currentValue:
            appState.taxData.medicalEducation.medical +
            appState.taxData.medicalEducation.education,
        estimatedDeduction: taxResult.taxDeductions.medicalEducationTaxCredit,
        categoryLabel: '세액공제',
      ),
    ];

    if (appState.userProfile.specialSituations.isSMEYouthTaxReduction &&
        appState.userProfile.age <= 34) {
      taxItems.insert(
        0,
        _TaxItem(
          id: 'sme',
          title: '중소기업 청년 감면',
          description: '소득세 90% 자동 감면',
          icon: Icons.apartment_outlined,
          currentValue: taxResult.smeReduction,
          estimatedDeduction: taxResult.smeReduction,
          categoryLabel: '세액감면',
        ),
      );
    }

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _DashboardNav(
                current: AppScreen.dashboard,
                onTap: appState.setCurrentScreen,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppCard(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  summaryLabel,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      TaxCalculator.formatCurrency(
                                        refundAmount.abs(),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(color: summaryColor),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      isRefund
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      color: summaryColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '급여 수령 ${appState.userProfile.currentMonth}개월 기준',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (taxResult.finalTax <= 0) ...<Widget>[
                                  const SizedBox(height: 8),
                                  Text(
                                    '결정세액은 최소 0원으로 처리됩니다. 공제액이 산출세액보다 커도 결정세액은 음수가 되지 않습니다.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppTheme.textMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                if (taxResult.smeReduction > 0) ...<Widget>[
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '중소기업 감면 적용 중: ${TaxCalculator.formatCurrency(taxResult.smeReduction)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '절세 항목',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              final columns =
                                  constraints.maxWidth >= 980
                                      ? 3
                                      : (constraints.maxWidth >= 640 ? 2 : 1);
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: taxItems.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 1.58,
                                    ),
                                itemBuilder: (BuildContext context, int index) {
                                  final item = taxItems[index];
                                  return AppCard(
                                    onTap: () => _openItem(context, item.id),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLight,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            item.icon,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                item.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.description,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (item.id != 'sme')
                                                Text(
                                                  '현재 ${TaxCalculator.formatMillions(item.currentValue)}',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.bodySmall,
                                                ),
                                              const SizedBox(height: 2),
                                              Text.rich(
                                                TextSpan(
                                                  text:
                                                      TaxCalculator.formatCurrency(
                                                        item.estimatedDeduction,
                                                      ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: AppTheme.primary,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                      text:
                                                          ' ${item.categoryLabel}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                AppTheme
                                                                    .textMuted,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          AppButton(
                            fullWidth: true,
                            onPressed:
                                () =>
                                    appState.setCurrentScreen(AppScreen.report),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.description_outlined),
                                SizedBox(width: 8),
                                Text('종합 리포트 보기'),
                              ],
                            ),
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

  void _openItem(BuildContext context, String itemId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return TaxItemEditorDialog(itemId: itemId, appState: appState);
      },
    );
  }
}

class _DashboardNav extends StatelessWidget {
  const _DashboardNav({required this.current, required this.onTap});

  final AppScreen current;
  final ValueChanged<AppScreen> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onTap(AppScreen.landing),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      'Savvy',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: AppTheme.primary),
                    ),
                  ),
                ),
                const Spacer(),
                _NavItem(
                  label: '대시보드',
                  active: current == AppScreen.dashboard,
                  onTap: () => onTap(AppScreen.dashboard),
                ),
                _NavItem(
                  label: '카드분석',
                  active: current == AppScreen.cardAnalysis,
                  onTap: () => onTap(AppScreen.cardAnalysis),
                ),
                _NavItem(
                  label: '리포트',
                  active: current == AppScreen.report,
                  onTap: () => onTap(AppScreen.report),
                ),
                IconButton(
                  onPressed: () => onTap(AppScreen.myPage),
                  icon: const Icon(Icons.person_outline),
                  color:
                      current == AppScreen.myPage
                          ? AppTheme.primary
                          : AppTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppTheme.primary : AppTheme.textMuted,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _TaxItem {
  const _TaxItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.currentValue,
    required this.estimatedDeduction,
    required this.categoryLabel,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final double currentValue;
  final double estimatedDeduction;
  final String categoryLabel;
}
