class SpecialSituations {
  const SpecialSituations({
    required this.isSMEYouthTaxReduction,
    required this.hasReligiousDonation,
    required this.monthlyReligiousDonation,
    required this.hasRent,
    required this.monthlyRent,
    required this.hasChildren,
    required this.hasDisabledDependent,
    required this.hasElderlyDependent,
  });

  factory SpecialSituations.defaults() {
    return const SpecialSituations(
      isSMEYouthTaxReduction: false,
      hasReligiousDonation: false,
      monthlyReligiousDonation: null,
      hasRent: false,
      monthlyRent: null,
      hasChildren: false,
      hasDisabledDependent: false,
      hasElderlyDependent: false,
    );
  }

  factory SpecialSituations.fromJson(Map<String, dynamic> json) {
    return SpecialSituations(
      isSMEYouthTaxReduction:
          json['isSMEYouthTaxReduction'] as bool? ?? false,
      hasReligiousDonation: json['hasReligiousDonation'] as bool? ?? false,
      monthlyReligiousDonation:
          (json['monthlyReligiousDonation'] as num?)?.toDouble(),
      hasRent: json['hasRent'] as bool? ?? false,
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble(),
      hasChildren: json['hasChildren'] as bool? ?? false,
      hasDisabledDependent: json['hasDisabledDependent'] as bool? ?? false,
      hasElderlyDependent: json['hasElderlyDependent'] as bool? ?? false,
    );
  }

  final bool isSMEYouthTaxReduction;
  final bool hasReligiousDonation;
  final double? monthlyReligiousDonation;
  final bool hasRent;
  final double? monthlyRent;
  final bool hasChildren;
  final bool hasDisabledDependent;
  final bool hasElderlyDependent;

  bool get hasAnyActive {
    return isSMEYouthTaxReduction ||
        hasReligiousDonation ||
        hasRent ||
        hasChildren ||
        hasDisabledDependent ||
        hasElderlyDependent;
  }

  SpecialSituations copyWith({
    bool? isSMEYouthTaxReduction,
    bool? hasReligiousDonation,
    double? monthlyReligiousDonation,
    bool clearMonthlyReligiousDonation = false,
    bool? hasRent,
    double? monthlyRent,
    bool clearMonthlyRent = false,
    bool? hasChildren,
    bool? hasDisabledDependent,
    bool? hasElderlyDependent,
  }) {
    return SpecialSituations(
      isSMEYouthTaxReduction:
          isSMEYouthTaxReduction ?? this.isSMEYouthTaxReduction,
      hasReligiousDonation: hasReligiousDonation ?? this.hasReligiousDonation,
      monthlyReligiousDonation: clearMonthlyReligiousDonation
          ? null
          : (monthlyReligiousDonation ?? this.monthlyReligiousDonation),
      hasRent: hasRent ?? this.hasRent,
      monthlyRent: clearMonthlyRent ? null : (monthlyRent ?? this.monthlyRent),
      hasChildren: hasChildren ?? this.hasChildren,
      hasDisabledDependent: hasDisabledDependent ?? this.hasDisabledDependent,
      hasElderlyDependent: hasElderlyDependent ?? this.hasElderlyDependent,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isSMEYouthTaxReduction': isSMEYouthTaxReduction,
      'hasReligiousDonation': hasReligiousDonation,
      'monthlyReligiousDonation': monthlyReligiousDonation,
      'hasRent': hasRent,
      'monthlyRent': monthlyRent,
      'hasChildren': hasChildren,
      'hasDisabledDependent': hasDisabledDependent,
      'hasElderlyDependent': hasElderlyDependent,
    };
  }
}

class UserProfile {
  const UserProfile({
    required this.age,
    required this.annualIncome,
    required this.dependents,
    required this.currentMonth,
    required this.specialSituations,
  });

