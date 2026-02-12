import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../app/models.dart';
import '../app/tax_calculator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/labeled_input.dart';
import '../widgets/page_background.dart';
import '../widgets/progress_bar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;
  static const int _totalSteps = 3;

  late int _age;
  late int _annualIncomeManwon;
  late int _dependents;
  late bool _isMidYearJoiner;
  late bool _isFirstJobThisYear;
  late int _employmentStartMonth;
  late int _previousCompanyIncomeManwon;
  late int _previousCompanyPrepaidTaxManwon;
  late List<bool> _salaryPaidMonths;
  late SpecialSituations _specialSituations;

  late final TextEditingController _ageController;
  late final TextEditingController _incomeController;
  late final TextEditingController _previousIncomeController;
  late final TextEditingController _previousPrepaidTaxController;
  late final TextEditingController _religiousDonationController;
  late final TextEditingController _rentController;

  bool get _isSMEAgeEligible => _age >= 15 && _age <= 34;

  @override
  void initState() {
    super.initState();
    final profile = widget.appState.userProfile;
    final isEditMode = widget.appState.onboardingComplete;

    _age = isEditMode ? profile.age : 0;
    _annualIncomeManwon =
        isEditMode ? (profile.annualIncome / 10000).round() : 0;
    _dependents = isEditMode ? profile.dependents : 0;
    _isFirstJobThisYear = isEditMode ? profile.isFirstJobThisYear : true;
    _previousCompanyIncomeManwon =
        isEditMode ? (profile.previousCompanyIncome / 10000).round() : 0;
    _previousCompanyPrepaidTaxManwon =
        isEditMode ? (profile.previousCompanyPrepaidTax / 10000).round() : 0;
    _specialSituations =
        isEditMode ? profile.specialSituations : SpecialSituations.defaults();

    if (isEditMode) {
      final paidMonths = profile.currentMonth.clamp(0, 12);
      _isMidYearJoiner = paidMonths < 12;
      _employmentStartMonth =
          _isMidYearJoiner ? (13 - paidMonths).clamp(1, 12) : 1;
      _salaryPaidMonths = List<bool>.generate(
        12,
        (index) =>
            !_isMidYearJoiner ? true : index >= (_employmentStartMonth - 1),
      );
    } else {
      _isMidYearJoiner = false;
      _employmentStartMonth = DateTime.now().month;
      _salaryPaidMonths = List<bool>.filled(12, true);
    }

    _ageController = TextEditingController(
      text: _age > 0 ? _age.toString() : '',
    );
    _incomeController = TextEditingController(
      text: _annualIncomeManwon > 0 ? _annualIncomeManwon.toString() : '',
    );
    _previousIncomeController = TextEditingController(
      text:
          _previousCompanyIncomeManwon > 0
              ? _previousCompanyIncomeManwon.toString()
              : '',
    );
    _previousPrepaidTaxController = TextEditingController(
      text:
          _previousCompanyPrepaidTaxManwon > 0
              ? _previousCompanyPrepaidTaxManwon.toString()
              : '',
    );
    _religiousDonationController = TextEditingController(
      text:
          ((_specialSituations.monthlyReligiousDonation ?? 0) / 10000) > 0
              ? ((_specialSituations.monthlyReligiousDonation ?? 0) / 10000)
                  .round()
                  .toString()
              : '',
    );
    _rentController = TextEditingController(
      text:
          ((_specialSituations.monthlyRent ?? 0) / 10000) > 0
              ? ((_specialSituations.monthlyRent ?? 0) / 10000)
                  .round()
                  .toString()
              : '',
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    _previousIncomeController.dispose();
    _previousPrepaidTaxController.dispose();
    _religiousDonationController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      1 => '기본 정보',
      2 => '특수 상황',
      _ => '맞춤 추천',
    };

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        Text(
                          'Step $_step / $_totalSteps',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppProgressBar(
                      current: _step.toDouble(),
                      total: _totalSteps.toDouble(),
                      showPercentage: false,
                    ),
                    const SizedBox(height: 18),
                    AppCard(child: _buildStep()),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        if (_step > 1)
                          AppButton(
                            variant: AppButtonVariant.outline,
                            onPressed: () => setState(() => _step -= 1),
                            child: const Text('이전'),
                          ),
                        if (_step > 1) const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            fullWidth: true,
                            onPressed: _handleNext,
                            child: Text(
                              _step == _totalSteps ? '상세 입력 시작하기' : '다음',
                            ),
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
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      1 => _buildStepBasic(),
      2 => _buildStepSpecial(),
      _ => _buildStepResult(),
    };
  }

  Widget _buildStepBasic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('기본 정보를 입력해주세요', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          '중도 입사자 여부와 월별 급여 수령 여부를 함께 체크하면 더 현실적인 환급 계산이 가능합니다.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 18),
        LabeledInput(
          label: '나이',
          controller: _ageController,
          suffixText: '세',
          onChanged: (value) => _age = int.tryParse(value) ?? 0,
        ),
        const SizedBox(height: 12),
        LabeledInput(
          label: '연봉 (총급여)',
          controller: _incomeController,
          suffixText: '만원',
          helperText: '현재 회사 연봉 기준으로 입력되며, 급여 수령 개월 수로 자동 환산됩니다.',
          onChanged: (value) => _annualIncomeManwon = int.tryParse(value) ?? 0,
        ),
        if (_annualIncomeManwon > 0 &&
            (_annualIncomeManwon * (_paidSalaryMonthCount / 12.0)) <= 1400) ...<Widget>[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '현재 입력 기준으로 결정세액이 0원에 가까울 수 있습니다. '
              '추가 절세 소비보다 입력 정확도를 먼저 확인해 주세요.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '부양가족 수',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            _roundControlButton(
              icon: Icons.remove,
              onTap:
                  () => setState(
                    () => _dependents = (_dependents - 1).clamp(0, 99),
                  ),
            ),
            SizedBox(
              width: 72,
              child: Text(
                '$_dependents',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _roundControlButton(
              icon: Icons.add,
              onTap: () => setState(() => _dependents += 1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '본인 제외, 소득 요건을 충족하는 가족 수를 입력합니다.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text(
          '근무/급여 정보',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _isMidYearJoiner,
          onChanged: (value) {
            setState(() {
              _isMidYearJoiner = value;
              if (_isMidYearJoiner) {
                _employmentStartMonth = DateTime.now().month;
                _applyEmploymentStartMonth(_employmentStartMonth);
              } else {
                _salaryPaidMonths = List<bool>.filled(12, true);
                _isFirstJobThisYear = true;
                _resetPreviousCompanyInputs();
              }
            });
          },
          title: const Text('중도 입사자'),
          subtitle: Text(
            _isMidYearJoiner
                ? '입사월 기반으로 급여 지급 월을 자동 채울 수 있습니다.'
                : '월별 급여 수령 여부를 직접 체크할 수 있습니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (_isMidYearJoiner) ...<Widget>[
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _employmentStartMonth,
                  items: List<DropdownMenuItem<int>>.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem<int>(
                      value: month,
                      child: Text('입사월: $month월'),
                    );
                  }),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _employmentStartMonth = value;
                      _applyEmploymentStartMonth(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              AppButton(
                variant: AppButtonVariant.outline,
                onPressed:
                    () => setState(
                      () => _applyEmploymentStartMonth(_employmentStartMonth),
                    ),
                child: const Text('자동 채우기'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '연도 내 회사 이력',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          RadioListTile<bool>(
            contentPadding: EdgeInsets.zero,
            value: true,
            groupValue: _isFirstJobThisYear,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _isFirstJobThisYear = value;
                _resetPreviousCompanyInputs();
              });
            },
            title: const Text('올해 첫 직장입니다'),
          ),
          RadioListTile<bool>(
            contentPadding: EdgeInsets.zero,
            value: false,
            groupValue: _isFirstJobThisYear,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _isFirstJobThisYear = value);
            },
            title: const Text('이전 회사에서 이직했습니다'),
          ),
          if (!_isFirstJobThisYear) ...<Widget>[
            const SizedBox(height: 8),
            LabeledInput(
              label: '이전 회사 총급여',
              controller: _previousIncomeController,
              suffixText: '만원',
              helperText: '해당 연도 내 이전 직장의 총급여를 입력해 주세요.',
              onChanged:
                  (value) =>
                      _previousCompanyIncomeManwon = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 12),
            LabeledInput(
              label: '이전 회사 기납부세액',
              controller: _previousPrepaidTaxController,
              suffixText: '만원',
              helperText: '원천징수영수증의 기납부세액을 입력해 주세요.',
              onChanged:
                  (value) =>
                      _previousCompanyPrepaidTaxManwon =
                          int.tryParse(value) ?? 0,
            ),
          ],
        ],
        const SizedBox(height: 10),
        Text(
          '월별 급여 수령 여부',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (_isMidYearJoiner && !_isFirstJobThisYear)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '월별 급여 수령 여부는 현재 회사 기준으로 체크해 주세요.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(12, (index) {
            final month = index + 1;
            final selected = _salaryPaidMonths[index];
            return FilterChip(
              label: Text('$month월'),
              selected: selected,
              onSelected:
                  (value) => setState(() => _salaryPaidMonths[index] = value),
              selectedColor: AppTheme.primaryLight,
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '급여 수령 개월 수: $_paidSalaryMonthCount개월',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepSpecial() {
    final smeDescription =
        _isSMEAgeEligible
            ? '만 15~34세 중소기업 근로자'
            : '만 15~34세에만 해당되어 현재는 선택할 수 없습니다.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('해당하는 항목을 선택해주세요', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          '선택한 조건을 기반으로 맞춤 공제 전략을 제공합니다.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 14),
        _checkboxTile(
          label: '중소기업 청년 소득세 감면 대상',
          description: smeDescription,
          value: _specialSituations.isSMEYouthTaxReduction,
          enabled: _isSMEAgeEligible,
          onChanged: (value) {
            setState(() {
              _specialSituations = _specialSituations.copyWith(
                isSMEYouthTaxReduction: value,
              );
            });
          },
        ),
        _checkboxTile(
          label: '종교단체 기부금 납부',
          value: _specialSituations.hasReligiousDonation,
          onChanged: (value) {
            setState(() {
              _specialSituations = _specialSituations.copyWith(
                hasReligiousDonation: value,
                clearMonthlyReligiousDonation: !value,
              );
            });
          },
        ),
        if (_specialSituations.hasReligiousDonation) ...<Widget>[
          const SizedBox(height: 10),
          LabeledInput(
            label: '월 기부금',
            controller: _religiousDonationController,
            suffixText: '만원',
            helperText: '입력한 금액은 급여 수령 개월 수 기준으로 연간 환산되어 자동 반영됩니다.',
            onChanged: (value) {
              final manwon = double.tryParse(value) ?? 0;
              _specialSituations = _specialSituations.copyWith(
                monthlyReligiousDonation: manwon * 10000,
              );
            },
          ),
        ],
        _checkboxTile(
          label: '월세 납부 중 (무주택 세대주)',
          value: _specialSituations.hasRent,
          onChanged: (value) {
            setState(() {
              _specialSituations = _specialSituations.copyWith(
                hasRent: value,
                clearMonthlyRent: !value,
              );
            });
          },
        ),
        if (_specialSituations.hasRent) ...<Widget>[
          const SizedBox(height: 10),
          LabeledInput(
            label: '월세',
            controller: _rentController,
            suffixText: '만원',
            helperText: '입력한 금액은 급여 수령 개월 수 기준으로 연간 환산되어 자동 반영됩니다.',
            onChanged: (value) {
              final manwon = double.tryParse(value) ?? 0;
              _specialSituations = _specialSituations.copyWith(
                monthlyRent: manwon * 10000,
              );
            },
          ),
        ],
        _checkboxTile(
          label: '자녀가 있음',
          description: '자녀 세액공제 대상',
          value: _specialSituations.hasChildren,
          onChanged:
              (value) => setState(
                () =>
                    _specialSituations = _specialSituations.copyWith(
                      hasChildren: value,
                    ),
              ),
        ),
        _checkboxTile(
          label: '장애인 부양가족이 있음',
          value: _specialSituations.hasDisabledDependent,
          onChanged:
              (value) => setState(
                () =>
                    _specialSituations = _specialSituations.copyWith(
                      hasDisabledDependent: value,
                    ),
              ),
        ),
        _checkboxTile(
          label: '경로우대(70세 이상) 부양가족이 있음',
          value: _specialSituations.hasElderlyDependent,
          onChanged:
              (value) => setState(
                () =>
                    _specialSituations = _specialSituations.copyWith(
                      hasElderlyDependent: value,
                    ),
              ),
        ),
      ],
    );
  }

  Widget _buildStepResult() {
    final recommendations = _buildRecommendations();
    final topRecommendation =
        recommendations.isEmpty ? null : recommendations.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 12),
              Text('맞춤 분석 완료', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                '적용 가능한 공제 항목을 확인했습니다.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[AppTheme.primary, Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('우선순위 분석', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                topRecommendation == null ? '추천 항목 없음' : topRecommendation.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (topRecommendation != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  topRecommendation.description,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('우선순위 추천 항목', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ...recommendations.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final item = entry.value;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        '우선순위 $rank',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '점수 ${item.priority}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _checkboxTile({
    required String label,
    String? description,
    required bool value,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: enabled ? (checked) => onChanged(checked ?? false) : null,
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: enabled ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
        subtitle:
            description == null
                ? null
                : Text(
                  description,
                  style: TextStyle(
                    color: enabled ? AppTheme.textMuted : AppTheme.warning,
                  ),
                ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _roundControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.primary, width: 1.4),
        ),
        child: Icon(icon, color: AppTheme.primary),
      ),
    );
  }

  int get _paidSalaryMonthCount =>
      _salaryPaidMonths.where((paid) => paid).length;

  List<_RecommendationItem> _buildRecommendations() {
    final currentCompanyIncome =
        _annualIncomeManwon * 10000.0 * (_paidSalaryMonthCount / 12.0);
    final hasPreviousCompany = _isMidYearJoiner && !_isFirstJobThisYear;
    final previousIncome =
        hasPreviousCompany ? _previousCompanyIncomeManwon * 10000.0 : 0.0;
    final effectiveAnnualIncome = math.max(
      currentCompanyIncome + previousIncome,
      0.0,
    );
    final cardUsage = widget.appState.taxData.cardUsage;
    final currentCardUsage =
        cardUsage.creditCard + cardUsage.debitCard + cardUsage.cashReceipt;
    final cardThreshold = effectiveAnnualIncome * 0.25;
    final cardGap = math.max(cardThreshold - currentCardUsage, 0.0);
    final pensionTotal =
        widget.appState.taxData.pension.pensionSavings +
        widget.appState.taxData.pension.irp;
    final pensionRemaining = math.max(7000000.0 - pensionTotal, 0.0);
    final monthlyDonation =
        (double.tryParse(_religiousDonationController.text.trim()) ?? 0) * 10000;
    final annualDonation =
        _specialSituations.hasReligiousDonation
            ? monthlyDonation * _paidSalaryMonthCount
            : 0.0;
    final monthlyRent =
        (double.tryParse(_rentController.text.trim()) ?? 0) * 10000;
    final annualRent =
        _specialSituations.hasRent ? monthlyRent * _paidSalaryMonthCount : 0.0;

    final items = <_RecommendationItem>[
      if (_specialSituations.isSMEYouthTaxReduction && _isSMEAgeEligible)
        const _RecommendationItem(
          title: '중소기업 청년 소득세 감면',
          description: '산출세액의 90% 감면이 적용되며 자동 반영됩니다.',
          priority: 100,
        ),
      _RecommendationItem(
        title: '신용/체크카드 소득공제',
        description:
            cardGap > 0
                ? '공제 문턱까지 ${TaxCalculator.formatCurrency(cardGap)} 남았습니다. '
                    '체크카드 사용을 우선 추천합니다.'
                : '공제 문턱을 이미 충족했습니다. 남은 지출은 체크카드/현금영수증 위주가 유리합니다.',
        priority: cardGap > 0 ? 90 : 70,
      ),
      _RecommendationItem(
        title: '연금저축 세액공제',
        description:
            pensionRemaining > 0
                ? '연금/IRP 한도까지 ${TaxCalculator.formatCurrency(pensionRemaining)} 추가 납입 여지가 있습니다.'
                : '연금저축 공제 한도를 이미 충분히 활용하고 있습니다.',
        priority: pensionRemaining > 0 ? 88 : 55,
      ),
      if (_specialSituations.hasReligiousDonation)
        _RecommendationItem(
          title: '종교단체 기부금 세액공제',
          description:
              '현재 입력 기준 연간 기부액은 ${TaxCalculator.formatCurrency(annualDonation)}입니다.',
          priority: annualDonation > 0 ? 78 : 58,
        ),
      _RecommendationItem(
        title: '주택청약/월세 반영',
        description:
            annualRent > 0
                ? '월세 입력액 ${TaxCalculator.formatCurrency(annualRent)}이 공제 계산에 반영됩니다.'
                : '주택청약/월세 항목은 공제 효과가 큰 편이므로 해당 여부를 확인하세요.',
        priority: annualRent > 0 ? 75 : 62,
      ),
      if (_specialSituations.hasChildren ||
          _specialSituations.hasDisabledDependent ||
          _specialSituations.hasElderlyDependent)
        const _RecommendationItem(
          title: '인적공제 대상 확인',
          description: '부양가족 정보에 따라 인적공제가 반영되므로 입력값을 다시 확인해 주세요.',
          priority: 74,
        ),
    ];

    items.sort((a, b) => b.priority.compareTo(a.priority));
    return items.take(8).toList();
  }

  void _applyEmploymentStartMonth(int startMonth) {
    _salaryPaidMonths = List<bool>.generate(
      12,
      (index) => index >= startMonth - 1,
    );
  }

  void _handleNext() {
    _age = int.tryParse(_ageController.text.trim()) ?? 0;
    _annualIncomeManwon = int.tryParse(_incomeController.text.trim()) ?? 0;
    _previousCompanyIncomeManwon =
        int.tryParse(_previousIncomeController.text.trim()) ?? 0;
    _previousCompanyPrepaidTaxManwon =
        int.tryParse(_previousPrepaidTaxController.text.trim()) ?? 0;

    if (_step == 1) {
      if (_age < 19 || _age > 65) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('나이는 19세 이상 65세 이하로 입력해 주세요.')),
        );
        return;
      }
      if (_age <= 0 || _annualIncomeManwon <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('나이와 연봉은 필수 입력 항목입니다.')));
        return;
      }
      if (_paidSalaryMonthCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최소 1개월 이상 급여 수령 월을 선택해 주세요.')),
        );
        return;
      }
      if (_isMidYearJoiner &&
          !_isFirstJobThisYear &&
          _previousCompanyIncomeManwon <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이직한 경우 이전 회사 총급여를 입력해 주세요.')),
        );
        return;
      }
      if (_isMidYearJoiner &&
          !_isFirstJobThisYear &&
          _previousCompanyPrepaidTaxManwon < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이전 회사 기납부세액은 0 이상으로 입력해 주세요.')),
        );
        return;
      }
    }

    if (_step == 2 && !_isSMEAgeEligible) {
      _specialSituations = _specialSituations.copyWith(
        isSMEYouthTaxReduction: false,
      );
    }

    if (_step < _totalSteps) {
      setState(() => _step += 1);
      return;
    }

    final monthlyReligiousWon =
        _specialSituations.hasReligiousDonation
            ? ((double.tryParse(_religiousDonationController.text.trim()) ??
                    0) *
                10000)
            : 0.0;
    final monthlyRentWon =
        _specialSituations.hasRent
            ? ((double.tryParse(_rentController.text.trim()) ?? 0) * 10000)
            : 0.0;
    final paidMonths = _paidSalaryMonthCount;
    final isFirstJobThisYear = _isMidYearJoiner ? _isFirstJobThisYear : true;
    final previousCompanyIncomeWon =
        (_isMidYearJoiner && !_isFirstJobThisYear)
            ? _previousCompanyIncomeManwon * 10000.0
            : 0.0;
    final previousCompanyPrepaidTaxWon =
        (_isMidYearJoiner && !_isFirstJobThisYear)
            ? _previousCompanyPrepaidTaxManwon * 10000.0
            : 0.0;

    final updatedProfile = widget.appState.userProfile.copyWith(
      age: _age,
      annualIncome: _annualIncomeManwon * 10000,
      dependents: _dependents,
      currentMonth: paidMonths,
      isFirstJobThisYear: isFirstJobThisYear,
      previousCompanyIncome: previousCompanyIncomeWon,
      previousCompanyPrepaidTax: previousCompanyPrepaidTaxWon,
      specialSituations: _specialSituations.copyWith(
        monthlyReligiousDonation:
            _specialSituations.hasReligiousDonation
                ? monthlyReligiousWon
                : null,
        clearMonthlyReligiousDonation: !_specialSituations.hasReligiousDonation,
        monthlyRent: _specialSituations.hasRent ? monthlyRentWon : null,
        clearMonthlyRent: !_specialSituations.hasRent,
      ),
    );

    widget.appState.updateUserProfile(updatedProfile);

    final currentTaxData = widget.appState.taxData;
    widget.appState.updateTaxData(
      donations: currentTaxData.donations.copyWith(
        religious:
            _specialSituations.hasReligiousDonation
                ? monthlyReligiousWon * paidMonths
                : 0,
      ),
      housing: currentTaxData.housing.copyWith(
        monthlyRent:
            _specialSituations.hasRent ? monthlyRentWon * paidMonths : 0,
      ),
    );

    widget.appState.setOnboardingComplete(true);
  }

  void _resetPreviousCompanyInputs() {
    _previousCompanyIncomeManwon = 0;
    _previousCompanyPrepaidTaxManwon = 0;
    _previousIncomeController.clear();
    _previousPrepaidTaxController.clear();
  }
}

class _RecommendationItem {
  const _RecommendationItem({
    required this.title,
    required this.description,
    required this.priority,
  });

  final String title;
  final String description;
  final int priority;
}
