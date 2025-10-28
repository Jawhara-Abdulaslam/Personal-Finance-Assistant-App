// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../model/transaction_model.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import '../utils/app_constants.dart';
import 'analytics_screen.dart';
import 'reports_screen.dart';
import 'budgets_screen.dart';
import 'add_transaction_screen.dart';
import 'finance_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AnalyticsService _analyticsService = AnalyticsService();

  List<Transaction> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _netIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// تحميل البيانات من قاعدة البيانات
  Future<void> _loadData() async {
    final transactions = await _databaseService.getTransactions();

    setState(() {
      _transactions = transactions;
      _totalIncome = _analyticsService.calculateTotalIncome(transactions);
      _totalExpenses = _analyticsService.calculateTotalExpenses(transactions);
      _netIncome = _analyticsService.calculateNetIncome(transactions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('المحاسب الشخصي'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          // زر التقارير
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportsScreen(transactions: _transactions),
                ),
              );
            },
            tooltip: 'التقارير',
          ),
          // زر التحليل الرسومي
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalyticsScreen(transactions: _transactions),
                ),
              );
            },
            tooltip: 'التحليل الرسومي',
          ),
          // زر الميزانيات
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetsScreen()),
              );
            },
            tooltip: 'الميزانيات',
          ),
          // زر الإعدادات
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinanceSettingsScreen()),
              );
            },
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTransaction,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // بطاقة الملخص المالي
          _buildSummaryCard(),

          const SizedBox(height: 20),

          // البطاقات السريعة
          _buildQuickCards(),

          const SizedBox(height: 20),

          // الإحصائيات السريعة
          _buildQuickStats(),

          const SizedBox(height: 20),

          // آخر المعاملات
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  /// بطاقة عرض الملخص المالي
  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'الملخص المالي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('الدخل', _totalIncome, AppConstants.incomeColor),
                _buildSummaryItem('المصروفات', _totalExpenses, AppConstants.expenseColor),
                _buildSummaryItem('الصافي', _netIncome,
                    _netIncome >= 0 ? AppConstants.incomeColor : AppConstants.expenseColor),
              ],
            ),
            const SizedBox(height: 16),
            // شريط التقدم
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  /// شريط التقدم للمصروفات مقابل الدخل
  Widget _buildProgressIndicator() {
    final total = _totalIncome + _totalExpenses;
    final expensePercentage = total > 0 ? _totalExpenses / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة المصروفات: ${(expensePercentage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'نسبة التوفير: ${((1 - expensePercentage) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: expensePercentage,
          backgroundColor: AppConstants.incomeColor.withOpacity(0.3),
          color: AppConstants.expenseColor,
        ),
      ],
    );
  }

  /// البطاقات السريعة للوظائف
  Widget _buildQuickCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildQuickCard(
          'إضافة معاملة',
          Icons.add_circle,
          Colors.green,
          _addNewTransaction,
        ),
        _buildQuickCard(
          'التقارير',
          Icons.assessment,
          Colors.blue,
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportsScreen(transactions: _transactions),
              ),
            );
          },
        ),
        _buildQuickCard(
          'التحليل',
          Icons.analytics,
          Colors.orange,
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnalyticsScreen(transactions: _transactions),
              ),
            );
          },
        ),
        _buildQuickCard(
          'الميزانيات',
          Icons.account_balance_wallet,
          Colors.purple,
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetsScreen()),
            );
          },
        ),
      ],
    );
  }

  /// بطاقة سريعة
  Widget _buildQuickCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// عنصر في الملخص المالي
  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} ر.س',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// الإحصائيات السريعة
  Widget _buildQuickStats() {
    final categoryExpenses = _analyticsService.getExpensesByCategory(_transactions);
    final topCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(3);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أعلى المصروفات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (topCategories.isEmpty)
              const Center(
                child: Text(
                  'لا توجد مصروفات',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...topCategories.map((entry) =>
                  _buildCategoryRow(entry.key, entry.value)
              ).toList(),
          ],
        ),
      ),
    );
  }

  /// صف عرض فئة المصروفات
  Widget _buildCategoryRow(String category, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${amount.toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppConstants.expenseColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// عرض آخر المعاملات
  Widget _buildRecentTransactions() {
    final recentTransactions = _transactions
      ..sort((a, b) => b.date.compareTo(a.date))
      ..take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'آخر المعاملات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_transactions.length > 5)
                  TextButton(
                    onPressed: () {
                      // يمكنك إضافة شاشة عرض جميع المعاملات لاحقاً
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportsScreen(transactions: _transactions),
                        ),
                      );
                    },
                    child: const Text('عرض الكل'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentTransactions.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'لا توجد معاملات',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'انقر على + لإضافة معاملة جديدة',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...recentTransactions.map((transaction) =>
                  _buildTransactionTile(transaction)
              ).toList(),
          ],
        ),
      ),
    );
  }

  /// عنصر عرض معاملة
  Widget _buildTransactionTile(Transaction transaction) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: transaction.type == TransactionType.income
              ? AppConstants.incomeColor.withOpacity(0.2)
              : AppConstants.expenseColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          transaction.type == TransactionType.income
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: transaction.type == TransactionType.income
              ? AppConstants.incomeColor
              : AppConstants.expenseColor,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${transaction.category} • ${_formatDate(transaction.date)}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${transaction.amount.toStringAsFixed(2)} ر.س',
            style: TextStyle(
              color: transaction.type == TransactionType.income
                  ? AppConstants.incomeColor
                  : AppConstants.expenseColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            transaction.paymentMethod,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// إضافة معاملة جديدة
  void _addNewTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          onTransactionAdded: (transaction) {
            // إعادة تحميل البيانات عند إضافة معاملة جديدة
            _loadData();
          },
        ),
      ),
    );
  }
}