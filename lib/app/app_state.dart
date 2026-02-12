import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_screen.dart';
import 'app_storage.dart';
import 'models.dart';
import 'tax_calculator.dart';

class AppState extends ChangeNotifier {
  AppState({AppStorage? storage}) : _storage = storage ?? AppStorage();

  final AppStorage _storage;

  UserProfile _userProfile = UserProfile.defaults();
  TaxDeductionData _taxData = TaxDeductionData.defaults();
  TaxCalculationResult? _taxResult;
  bool _onboardingComplete = false;
  AppScreen _currentScreen = AppScreen.landing;
  bool _initialized = false;

  UserProfile get userProfile => _userProfile;
  TaxDeductionData get taxData => _taxData;
  TaxCalculationResult? get taxResult => _taxResult;
  bool get onboardingComplete => _onboardingComplete;
  AppScreen get currentScreen => _currentScreen;
  bool get isInitialized => _initialized;

  Future<void> initialize({bool forceFreshStart = false}) async {
    if (_initialized) return;

    if (forceFreshStart) {
      await _storage.clearAllData();
      _userProfile = UserProfile.defaults();
      _taxData = TaxDeductionData.defaults();
      _taxResult = null;
      _onboardingComplete = false;
      _currentScreen = AppScreen.landing;
      _initialized = true;
      notifyListeners();
      return;
    }

    final savedProfile = await _storage.loadUserProfile();
    final savedTaxData = await _storage.loadTaxData();
    final savedOnboardingComplete = await _storage.loadOnboardingComplete();

    if (savedProfile != null) {
      _userProfile = savedProfile;
    }
    if (savedTaxData != null) {
      _taxData = savedTaxData;
    }

    _onboardingComplete = savedOnboardingComplete;
    if (_onboardingComplete) {
      _currentScreen = AppScreen.dashboard;
      _taxResult = TaxCalculator.calculateTotalTax(_userProfile, _taxData);
    }

    _initialized = true;
    notifyListeners();
  }

  void setCurrentScreen(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    unawaited(_storage.saveUserProfile(profile));
    _recalculateIfReady();
    notifyListeners();
  }

  void updateTaxData({
    CardUsage? cardUsage,
    Donations? donations,
    Pension? pension,
    Housing? housing,
    Insurance? insurance,
    MedicalEducation? medicalEducation,
  }) {
    _taxData = _taxData.copyWith(
      cardUsage: cardUsage,
      donations: donations,
      pension: pension,
      housing: housing,
      insurance: insurance,
      medicalEducation: medicalEducation,
    );
    unawaited(_storage.saveTaxData(_taxData));
    _recalculateIfReady();
    notifyListeners();
  }

  void setOnboardingComplete(bool complete) {
    _onboardingComplete = complete;
    unawaited(_storage.saveOnboardingComplete(complete));

    if (complete) {
      _currentScreen = AppScreen.dashboard;
      _taxResult = TaxCalculator.calculateTotalTax(_userProfile, _taxData);
    } else {
      _taxResult = null;
      _currentScreen = AppScreen.landing;
    }
    notifyListeners();
  }

  void recalculateTax() {
    if (!_onboardingComplete) return;
    _taxResult = TaxCalculator.calculateTotalTax(_userProfile, _taxData);
    notifyListeners();
  }

  void resetAllData() {
    unawaited(_storage.clearAllData());
    _userProfile = UserProfile.defaults();
    _taxData = TaxDeductionData.defaults();
    _taxResult = null;
    _onboardingComplete = false;
    _currentScreen = AppScreen.landing;
    notifyListeners();
  }

  void _recalculateIfReady() {
    if (!_onboardingComplete) return;
    _taxResult = TaxCalculator.calculateTotalTax(_userProfile, _taxData);
  }
}
