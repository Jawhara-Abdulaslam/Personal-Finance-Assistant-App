// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../model/transaction_model.dart';
import '../services/analytics_service.dart';
import '../utils/app_constants.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const AnalyticsScreen({super.key, required this.transactions});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  int _selectedTab = 0; // 0: المصروفات, 1: الدخل, 2: المقارنة
  String _selectedPeriod = 'شهري'; // شهري, أسبوعي, سنوي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('التحليل الرسومي'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          // أزرار التبويب
          _buildTabButtons(),

          // اختيار الفترة
          _buildPeriodSelector(),

          // الرسوم البيانية
          Expanded(
            child: _buildCharts(),
          ),
        ],
      ),
    );
  }

  /// أزرار التبويب لاختيار نوع التحليل
  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTabButton('المصروفات', 0),
          _buildTabButton('الدخل', 1),
          _buildTabButton('المقارنة', 2),
        ],
      ),
    );
  }

  /// زر تبويب فردي
  Widget _buildTabButton(String text, int index) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedTab = index;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedTab == index
                ? AppConstants.primaryColor
                : Colors.grey[300],
            foregroundColor: _selectedTab == index ? Colors.white : Colors.black,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  /// اختيار الفترة الزمنية
  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPeriodButton('أسبوعي'),
          _buildPeriodButton('شهري'),
          _buildPeriodButton('سنوي'),
        ],
      ),
    );
  }

  /// زر فترة زمنية
  Widget _buildPeriodButton(String period) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(period),
        selected: _selectedPeriod == period,
        onSelected: (selected) {
          setState(() {
            _selectedPeriod = period;
          });
        },
        selectedColor: AppConstants.primaryColor,
        labelStyle: TextStyle(
          color: _selectedPeriod == period ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  /// بناء الرسوم البيانية حسب الاختيار
  Widget _buildCharts() {
    switch (_selectedTab) {
      case 0:
        return _buildExpensesCharts();
      case 1:
        return _buildIncomeCharts();
      case 2:
        return _buildComparisonCharts();
      default:
        return _buildExpensesCharts();
    }
  }

  /// رسوم بيانية للمصروفات
  Widget _buildExpensesCharts() {
    final categoryExpenses = _analyticsService.getExpensesByCategory(widget.transactions);

    return SingleChildScrollView(
      child: Column(
        children: [
          // مخطط دائري للمصروفات
          _buildPieChart(categoryExpenses),

          const SizedBox(height: 20),

          // مخطط أعمدة للمصروفات
          _buildBarChart(categoryExpenses),

          const SizedBox(height: 20),

          // قائمة تفصيلية بالفئات
          _buildCategoriesList(categoryExpenses),
        ],
      ),
    );
  }

  /// مخطط دائري للمصروفات
  Widget _buildPieChart(Map<String, double> categoryExpenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'توزيع المصروفات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(categoryExpenses),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء أقسام المخطط الدائري
  List<PieChartSectionData> _buildPieChartSections(Map<String, double> categoryExpenses) {
    final totalExpenses = categoryExpenses.values.fold(0.0, (sum, amount) => sum + amount);

    // ألوان متنوعة للفئات
    final List<Color> colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.red, Colors.teal, Colors.pink, Colors.indigo,
      Colors.amber, Colors.cyan, Colors.deepOrange, Colors.lime,
    ];

    return categoryExpenses.entries.map((entry) {
      final percentage = (entry.value / totalExpenses) * 100;
      final color = colors[categoryExpenses.keys.toList().indexOf(entry.key) % colors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// مخطط أعمدة للمصروفات
  Widget _buildBarChart(Map<String, double> categoryExpenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'المصروفات حسب الفئة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _buildBarChartGroups(categoryExpenses),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: _buildBarChartTitles(categoryExpenses),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء مجموعات الأعمدة
  List<BarChartGroupData> _buildBarChartGroups(Map<String, double> categoryExpenses) {
    return categoryExpenses.entries.map((entry) {
      final index = categoryExpenses.keys.toList().indexOf(entry.key);
      final color = [
        Colors.blue, Colors.green, Colors.orange, Colors.purple,
        Colors.red, Colors.teal, Colors.pink, Colors.indigo,
      ][index % 8];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: color,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  /// عناوين المخطط العمودي
  FlTitlesData _buildBarChartTitles(Map<String, double> categoryExpenses) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final category = categoryExpenses.keys.toList()[value.toInt()];
            // عرض أول كلمتين فقط لتجنب الازدحام
            final shortName = category.split(' ').take(2).join(' ');
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                shortName,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  /// قائمة تفصيلية بالفئات
  Widget _buildCategoriesList(Map<String, double> categoryExpenses) {
    final totalExpenses = categoryExpenses.values.fold(0.0, (sum, amount) => sum + amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفصيل المصروفات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...categoryExpenses.entries.map((entry) {
              final percentage = (entry.value / totalExpenses) * 100;
              return _buildCategoryListItem(entry.key, entry.value, percentage);
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// عنصر في قائمة الفئات
  Widget _buildCategoryListItem(String category, double amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // دائرة صغيرة للون
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(category),
          ),
          Text('${amount.toStringAsFixed(2)} ر.س'),
          const SizedBox(width: 8),
          Text(
            '(${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// الحصول على لون ثابت لكل فئة
  Color _getCategoryColor(String category) {
    final colors = {
      '🍔 الطعام': Colors.orange,
      '🚗 المواصلات': Colors.blue,
      '🏠 السكن': Colors.green,
      '⚡ المرافق': Colors.yellow,
      '🎮 الترفيه': Colors.purple,
      '🛒 تسوق': Colors.pink,
      '🏥 الصحة': Colors.red,
      '📚 التعليم': Colors.teal,
      '🎁 هدايا': Colors.amber,
      '✈️ سفر': Colors.cyan,
      '🔧 صيانة': Colors.deepOrange,
      '📱 اشتراكات': Colors.indigo,
      '💼 أخرى': Colors.grey,
    };

    return colors[category] ?? Colors.grey;
  }

  /// رسوم بيانية للدخل
  Widget _buildIncomeCharts() {
    final incomeTransactions = widget.transactions
        .where((t) => t.type == TransactionType.income)
        .toList();

    final incomeByCategory = _groupIncomeByCategory(incomeTransactions);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildIncomePieChart(incomeByCategory),
          const SizedBox(height: 20),
          _buildIncomeTrendChart(incomeTransactions),
        ],
      ),
    );
  }

  /// تجميع الدخل حسب الفئة
  Map<String, double> _groupIncomeByCategory(List<Transaction> incomeTransactions) {
    final Map<String, double> incomeByCategory = {};

    for (final transaction in incomeTransactions) {
      incomeByCategory.update(
        transaction.category,
            (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return incomeByCategory;
  }

  /// مخطط دائري للدخل
  Widget _buildIncomePieChart(Map<String, double> incomeByCategory) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'توزيع الدخل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(incomeByCategory),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// مخطط اتجاه الدخل
  Widget _buildIncomeTrendChart(List<Transaction> incomeTransactions) {
    // تجميع الدخل حسب الشهر
    final monthlyIncome = _groupIncomeByMonth(incomeTransactions);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'اتجاه الدخل الشهري',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyIncome.entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: AppConstants.incomeColor,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: _buildLineChartTitles(monthlyIncome),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تجميع الدخل حسب الشهر
  Map<int, double> _groupIncomeByMonth(List<Transaction> incomeTransactions) {
    final Map<int, double> monthlyIncome = {};

    for (final transaction in incomeTransactions) {
      final month = transaction.date.month;
      monthlyIncome.update(
        month,
            (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return monthlyIncome;
  }

  /// عناوين المخطط الخطي
  FlTitlesData _buildLineChartTitles(Map<int, double> monthlyIncome) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final monthNames = [
              '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
              'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
            ];
            final month = value.toInt();
            return Text(
              month >= 1 && month <= 12 ? monthNames[month] : '',
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  /// رسوم بيانية للمقارنة بين الدخل والمصروفات
  Widget _buildComparisonCharts() {
    final monthlyComparison = _getMonthlyComparison();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildComparisonBarChart(monthlyComparison),
          const SizedBox(height: 20),
          _buildSavingsChart(monthlyComparison),
        ],
      ),
    );
  }

  /// الحصول على بيانات المقارنة الشهرية
  Map<String, Map<String, double>> _getMonthlyComparison() {
    final Map<String, Map<String, double>> monthlyData = {};

    for (final transaction in widget.transactions) {
      final monthKey = DateFormat('yyyy-MM').format(transaction.date);
      final type = transaction.type == TransactionType.income ? 'income' : 'expense';

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {'income': 0.0, 'expense': 0.0};
      }

      monthlyData[monthKey]![type] = monthlyData[monthKey]![type]! + transaction.amount;
    }

    return monthlyData;
  }

  /// مخطط أعمدة للمقارنة
  Widget _buildComparisonBarChart(Map<String, Map<String, double>> monthlyComparison) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'المقارنة الشهرية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _buildComparisonBarGroups(monthlyComparison),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: _buildComparisonTitles(monthlyComparison),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء مجموعات أعمدة المقارنة
  List<BarChartGroupData> _buildComparisonBarGroups(Map<String, Map<String, double>> monthlyComparison) {
    final months = monthlyComparison.keys.toList();

    return months.asMap().entries.map((entry) {
      final index = entry.key;
      final monthData = monthlyComparison[entry.value]!;

      return BarChartGroupData(
        x: index,
        groupVertically: true,
        barRods: [
          // عمود الدخل
          BarChartRodData(
            toY: monthData['income']!,
            color: AppConstants.incomeColor,
            width: 12,
            borderRadius: BorderRadius.circular(2),
          ),
          // عمود المصروفات
          BarChartRodData(
            toY: monthData['expense']!,
            color: AppConstants.expenseColor,
            width: 12,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }).toList();
  }

  /// عناوين مخطط المقارنة
  FlTitlesData _buildComparisonTitles(Map<String, Map<String, double>> monthlyComparison) {
    final months = monthlyComparison.keys.toList();

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < months.length) {
              final monthStr = months[index];
              final parts = monthStr.split('-');
              final monthName = _getMonthName(int.parse(parts[1]));
              return Text(
                monthName,
                style: const TextStyle(fontSize: 10),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  /// الحصول على اسم الشهر
  String _getMonthName(int month) {
    final monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month >= 1 && month <= 12 ? monthNames[month] : '';
  }

  /// مخطط المدخرات
  Widget _buildSavingsChart(Map<String, Map<String, double>> monthlyComparison) {
    final savingsData = monthlyComparison.map((key, value) {
      final savings = value['income']! - value['expense']!;
      return MapEntry(key, savings);
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'المدخرات الشهرية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: savingsData.entries.map((entry) {
                    final index = savingsData.keys.toList().indexOf(entry.key);
                    final isPositive = entry.value >= 0;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.abs(),
                          color: isPositive ? Colors.green : Colors.red,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: _buildSavingsTitles(savingsData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عناوين مخطط المدخرات
  FlTitlesData _buildSavingsTitles(Map<String, double> savingsData) {
    final months = savingsData.keys.toList();

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < months.length) {
              final monthStr = months[index];
              final parts = monthStr.split('-');
              final monthName = _getMonthName(int.parse(parts[1]));
              return Text(
                monthName,
                style: const TextStyle(fontSize: 10),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }
}