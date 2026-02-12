import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../app/models.dart';
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
  late int _employmentStartMonth;
  late List<bool> _salaryPaidMonths;
  late SpecialSituations _specialSituations;

  late final TextEditingController _ageController;
  late final TextEditingController _incomeController;
  late final TextEditingController _religiousDonationController;
  late final TextEditingController _rentController;

  @override
  void initState() {
    super.initState();
    final profile = widget.appState.userProfile;
    _age = profile.age;
    _annualIncomeManwon = (profile.annualIncome / 10000).round();
    _dependents = profile.dependents;
    _specialSituations = profile.specialSituations;

    final paidMonths = profile.currentMonth.clamp(0, 12);
    _isMidYearJoiner = paidMonths < 12;
    _employmentStartMonth =
        _isMidYearJoiner ? (13 - paidMonths).clamp(1, 12) : 1;
    _salaryPaidMonths = List<bool>.generate(
      12,
      (index) =>
          !_isMidYearJoiner ? true : index >= (_employmentStartMonth - 1),
    );

    _ageController = TextEditingController(text: _age.toString());
    _incomeController = TextEditingController(
      text: _annualIncomeManwon.toString(),
    );
    _religiousDonationController = TextEditingController(
      text:
          ((_specialSituations.monthlyReligiousDonation ?? 0) / 10000)
              .round()
              .toString(),
    );
    _rentController = TextEditingController(
      text: ((_specialSituations.monthlyRent ?? 0) / 10000).round().toString(),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
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
          helperText: '세전 총급여 기준으로 입력해 주세요.',
          onChanged: (value) => _annualIncomeManwon = int.tryParse(value) ?? 0,
        ),
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
        ],
        const SizedBox(height: 10),
        Text(
          '월별 급여 수령 여부',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
          description: '만 15~34세 중소기업 근로자',
          value: _specialSituations.isSMEYouthTaxReduction,
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
    final chips = <String>[
      if (_specialSituations.isSMEYouthTaxReduction && _age <= 34)
        '중소기업 청년 소득세 감면 (90%)',
      '신용/체크카드 소득공제',
      '연금저축 세액공제',
      if (_specialSituations.hasReligiousDonation) '종교단체 기부금 세액공제',
      '주택청약 소득공제',
    ];

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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('예상 환급액', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              Text(
                '계산 준비 완료',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('적용 가능한 공제 항목', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ...chips.map((item) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
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
        onChanged: (checked) => onChanged(checked ?? false),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle:
            description == null
                ? null
                : Text(
                  description,
                  style: const TextStyle(color: AppTheme.textMuted),
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

  void _applyEmploymentStartMonth(int startMonth) {
    _salaryPaidMonths = List<bool>.generate(
      12,
      (index) => index >= startMonth - 1,
    );
  }

  void _handleNext() {
    _age = int.tryParse(_ageController.text) ?? _age;
    _annualIncomeManwon =
        int.tryParse(_incomeController.text) ?? _annualIncomeManwon;

    if (_step < _totalSteps) {
      setState(() => _step += 1);
      return;
    }

    final updatedProfile = widget.appState.userProfile.copyWith(
      age: _age,
      annualIncome: _annualIncomeManwon * 10000,
      dependents: _dependents,
      currentMonth: _paidSalaryMonthCount,
      specialSituations: _specialSituations.copyWith(
        monthlyReligiousDonation:
            _specialSituations.hasReligiousDonation
                ? ((double.tryParse(_religiousDonationController.text) ?? 0) *
                    10000)
                : null,
        clearMonthlyReligiousDonation: !_specialSituations.hasReligiousDonation,
        monthlyRent:
            _specialSituations.hasRent
                ? ((double.tryParse(_rentController.text) ?? 0) * 10000)
                : null,
        clearMonthlyRent: !_specialSituations.hasRent,
      ),
    );

    widget.appState.updateUserProfile(updatedProfile);
    widget.appState.setOnboardingComplete(true);
  }
}
