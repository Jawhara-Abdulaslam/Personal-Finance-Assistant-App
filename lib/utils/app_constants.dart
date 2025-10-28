// lib/utils/app_constants.dart

import 'dart:ui';

/// فئات المصروفات الأساسية
class AppConstants {
  static const List<String> expenseCategories = [
    '🍔 الطعام',
    '🚗 المواصلات',
    '🏠 السكن',
    '⚡ المرافق',
    '🎮 الترفيه',
    '🛒 تسوق',
    '🏥 الصحة',
    '📚 التعليم',
    '🎁 هدايا',
    '✈️ سفر',
    '🔧 صيانة',
    '📱 اشتراكات',
    '💼 أخرى'
  ];

  static const List<String> incomeCategories = [
    '💰 راتب',
    '🏢 عمل حر',
    '📊 استثمار',
    '🎁 هدية',
    '↩️ استرداد',
    '💼 أخرى'
  ];

  static const List<String> paymentMethods = [
    '💵 نقدي',
    '💳 بطاقة ائتمان',
    '💳 بطاقة خصم',
    '📱 محفظة إلكترونية',
    '🏦 تحويل بنكي',
    '📊 أخرى'
  ];

  /// ألوان التطبيق
  static const primaryColor = Color(0xFF2E7D32);
  static const secondaryColor = Color(0xFF4CAF50);
  static const incomeColor = Color(0xFF4CAF50);
  static const expenseColor = Color(0xFFF44336);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const cardColor = Color(0xFFFFFFFF);
}