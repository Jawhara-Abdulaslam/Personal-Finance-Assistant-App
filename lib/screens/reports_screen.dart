// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/transaction_model.dart';
import '../services/analytics_service.dart';
import '../utils/app_constants.dart';

class ReportsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const ReportsScreen({super.key, required this.transactions});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'monthly';

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _analyticsService.getTransactionsInDateRange(
        widget.transactions,
        _startDate,
        _endDate
    );

    final totalIncome = _analyticsService.calculateTotalIncome(filteredTransactions);
    final totalExpenses = _analyticsService.calculateTotalExpenses(filteredTransactions);
    final netIncome = _analyticsService.calculateNetIncome(filteredTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          // فلتر التاريخ
          _buildDateFilter(),

          // ملخص سريع
          _buildQuickSummary(totalIncome, totalExpenses, netIncome),

          // التقارير التفصيلية
          Expanded(
            child: _buildDetailedReports(filteredTransactions),
          ),
        ],
      ),
    );
  }

  /// فلتر التاريخ
  Widget _buildDateFilter() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'الفترة الزمنية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton('أسبوع', Duration(days: 7)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateButton('شهر', Duration(days: 30)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateButton('3 أشهر', Duration(days: 90)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('من', _startDate, true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField('إلى', _endDate, false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// زر فترة زمنية سريعة
  Widget _buildDateButton(String label, Duration duration) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _endDate = DateTime.now();
          _startDate = _endDate.subtract(duration);
        });
      },
      child: Text(label),
    );
  }

  /// حقل التاريخ
  Widget _buildDateField(String label, DateTime date, bool isStartDate) {
    return InkWell(
      onTap: () => _selectDate(isStartDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('yyyy-MM-dd').format(date)),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  /// اختيار التاريخ
  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  /// الملخص السريع
  Widget _buildQuickSummary(double income, double expenses, double net) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('الدخل', income, AppConstants.incomeColor),
            _buildSummaryItem('المصروفات', expenses, AppConstants.expenseColor),
            _buildSummaryItem('الصافي', net,
                net >= 0 ? AppConstants.incomeColor : AppConstants.expenseColor),
          ],
        ),
      ),
    );
  }

  /// عنصر في الملخص
  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} ر.س',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// التقارير التفصيلية
  Widget _buildDetailedReports(List<Transaction> transactions) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // تقرير المصروفات حسب الفئة
        _buildExpensesByCategory(transactions),
        const SizedBox(height: 16),

        // تقرير الدخل حسب الفئة
        _buildIncomeByCategory(transactions),
        const SizedBox(height: 16),

        // آخر المعاملات
        _buildRecentTransactions(transactions),
      ],
    );
  }

  /// تقرير المصروفات حسب الفئة
  Widget _buildExpensesByCategory(List<Transaction> transactions) {
    final expensesByCategory = _analyticsService.getExpensesByCategory(transactions);
    final totalExpenses = expensesByCategory.values.fold(0.0, (sum, amount) => sum + amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المصروفات حسب الفئة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...expensesByCategory.entries.map((entry) {
              final percentage = (entry.value / totalExpenses) * 100;
              return _buildCategoryItem(entry.key, entry.value, percentage, false);
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// تقرير الدخل حسب الفئة
  Widget _buildIncomeByCategory(List<Transaction> transactions) {
    final incomeTransactions = transactions.where((t) => t.type == TransactionType.income).toList();
    final incomeByCategory = <String, double>{};

    for (final transaction in incomeTransactions) {
      incomeByCategory.update(
        transaction.category,
            (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final totalIncome = incomeByCategory.values.fold(0.0, (sum, amount) => sum + amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الدخل حسب الفئة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...incomeByCategory.entries.map((entry) {
              final percentage = (entry.value / totalIncome) * 100;
              return _buildCategoryItem(entry.key, entry.value, percentage, true);
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// عنصر الفئة في التقرير
  Widget _buildCategoryItem(String category, double amount, double percentage, bool isIncome) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(category),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${amount.toStringAsFixed(0)} ر.س',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isIncome ? AppConstants.incomeColor : AppConstants.expenseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// آخر المعاملات
  Widget _buildRecentTransactions(List<Transaction> transactions) {
    final recentTransactions = transactions.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'آخر المعاملات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (recentTransactions.isEmpty)
              const Center(
                child: Text('لا توجد معاملات في هذه الفترة'),
              )
            else
              ...recentTransactions.map((transaction) =>
                  _buildTransactionRow(transaction)
              ).toList(),
          ],
        ),
      ),
    );
  }

  /// صف المعاملة في التقرير
  Widget _buildTransactionRow(Transaction transaction) {
    return ListTile(
      leading: Icon(
        transaction.type == TransactionType.income
            ? Icons.arrow_downward
            : Icons.arrow_upward,
        color: transaction.type == TransactionType.income
            ? AppConstants.incomeColor
            : AppConstants.expenseColor,
      ),
      title: Text(transaction.description),
      subtitle: Text(
        '${transaction.category} • ${DateFormat('MM-dd').format(transaction.date)}',
      ),
      trailing: Text(
        '${transaction.amount.toStringAsFixed(0)} ر.س',
        style: TextStyle(
          color: transaction.type == TransactionType.income
              ? AppConstants.incomeColor
              : AppConstants.expenseColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}