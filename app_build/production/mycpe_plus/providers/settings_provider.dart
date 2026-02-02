import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/localization/app_locale.dart';
import '../core/localization/app_strings.dart';

/// Provider for application settings
class SettingsProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  final FlutterSecureStorage _storage;
  
  AppLocale _locale = AppLocale.english;
  AppStrings _strings = const EnglishStrings();
  bool _isInitialized = false;
  
  SettingsProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  
  AppLocale get locale => _locale;
  AppStrings get strings => _strings;
  bool get isInitialized => _isInitialized;
  
  /// Initialize settings from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final storedLocale = await _storage.read(key: _localeKey);
      if (storedLocale != null) {
        _locale = AppLocale.fromCode(storedLocale);
        _strings = AppStrings.of(_locale);
      }
    } catch (_) {
      // Use default locale on error
    }
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Change the application locale
  Future<void> setLocale(AppLocale newLocale) async {
    if (_locale == newLocale) return;
    
    _locale = newLocale;
    _strings = AppStrings.of(newLocale);
    
    try {
      await _storage.write(key: _localeKey, value: newLocale.code);
    } catch (_) {
      // Continue even if storage fails
    }
    
    notifyListeners();
  }
}
