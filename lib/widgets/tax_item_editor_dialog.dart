import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../app/tax_calculator.dart';
import 'app_button.dart';
import 'labeled_input.dart';
import 'progress_bar.dart';

class TaxItemEditorDialog extends StatefulWidget {
  const TaxItemEditorDialog({
    super.key,
    required this.itemId,
    required this.appState,
  });

  final String itemId;
  final AppState appState;

  @override
  State<TaxItemEditorDialog> createState() => _TaxItemEditorDialogState();
}

class _TaxItemEditorDialogState extends State<TaxItemEditorDialog> {
  late final TextEditingController _creditCardController;
  late final TextEditingController _debitCardController;
  late final TextEditingController _cashController;
  late final TextEditingController _pensionController;
  late final TextEditingController _irpController;
  late final TextEditingController _religiousController;
  late final TextEditingController _politicalController;
  late final TextEditingController _generalController;
  late final TextEditingController _housingController;

  @override
  void initState() {
    super.initState();
    final taxData = widget.appState.taxData;
    _creditCardController =
        TextEditingController(text: _toManwonString(taxData.cardUsage.creditCard));
    _debitCardController =
        TextEditingController(text: _toManwonString(taxData.cardUsage.debitCard));
    _cashController =
        TextEditingController(text: _toManwonString(taxData.cardUsage.cashReceipt));
    _pensionController =
        TextEditingController(text: _toManwonString(taxData.pension.pensionSavings));
    _irpController = TextEditingController(text: _toManwonString(taxData.pension.irp));
    _religiousController =
        TextEditingController(text: _toManwonString(taxData.donations.religious));
    _politicalController =
        TextEditingController(text: _toManwonString(taxData.donations.political));
    _generalController =
        TextEditingController(text: _toManwonString(taxData.donations.general));
    _housingController =
        TextEditingController(text: _toManwonString(taxData.housing.housingSubscription));
  }

