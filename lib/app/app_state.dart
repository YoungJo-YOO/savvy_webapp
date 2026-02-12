import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_screen.dart';
import 'route_sync.dart';
import 'app_storage.dart';
import 'models.dart';
import 'tax_calculator.dart';

class AppState extends ChangeNotifier {
  AppState({AppStorage? storage, AppRouteSync? routeSync})
      : _storage = storage ?? AppStorage(),
        _routeSync = routeSync ?? createAppRouteSync() {
    _routeSync.listen(_handleRouteChangedFromBrowser);
  }

  final AppStorage _storage;
  final AppRouteSync _routeSync;

  UserProfile _userProfile = UserProfile.defaults();
  TaxDeductionData _taxData = TaxDeductionData.defaults();
  TaxCalculationResult? _taxResult;
  bool _onboardingComplete = false;
  AppScreen _currentScreen = AppScreen.landing;
  bool _initialized = false;
  bool _isHandlingExternalRoute = false;

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
      unawaited(_storage.saveCurrentScreen(_currentScreen.name));
      _routeSync.updateScreen(_currentScreen, replace: true);
      _initialized = true;
      notifyListeners();
      return;
    }

    final savedProfile = await _storage.loadUserProfile();
    final savedTaxData = await _storage.loadTaxData();
    final savedOnboardingComplete = await _storage.loadOnboardingComplete();
    final savedScreenName = await _storage.loadCurrentScreen();
    final savedScreen = _screenFromName(savedScreenName);
    final routeScreen = _routeSync.readInitialScreen();
    final preferredScreen = routeScreen ?? savedScreen;

    if (savedProfile != null) {
      _userProfile = savedProfile;
    }
    if (savedTaxData != null) {
      _taxData = savedTaxData;
    }

    _onboardingComplete = savedOnboardingComplete;
    if (_onboardingComplete) {
      _taxResult = TaxCalculator.calculateTotalTax(_userProfile, _taxData);
      _currentScreen = _resolveInitialScreen(
        preferredScreen,
        onboardingComplete: true,
      );
    } else {
      _currentScreen = _resolveInitialScreen(
        preferredScreen,
        onboardingComplete: false,
      );
    }
    unawaited(_storage.saveCurrentScreen(_currentScreen.name));
    _routeSync.updateScreen(_currentScreen, replace: true);

    _initialized = true;
    notifyListeners();
  }

  void setCurrentScreen(AppScreen screen) {
    if (_currentScreen == screen) return;
    _currentScreen = screen;
    if (!_isHandlingExternalRoute) {
      _routeSync.updateScreen(screen);
    }
    unawaited(_storage.saveCurrentScreen(screen.name));
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
      // User-driven completion should keep a natural browser history step.
      _routeSync.updateScreen(_currentScreen);
    } else {
      _taxResult = null;
      _currentScreen = AppScreen.landing;
      _routeSync.updateScreen(_currentScreen, replace: true);
    }
    unawaited(_storage.saveCurrentScreen(_currentScreen.name));
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
    _routeSync.updateScreen(_currentScreen, replace: true);
    unawaited(_storage.saveCurrentScreen(_currentScreen.name));
    notifyListeners();
  }

  void startOnboardingFromScratch() {
    unawaited(_storage.clearAllData());
    _userProfile = UserProfile.defaults();
    _taxData = TaxDeductionData.defaults();
    _taxResult = null;
    _onboardingComplete = false;
    _currentScreen = AppScreen.onboardingStep1;
    // Keep landing -> onboarding as a back/forward-friendly transition.
    _routeSync.updateScreen(_currentScreen);
    unawaited(_storage.saveCurrentScreen(_currentScreen.name));
    notifyListeners();
  }

  void _recalculateIfReady() {
    if (!_onboardingComplete) return;
    _taxResult = TaxCalculator.calculateTotalTax(_userProfile, _taxData);
  }

  AppScreen _resolveInitialScreen(
    AppScreen? savedScreen, {
    required bool onboardingComplete,
  }) {
    if (savedScreen == null) {
      return onboardingComplete ? AppScreen.dashboard : AppScreen.landing;
    }

    if (!onboardingComplete) {
      if (savedScreen == AppScreen.landing ||
          savedScreen == AppScreen.onboardingStep1 ||
          savedScreen == AppScreen.onboardingStep2 ||
          savedScreen == AppScreen.onboardingStep3) {
        return savedScreen;
      }
      return AppScreen.landing;
    }

    return savedScreen;
  }

  AppScreen? _screenFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final screen in AppScreen.values) {
      if (screen.name == name) return screen;
    }
    return null;
  }

  void _handleRouteChangedFromBrowser(AppScreen screen) {
    if (!_initialized) return;
    final resolved = _resolveInitialScreen(
      screen,
      onboardingComplete: _onboardingComplete,
    );

    // If route is not allowed in current state, normalize URL to resolved screen.
    if (resolved != screen) {
      _routeSync.updateScreen(resolved, replace: true);
    }
    if (resolved == _currentScreen) return;

    _isHandlingExternalRoute = true;
    _currentScreen = resolved;
    _isHandlingExternalRoute = false;

    unawaited(_storage.saveCurrentScreen(_currentScreen.name));
    notifyListeners();
  }

  @override
  void dispose() {
    _routeSync.dispose();
    super.dispose();
  }
}
