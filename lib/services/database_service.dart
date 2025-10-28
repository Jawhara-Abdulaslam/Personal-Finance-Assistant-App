// lib/services/database_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../model/budget_model.dart';
import '../model/transaction_model.dart';

/// خدمة للتعامل مع التخزين المحلي
/// تستخدم shared_preferences لتخزين البيانات
class DatabaseService {
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';
  static const String _userKey = 'user_settings';

  /// حفظ قائمة المعاملات
  /// [transactions] قائمة المعاملات المراد حفظها
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();

    // تحويل كل معاملة لـ Map ثم لـ JSON
    final transactionsJson = transactions.map((t) => t.toMap()).toList();

    // حفظ كـ JSON string
    await prefs.setString(_transactionsKey, json.encode(transactionsJson));
  }

  /// جلب قائمة المعاملات المحفوظة
  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_transactionsKey);

    if (transactionsJson == null) return [];

    try {
      // تحويل JSON string لـ List ثم لـ كائنات Transaction
      final List<dynamic> transactionsList = json.decode(transactionsJson);
      return transactionsList.map((item) => Transaction.fromMap(item)).toList();
    } catch (e) {
      print('خطأ في قراءة المعاملات: $e');
      return [];
    }
  }

  /// إضافة معاملة جديدة
  /// [transaction] المعاملة الجديدة المراد إضافتها
  Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  /// حذف معاملة
  /// [transactionId] معرف المعاملة المراد حذفها
  Future<void> deleteTransaction(String transactionId) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == transactionId);
    await saveTransactions(transactions);
  }

  /// حفظ الميزانيات
  Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = budgets.map((b) => b.toMap()).toList();
    await prefs.setString(_budgetsKey, json.encode(budgetsJson));
  }

  /// جلب الميزانيات
  Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getString(_budgetsKey);

    if (budgetsJson == null) return [];

    try {
      final List<dynamic> budgetsList = json.decode(budgetsJson);
      return budgetsList.map((item) => Budget.fromMap(item)).toList();
    } catch (e) {
      print('خطأ في قراءة الميزانيات: $e');
      return [];
    }
  }

  /// تحديث المبلغ المنفق في الميزانية
  /// [category] فئة الميزانية
  /// [amount] المبلغ المراد إضافته للمنفق
  Future<void> updateBudgetSpending(String category, double amount) async {
    final budgets = await getBudgets();
    final budgetIndex = budgets.indexWhere((b) => b.category == category);

    if (budgetIndex != -1) {
      budgets[budgetIndex] = Budget(
        id: budgets[budgetIndex].id,
        category: budgets[budgetIndex].category,
        allocatedAmount: budgets[budgetIndex].allocatedAmount,
        spentAmount: budgets[budgetIndex].spentAmount + amount,
        startDate: budgets[budgetIndex].startDate,
        endDate: budgets[budgetIndex].endDate,
      );
      await saveBudgets(budgets);
    }
  }
}