  @override
  void dispose() {
    _creditCardController.dispose();
    _debitCardController.dispose();
    _cashController.dispose();
    _pensionController.dispose();
    _irpController.dispose();
    _religiousController.dispose();
    _politicalController.dispose();
    _generalController.dispose();
    _housingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemId == 'sme') {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '중소기업 청년 소득세 감면',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '만 15~34세 청년이 중소기업에 취업한 경우 5년 동안 소득세 90% 감면이 자동 반영됩니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[AppTheme.primary, Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '현재 감면액',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        TaxCalculator.formatCurrency(
                          widget.appState.taxResult?.smeReduction ?? 0,
                        ),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  fullWidth: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final estimated = _estimatedDeduction();

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: _buildEditorBody(context),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppTheme.primary, Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('예상 공제액', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(
                      TaxCalculator.formatCurrency(estimated),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('닫기'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      fullWidth: true,
                      onPressed: _apply,
                      child: const Text('적용하기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorBody(BuildContext context) {
    return switch (widget.itemId) {
      'card' => _buildCardEditor(context),
      'pension' => _buildPensionEditor(context),
      'donation' => _buildDonationEditor(context),
      'housing' => _buildHousingEditor(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildCardEditor(BuildContext context) {
    final income = widget.appState.userProfile.annualIncome;
    final minimum = income * 0.25;
    final total = _won(_creditCardController) +
        _won(_debitCardController) +
        _won(_cashController);
    final progress = total / math.max(minimum, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('신용/체크카드 소득공제', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '총급여의 25%를 초과한 사용금액에 대해 공제를 받을 수 있습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        const SizedBox(height: 14),
        AppProgressBar(
          current: total,
          total: minimum,
          label: '공제 최소 충족',
          tone: progress >= 1
              ? ProgressTone.success
              : (progress >= 0.5 ? ProgressTone.warning : ProgressTone.danger),
        ),
        const SizedBox(height: 8),
        Text(
          '기준 금액: ${TaxCalculator.formatCurrency(minimum)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        LabeledInput(
          label: '신용카드 사용액',
          controller: _creditCardController,
          suffixText: '만원',
          helperText: '공제율 15%',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        LabeledInput(
          label: '체크카드 사용액',
          controller: _debitCardController,
          suffixText: '만원',
          helperText: '공제율 30%',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        LabeledInput(
          label: '현금영수증',
          controller: _cashController,
          suffixText: '만원',
          helperText: '공제율 30%',
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPensionEditor(BuildContext context) {
    final annualIncome = widget.appState.userProfile.annualIncome;
    final rate = annualIncome <= 55000000 ? 16.5 : 13.2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('연금저축 세액공제', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '연금저축과 IRP를 합산해 최대 700만원까지 세액공제를 받을 수 있습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        LabeledInput(
          label: '연금저축 연간 납입액',
          controller: _pensionController,
          suffixText: '만원',
          helperText: '최대 400만원, 세액공제율 $rate%',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        LabeledInput(
          label: 'IRP 연간 납입액',
          controller: _irpController,
          suffixText: '만원',
          helperText: '연금저축 포함 최대 700만원',
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDonationEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('기부금 세액공제', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '기부금은 1,000만원 이하 15%, 초과분 30% 공제율이 적용됩니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        LabeledInput(
          label: '종교단체 기부금',
          controller: _religiousController,
          suffixText: '만원',
          helperText: '소득금액의 10% 한도',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        LabeledInput(
          label: '정치자금 기부금',
          controller: _politicalController,
          suffixText: '만원',
          helperText: '우선 공제 대상',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        LabeledInput(
          label: '일반 기부금',
          controller: _generalController,
          suffixText: '만원',
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildHousingEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('주택청약 소득공제', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '무주택 세대주는 연간 240만원 한도로 40% 소득공제를 받을 수 있습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        LabeledInput(
          label: '주택청약 납입액',
          controller: _housingController,
          suffixText: '만원',
          helperText: '최대 240만원, 40% 소득공제',
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  double _estimatedDeduction() {
    final profile = widget.appState.userProfile;
    return switch (widget.itemId) {
      'card' => TaxCalculator.calculateCardDeduction(
          profile.annualIncome,
          _won(_creditCardController),
          _won(_debitCardController),
          _won(_cashController),
        ),
      'pension' => TaxCalculator.calculatePensionTaxCredit(
          profile.annualIncome,
          _won(_pensionController),
          _won(_irpController),
        ),
      'donation' => TaxCalculator.calculateDonationTaxCredit(
          _won(_religiousController),
          _won(_politicalController),
          _won(_generalController),
        ),
      'housing' => TaxCalculator.calculateHousingDeduction(
          _won(_housingController),
        ),
      _ => 0,
    };
  }

  void _apply() {
    final taxData = widget.appState.taxData;
    switch (widget.itemId) {
      case 'card':
        widget.appState.updateTaxData(
          cardUsage: taxData.cardUsage.copyWith(
            creditCard: _won(_creditCardController),
            debitCard: _won(_debitCardController),
            cashReceipt: _won(_cashController),
          ),
        );
        break;
      case 'pension':
        widget.appState.updateTaxData(
          pension: taxData.pension.copyWith(
            pensionSavings: _won(_pensionController),
            irp: _won(_irpController),
          ),
        );
        break;
      case 'donation':
        widget.appState.updateTaxData(
          donations: taxData.donations.copyWith(
            religious: _won(_religiousController),
            political: _won(_politicalController),
            general: _won(_generalController),
          ),
        );
        break;
      case 'housing':
        widget.appState.updateTaxData(
          housing: taxData.housing.copyWith(
            housingSubscription: _won(_housingController),
          ),
        );
        break;
    }
    Navigator.of(context).pop();
  }

  static String _toManwonString(double value) {
    final amount = value / 10000;
    if (amount == amount.roundToDouble()) return amount.toStringAsFixed(0);
    return amount.toStringAsFixed(1);
  }

  static double _won(TextEditingController controller) {
    final text = controller.text.replaceAll(',', '').trim();
    return (double.tryParse(text) ?? 0) * 10000;
  }
}
