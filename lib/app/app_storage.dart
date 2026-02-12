import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStorage {
  static const String _userProfileKey = 'savvy_user_profile';
  static const String _taxDataKey = 'savvy_tax_data';
  static const String _onboardingCompleteKey = 'savvy_onboarding_complete';
  static const String _lastUpdatedKey = 'savvy_last_updated';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<void> saveUserProfile(UserProfile profile) {
    return _saveMap(_userProfileKey, profile.toJson());
  }

  Future<UserProfile?> loadUserProfile() async {
    final map = await _loadMap(_userProfileKey);
    if (map == null) return null;
    return UserProfile.fromJson(map);
  }

  Future<void> saveTaxData(TaxDeductionData data) {
    return _saveMap(_taxDataKey, data.toJson());
  }

  Future<TaxDeductionData?> loadTaxData() async {
    final map = await _loadMap(_taxDataKey);
    if (map == null) return null;
    return TaxDeductionData.fromJson(map);
  }

  Future<void> saveOnboardingComplete(bool complete) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingCompleteKey, complete);
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  Future<bool> loadOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.remove(_userProfileKey);
    await prefs.remove(_taxDataKey);
    await prefs.remove(_onboardingCompleteKey);
    await prefs.remove(_lastUpdatedKey);
  }

  Future<void> _saveMap(String key, Map<String, dynamic> value) async {
    final prefs = await _prefs;
    await prefs.setString(key, jsonEncode(value));
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>?> _loadMap(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((Object? k, Object? v) {
          return MapEntry(k.toString(), v);
        });
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
