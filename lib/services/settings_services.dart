// أضف هذه الدوال في lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // ... الدوال الحالية ...

  // 🔧 إعدادات التطبيق المحاسبي
  static const String _currencyKey = 'finance_currency';
  static const String _dateFormatKey = 'finance_date_format';
  static const String _backupKey = 'finance_backup';
  static const String _darkModeKey = 'finance_dark_mode';
  static const String _biometricKey = 'finance_biometric';
  static const String _taxRateKey = 'finance_tax_rate';
  static const String _startWeekKey = 'finance_start_week';

  // العملة
  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'ر.س';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // تنسيق التاريخ
  Future<String> getDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dateFormatKey) ?? 'yyyy-MM-dd';
  }

  Future<void> setDateFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateFormatKey, format);
  }

  // النسخ الاحتياطي
  Future<bool> getBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_backupKey) ?? true;
  }

  Future<void> setBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backupKey, enabled);
  }

  // الوضع الليلي
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  // المصادقة البيومترية
  Future<bool> getBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  Future<void> setBiometricAuth(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }

  // نسبة الضريبة
  Future<String> getTaxRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_taxRateKey) ?? '15';
  }

  Future<void> setTaxRate(String rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_taxRateKey, rate);
  }

  // بداية الأسبوع
  Future<String> getStartOfWeek() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_startWeekKey) ?? 'saturday';
  }

  Future<void> setStartOfWeek(String startDay) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startWeekKey, startDay);
  }

  // جلب جميع إعدادات المحاسبة
  Future<Map<String, dynamic>> getFinanceSettings() async {
    return {
      'currency': await getCurrency(),
      'dateFormat': await getDateFormat(),
      'backupEnabled': await getBackupEnabled(),
      'darkMode': await getDarkMode(),
      'biometricAuth': await getBiometricAuth(),
      'taxRate': await getTaxRate(),
      'startOfWeek': await getStartOfWeek(),
    };
  }
}