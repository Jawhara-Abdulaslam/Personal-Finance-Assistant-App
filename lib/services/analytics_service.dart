// lib/services/analytics_service.dart
import '../model/transaction_model.dart';

/// خدمة لحساب الإحصائيات والتقارير المالية
class AnalyticsService {

  /// حساب إجمالي الدخل من المعاملات
  /// [transactions] قائمة جميع المعاملات
  double calculateTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// حساب إجمالي المصروفات
  double calculateTotalExpenses(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// حساب صافي الدخل (الدخل - المصروفات)
  double calculateNetIncome(List<Transaction> transactions) {
    return calculateTotalIncome(transactions) - calculateTotalExpenses(transactions);
  }

  /// تجميع المصروفات حسب الفئة
  /// Returns: Map where key is category and value is total amount
  Map<String, double> getExpensesByCategory(List<Transaction> transactions) {
    final Map<String, double> categoryTotals = {};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals.update(
          transaction.category,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return categoryTotals;
  }

  /// الحصول على المصروفات لفترة محددة
  /// [startDate] تاريخ البداية
  /// [endDate] تاريخ النهاية
  List<Transaction> getTransactionsInDateRange(
      List<Transaction> transactions,
      DateTime startDate,
      DateTime endDate
      ) {
    return transactions.where((t) =>
    t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  /// حساب متوسط المصروفات اليومية
  double calculateDailyAverage(List<Transaction> transactions, int days) {
    final totalExpenses = calculateTotalExpenses(transactions);
    return days > 0 ? totalExpenses / days : 0.0;
  }
}