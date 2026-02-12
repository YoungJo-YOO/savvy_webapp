import 'dart:math' as math;

import 'package:intl/intl.dart';

import 'models.dart';

class TaxCalculator {
  static double currentCompanyIncome(UserProfile profile) {
    final paidMonths = profile.currentMonth.clamp(0, 12);
    return profile.annualIncome * (paidMonths / 12.0);
  }

  static double totalAnnualIncome(UserProfile profile) {
    return currentCompanyIncome(profile) +
        (profile.isFirstJobThisYear ? 0 : profile.previousCompanyIncome);
  }

  static double calculateEarnedIncomeDeduction(double annualIncome) {
    if (annualIncome <= 5000000) {
      return annualIncome * 0.7;
    } else if (annualIncome <= 15000000) {
      return 3500000 + (annualIncome - 5000000) * 0.4;
    } else if (annualIncome <= 45000000) {
      return 7500000 + (annualIncome - 15000000) * 0.15;
    } else if (annualIncome <= 100000000) {
      return 12000000 + (annualIncome - 45000000) * 0.05;
    } else {
      return 14750000 + (annualIncome - 100000000) * 0.02;
    }
  }

  static double calculateCardDeduction(
    double annualIncome,
    double creditCard,
    double debitCard,
    double cashReceipt,
  ) {
    final minUsage = annualIncome * 0.25;
    final totalUsage = creditCard + debitCard + cashReceipt;

    if (totalUsage <= minUsage) {
      return 0;
    }

    var deduction = 0.0;
    var remaining = totalUsage - minUsage;

    if (creditCard > minUsage) {
      final creditExcess = math.min(creditCard - minUsage, remaining);
      deduction += creditExcess * 0.15;
      remaining -= creditExcess;
    }

    if (remaining > 0 && debitCard > 0) {
      final debitExcess = math.min(debitCard, remaining);
      deduction += debitExcess * 0.3;
      remaining -= debitExcess;
    }

    if (remaining > 0 && cashReceipt > 0) {
      final cashExcess = math.min(cashReceipt, remaining);
      deduction += cashExcess * 0.3;
    }

    final limit = annualIncome <= 120000000 ? 3000000 : 2500000;
    return math.min(deduction, limit.toDouble());
  }

  static double calculatePensionTaxCredit(
    double annualIncome,
    double pensionSavings,
    double irp,
  ) {
    final total = pensionSavings + irp;
    const limit = 7000000.0;
    final effectiveAmount = math.min(
      total,
      math.min(limit, pensionSavings + math.min(irp, limit - pensionSavings)),
    );
    final rate = annualIncome <= 55000000 ? 0.165 : 0.132;
    return effectiveAmount * rate;
  }

  static double calculateDonationTaxCredit(
    double religious,
    double political,
    double general,
  ) {
    var credit = 0.0;
    credit += political * 0.15;

    if (general <= 10000000) {
      credit += general * 0.15;
    } else {
      credit += 10000000 * 0.15 + (general - 10000000) * 0.3;
    }

    if (religious <= 10000000) {
      credit += religious * 0.15;
    } else {
      credit += 10000000 * 0.15 + (religious - 10000000) * 0.3;
    }

    return credit;
  }

  static double calculateMedicalEducationTaxCredit(
    double annualIncome,
    double medical,
    double education,
  ) {
    final medicalThreshold = annualIncome * 0.03;
    final medicalEligible = math.max(medical - medicalThreshold, 0);
    final medicalCredit = medicalEligible * 0.15;
    final educationCredit = math.max(education, 0) * 0.15;
    return medicalCredit + educationCredit;
  }

  static double calculateHousingDeduction(
    double housingSubscription, {
    double annualMonthlyRent = 0,
  }) {
    const subscriptionLimit = 2400000.0;
    final subscriptionDeduction =
        math.min(housingSubscription, subscriptionLimit) * 0.4;

    const rentAnnualLimit = 7500000.0;
    final rentDeduction = math.min(annualMonthlyRent, rentAnnualLimit) * 0.15;

    return subscriptionDeduction + rentDeduction;
  }

