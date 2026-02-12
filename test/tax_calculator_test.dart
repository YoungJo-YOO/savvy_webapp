import 'package:flutter_test/flutter_test.dart';
import 'package:savvy_webapp/app/models.dart';
import 'package:savvy_webapp/app/tax_calculator.dart';

UserProfile _profile({
  int age = 28,
  double annualIncome = 42000000,
  int currentMonth = 12,
  bool isFirstJobThisYear = true,
  double previousCompanyIncome = 0,
  double previousCompanyPrepaidTax = 0,
  bool isSME = false,
}) {
  return UserProfile(
    age: age,
    annualIncome: annualIncome,
    dependents: 0,
    currentMonth: currentMonth,
    isFirstJobThisYear: isFirstJobThisYear,
    previousCompanyIncome: previousCompanyIncome,
    previousCompanyPrepaidTax: previousCompanyPrepaidTax,
    specialSituations:
        isSME
            ? SpecialSituations.defaults().copyWith(
              isSMEYouthTaxReduction: true,
            )
            : SpecialSituations.defaults(),
  );
}

void main() {
  group('경계값: 카드/연금/세율', () {
    test('카드 사용액이 25% 문턱과 같으면 공제액은 0원', () {
      final deduction = TaxCalculator.calculateCardDeduction(
        40000000,
        6000000,
        3000000,
        1000000,
      );

      expect(deduction, 0);
    });

    test('카드 공제는 한도(총급여 1.2억 이하 300만원)를 넘지 않는다', () {
      final deduction = TaxCalculator.calculateCardDeduction(
        40000000,
        0,
        100000000,
        0,
      );

      expect(deduction, 3000000);
    });

    test('연금 세액공제율은 5,500만원 경계에서 달라진다', () {
      final atBoundary = TaxCalculator.calculatePensionTaxCredit(
        55000000,
        7000000,
        0,
      );
      final overBoundary = TaxCalculator.calculatePensionTaxCredit(
        55000001,
        7000000,
        0,
      );

      expect(atBoundary, closeTo(1155000, 0.001));
      expect(overBoundary, closeTo(924000, 0.001));
    });

    test('산출세액 구간 경계(1,400만원)에서 계산이 이어진다', () {
      final atBoundary = TaxCalculator.calculateTax(14000000);
      final overBoundary = TaxCalculator.calculateTax(14000001);

      expect(atBoundary, closeTo(840000, 0.001));
      expect(overBoundary, closeTo(840000.15, 0.001));
    });
  });

  group('중도입사/이직 반영', () {
    test('중도입사 첫 직장은 급여 8개월분과 해당 기납부세액만 반영된다', () {
      final profile = _profile(
        annualIncome: 48000000,
        currentMonth: 8,
        isFirstJobThisYear: true,
      );

      final result = TaxCalculator.calculateTotalTax(
        profile,
        TaxDeductionData.defaults(),
      );

      expect(TaxCalculator.currentCompanyIncome(profile), closeTo(32000000, 0.001));
      expect(TaxCalculator.totalAnnualIncome(profile), closeTo(32000000, 0.001));
      expect(result.prepaidTax, closeTo(1600000, 0.001));
    });

    test('이직자는 전직장 총급여/기납부세액이 합산된다', () {
      final profile = _profile(
        annualIncome: 48000000,
        currentMonth: 8,
        isFirstJobThisYear: false,
        previousCompanyIncome: 12000000,
        previousCompanyPrepaidTax: 500000,
      );

      final result = TaxCalculator.calculateTotalTax(
        profile,
        TaxDeductionData.defaults(),
      );

      expect(TaxCalculator.totalAnnualIncome(profile), closeTo(44000000, 0.001));
      expect(result.prepaidTax, closeTo(2100000, 0.001));
    });
  });

  group('중소기업 청년 감면', () {
    test('적격 연령(34세 이하)은 산출세액의 90% 감면된다', () {
      final normalProfile = _profile(annualIncome: 42000000, isSME: false);
      final smeProfile = _profile(annualIncome: 42000000, isSME: true);

      final normalResult = TaxCalculator.calculateTotalTax(
        normalProfile,
        TaxDeductionData.defaults(),
      );
      final smeResult = TaxCalculator.calculateTotalTax(
        smeProfile,
        TaxDeductionData.defaults(),
      );

      expect(smeResult.smeReduction, closeTo(normalResult.calculatedTax * 0.9, 0.001));
      expect(smeResult.finalTax, closeTo(normalResult.finalTax * 0.1, 0.001));
    });

    test('연령 비적격(35세)은 감면 체크가 있어도 감면되지 않는다', () {
      final normalProfile = _profile(age: 35, annualIncome: 42000000, isSME: false);
      final ineligibleProfile = _profile(
        age: 35,
        annualIncome: 42000000,
        isSME: true,
      );

      final normalResult = TaxCalculator.calculateTotalTax(
        normalProfile,
        TaxDeductionData.defaults(),
      );
      final ineligibleResult = TaxCalculator.calculateTotalTax(
        ineligibleProfile,
        TaxDeductionData.defaults(),
      );

      expect(ineligibleResult.smeReduction, 0);
      expect(ineligibleResult.finalTax, closeTo(normalResult.finalTax, 0.001));
    });
  });

  group('부호(최종세액/환급액) 처리', () {
    test('세액공제가 산출세액을 초과해도 결정세액은 0원 미만으로 내려가지 않는다', () {
      final profile = _profile(annualIncome: 42000000);
      final data = TaxDeductionData.defaults().copyWith(
        pension: const Pension(pensionSavings: 7000000, irp: 0),
        donations: const Donations(religious: 0, political: 0, general: 20000000),
      );

      final result = TaxCalculator.calculateTotalTax(profile, data);

      expect(result.finalTax, 0);
      expect(
        result.refundAmount,
        closeTo(result.prepaidTax - result.finalTax, 0.001),
      );
      expect(result.refundAmount, closeTo(result.prepaidTax, 0.001));
    });

    test('최종세액이 기납부세액보다 크면 추가 납부(환급액 음수)가 된다', () {
      final profile = _profile(annualIncome: 100000000);
      final result = TaxCalculator.calculateTotalTax(
        profile,
        TaxDeductionData.defaults(),
      );

      expect(result.finalTax, greaterThan(result.prepaidTax));
      expect(result.refundAmount, lessThan(0));
      expect(
        result.refundAmount,
        closeTo(result.prepaidTax - result.finalTax, 0.001),
      );
    });
  });
}