  factory UserProfile.defaults() {
    return UserProfile(
      age: 28,
      annualIncome: 42000000,
      dependents: 0,
      currentMonth: DateTime.now().month,
      specialSituations: SpecialSituations.defaults(),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int? ?? 28,
      annualIncome: (json['annualIncome'] as num?)?.toDouble() ?? 42000000,
      dependents: json['dependents'] as int? ?? 0,
      currentMonth: json['currentMonth'] as int? ?? DateTime.now().month,
      specialSituations: SpecialSituations.fromJson(
        (json['specialSituations'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
    );
  }

  final int age;
  final double annualIncome;
  final int dependents;
  final int currentMonth;
  final SpecialSituations specialSituations;

  UserProfile copyWith({
    int? age,
    double? annualIncome,
    int? dependents,
    int? currentMonth,
    SpecialSituations? specialSituations,
  }) {
    return UserProfile(
      age: age ?? this.age,
      annualIncome: annualIncome ?? this.annualIncome,
      dependents: dependents ?? this.dependents,
      currentMonth: currentMonth ?? this.currentMonth,
      specialSituations: specialSituations ?? this.specialSituations,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'age': age,
      'annualIncome': annualIncome,
      'dependents': dependents,
      'currentMonth': currentMonth,
      'specialSituations': specialSituations.toJson(),
    };
  }
}

class CardUsage {
  const CardUsage({
    required this.creditCard,
    required this.debitCard,
    required this.cashReceipt,
  });

  factory CardUsage.defaults() {
    return const CardUsage(creditCard: 0, debitCard: 0, cashReceipt: 0);
  }

  factory CardUsage.fromJson(Map<String, dynamic> json) {
    return CardUsage(
      creditCard: (json['creditCard'] as num?)?.toDouble() ?? 0,
      debitCard: (json['debitCard'] as num?)?.toDouble() ?? 0,
      cashReceipt: (json['cashReceipt'] as num?)?.toDouble() ?? 0,
    );
  }

  final double creditCard;
  final double debitCard;
  final double cashReceipt;

  CardUsage copyWith({
    double? creditCard,
    double? debitCard,
    double? cashReceipt,
  }) {
    return CardUsage(
      creditCard: creditCard ?? this.creditCard,
      debitCard: debitCard ?? this.debitCard,
      cashReceipt: cashReceipt ?? this.cashReceipt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'creditCard': creditCard,
      'debitCard': debitCard,
      'cashReceipt': cashReceipt,
    };
  }
}

class Donations {
  const Donations({
    required this.religious,
    required this.political,
    required this.general,
  });

  factory Donations.defaults() {
    return const Donations(religious: 0, political: 0, general: 0);
  }

  factory Donations.fromJson(Map<String, dynamic> json) {
    return Donations(
      religious: (json['religious'] as num?)?.toDouble() ?? 0,
      political: (json['political'] as num?)?.toDouble() ?? 0,
      general: (json['general'] as num?)?.toDouble() ?? 0,
    );
  }

  final double religious;
  final double political;
  final double general;

  Donations copyWith({
    double? religious,
    double? political,
    double? general,
  }) {
    return Donations(
      religious: religious ?? this.religious,
      political: political ?? this.political,
      general: general ?? this.general,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'religious': religious,
      'political': political,
      'general': general,
    };
  }
}

class Pension {
  const Pension({
    required this.pensionSavings,
    required this.irp,
  });

  factory Pension.defaults() {
    return const Pension(pensionSavings: 0, irp: 0);
  }

  factory Pension.fromJson(Map<String, dynamic> json) {
    return Pension(
      pensionSavings: (json['pensionSavings'] as num?)?.toDouble() ?? 0,
      irp: (json['irp'] as num?)?.toDouble() ?? 0,
    );
  }

  final double pensionSavings;
  final double irp;

  Pension copyWith({
    double? pensionSavings,
    double? irp,
  }) {
    return Pension(
      pensionSavings: pensionSavings ?? this.pensionSavings,
      irp: irp ?? this.irp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pensionSavings': pensionSavings,
      'irp': irp,
    };
  }
}

class Housing {
  const Housing({
    required this.housingSubscription,
    required this.monthlyRent,
  });

  factory Housing.defaults() {
    return const Housing(housingSubscription: 0, monthlyRent: 0);
  }

  factory Housing.fromJson(Map<String, dynamic> json) {
    return Housing(
      housingSubscription:
          (json['housingSubscription'] as num?)?.toDouble() ?? 0,
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0,
    );
  }

  final double housingSubscription;
  final double monthlyRent;

  Housing copyWith({
    double? housingSubscription,
    double? monthlyRent,
  }) {
    return Housing(
      housingSubscription: housingSubscription ?? this.housingSubscription,
      monthlyRent: monthlyRent ?? this.monthlyRent,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'housingSubscription': housingSubscription,
      'monthlyRent': monthlyRent,
    };
  }
}

class TaxDeductionData {
  const TaxDeductionData({
    required this.cardUsage,
    required this.donations,
    required this.pension,
    required this.housing,
  });

  factory TaxDeductionData.defaults() {
    return TaxDeductionData(
      cardUsage: CardUsage.defaults(),
      donations: Donations.defaults(),
      pension: Pension.defaults(),
      housing: Housing.defaults(),
    );
  }

  factory TaxDeductionData.fromJson(Map<String, dynamic> json) {
    return TaxDeductionData(
      cardUsage: CardUsage.fromJson(
        (json['cardUsage'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      donations: Donations.fromJson(
        (json['donations'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      pension: Pension.fromJson(
        (json['pension'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      housing: Housing.fromJson(
        (json['housing'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
    );
  }

  final CardUsage cardUsage;
  final Donations donations;
  final Pension pension;
  final Housing housing;

  TaxDeductionData copyWith({
    CardUsage? cardUsage,
    Donations? donations,
    Pension? pension,
    Housing? housing,
  }) {
    return TaxDeductionData(
      cardUsage: cardUsage ?? this.cardUsage,
      donations: donations ?? this.donations,
      pension: pension ?? this.pension,
      housing: housing ?? this.housing,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cardUsage': cardUsage.toJson(),
      'donations': donations.toJson(),
      'pension': pension.toJson(),
      'housing': housing.toJson(),
    };
  }
}

class TaxDeductions {
  const TaxDeductions({
    required this.religiousDonation,
    required this.pension,
    required this.cardUsage,
    required this.housingSubscription,
    required this.total,
  });

  factory TaxDeductions.empty() {
    return const TaxDeductions(
      religiousDonation: 0,
      pension: 0,
      cardUsage: 0,
      housingSubscription: 0,
      total: 0,
    );
  }

  factory TaxDeductions.fromJson(Map<String, dynamic> json) {
    return TaxDeductions(
      religiousDonation: (json['religiousDonation'] as num?)?.toDouble() ?? 0,
      pension: (json['pension'] as num?)?.toDouble() ?? 0,
      cardUsage: (json['cardUsage'] as num?)?.toDouble() ?? 0,
      housingSubscription:
          (json['housingSubscription'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  final double religiousDonation;
  final double pension;
  final double cardUsage;
  final double housingSubscription;
  final double total;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'religiousDonation': religiousDonation,
      'pension': pension,
      'cardUsage': cardUsage,
      'housingSubscription': housingSubscription,
      'total': total,
    };
  }
}

class TaxCalculationResult {
  const TaxCalculationResult({
    required this.taxableIncome,
    required this.calculatedTax,
    required this.smeReduction,
    required this.taxDeductions,
    required this.finalTax,
    required this.prepaidTax,
    required this.refundAmount,
  });

  factory TaxCalculationResult.fromJson(Map<String, dynamic> json) {
    return TaxCalculationResult(
      taxableIncome: (json['taxableIncome'] as num?)?.toDouble() ?? 0,
      calculatedTax: (json['calculatedTax'] as num?)?.toDouble() ?? 0,
      smeReduction: (json['smeReduction'] as num?)?.toDouble() ?? 0,
      taxDeductions: TaxDeductions.fromJson(
        (json['taxDeductions'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      finalTax: (json['finalTax'] as num?)?.toDouble() ?? 0,
      prepaidTax: (json['prepaidTax'] as num?)?.toDouble() ?? 0,
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  final double taxableIncome;
  final double calculatedTax;
  final double smeReduction;
  final TaxDeductions taxDeductions;
  final double finalTax;
  final double prepaidTax;
  final double refundAmount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'taxableIncome': taxableIncome,
      'calculatedTax': calculatedTax,
      'smeReduction': smeReduction,
      'taxDeductions': taxDeductions.toJson(),
      'finalTax': finalTax,
      'prepaidTax': prepaidTax,
      'refundAmount': refundAmount,
    };
  }
}