  static double calculateTaxableIncome(
    double annualIncome,
    int dependents,
    double cardDeduction,
    double housingDeduction, {
    double additionalIncomeDeduction = 0,
  }) {
    final earnedIncomeDeduction = calculateEarnedIncomeDeduction(annualIncome);
    final earnedIncome = annualIncome - earnedIncomeDeduction;

    final personalDeduction = 1500000 + (dependents * 1500000);
    final totalDeduction =
        personalDeduction +
        cardDeduction +
        housingDeduction +
        additionalIncomeDeduction;

    return math.max(earnedIncome - totalDeduction, 0.0);
  }

  static double calculateTax(double taxableIncome) {
    if (taxableIncome <= 14000000) {
      return taxableIncome * 0.06;
    } else if (taxableIncome <= 50000000) {
      return 840000 + (taxableIncome - 14000000) * 0.15;
    } else if (taxableIncome <= 88000000) {
      return 6240000 + (taxableIncome - 50000000) * 0.24;
    } else if (taxableIncome <= 150000000) {
      return 15360000 + (taxableIncome - 88000000) * 0.35;
    } else if (taxableIncome <= 300000000) {
      return 37060000 + (taxableIncome - 150000000) * 0.38;
    } else if (taxableIncome <= 500000000) {
      return 94060000 + (taxableIncome - 300000000) * 0.40;
    } else {
      return 174060000 + (taxableIncome - 500000000) * 0.42;
    }
  }

  static TaxCalculationResult calculateTotalTax(
    UserProfile profile,
    TaxDeductionData data,
  ) {
    final effectiveAnnualIncome = totalAnnualIncome(profile);

    final cardDeduction = calculateCardDeduction(
      effectiveAnnualIncome,
      data.cardUsage.creditCard,
      data.cardUsage.debitCard,
      data.cardUsage.cashReceipt,
    );

    final housingDeduction = calculateHousingDeduction(
      data.housing.housingSubscription,
      annualMonthlyRent: data.housing.monthlyRent,
    );

    final taxableIncome = calculateTaxableIncome(
      effectiveAnnualIncome,
      profile.dependents,
      cardDeduction,
      housingDeduction,
    );

    var calculatedTax = calculateTax(taxableIncome);
    var smeReduction = 0.0;

    if (profile.specialSituations.isSMEYouthTaxReduction && profile.age <= 34) {
      smeReduction = calculatedTax * 0.9;
      calculatedTax *= 0.1;
    }

    final pensionCredit = calculatePensionTaxCredit(
      effectiveAnnualIncome,
      data.pension.pensionSavings,
      data.pension.irp,
    );

    final donationCredit = calculateDonationTaxCredit(
      data.donations.religious,
      data.donations.political,
      data.donations.general,
    );
    final medicalEducationTaxCredit = calculateMedicalEducationTaxCredit(
      effectiveAnnualIncome,
      data.medicalEducation.medical,
      data.medicalEducation.education,
    );
    final totalTaxCredit =
        pensionCredit + donationCredit + medicalEducationTaxCredit;

    final taxDeductions = TaxDeductions(
      religiousDonation: donationCredit,
      pension: pensionCredit,
      cardUsage: cardDeduction,
      housingSubscription: housingDeduction,
      insuranceIncome: 0,
      insuranceTaxCredit: 0,
      medicalEducationTaxCredit: medicalEducationTaxCredit,
      total: totalTaxCredit,
    );

    final finalTax = calculatedTax - taxDeductions.total;
    final currentCompanyPrepaidTax = currentCompanyIncome(profile) * 0.05;
    final previousCompanyPrepaidTax =
        profile.isFirstJobThisYear ? 0.0 : profile.previousCompanyPrepaidTax;
    final prepaidTax = currentCompanyPrepaidTax + previousCompanyPrepaidTax;
    final refundAmount = prepaidTax - finalTax;

    return TaxCalculationResult(
      taxableIncome: taxableIncome,
      calculatedTax: calculatedTax + smeReduction,
      smeReduction: smeReduction,
      taxDeductions: taxDeductions,
      finalTax: finalTax,
      prepaidTax: prepaidTax,
      refundAmount: refundAmount,
    );
  }

  static final NumberFormat _currencyFormatter = NumberFormat.decimalPattern(
    'ko_KR',
  );

  static String formatCurrency(double amount) {
    return '${_currencyFormatter.format(amount.round())}원';
  }

  static String formatMillions(double amount) {
    final millions = (amount / 10000).round();
    return '${_currencyFormatter.format(millions)}만원';
  }
}
