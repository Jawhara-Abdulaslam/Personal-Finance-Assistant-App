// lib/screens/budgets_screen.dart
import 'package:flutter/material.dart';
import '../model/budget_model.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgets = await _databaseService.getBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الميزانيات'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewBudget,
            tooltip: 'إضافة ميزانية جديدة',
          ),
        ],
      ),
      body: _budgets.isEmpty ? _buildEmptyState() : _buildBudgetsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBudget,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// واجهة الحالة الفارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'لا توجد ميزانيات',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'أنشئ ميزانيتك الأولى لتتبع مصروفاتك',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addNewBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('إضافة ميزانية جديدة'),
          ),
        ],
      ),
    );
  }

  /// قائمة الميزانيات
  Widget _buildBudgetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _budgets.length,
      itemBuilder: (context, index) {
        final budget = _budgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  /// بطاقة الميزانية
  Widget _buildBudgetCard(Budget budget) {
    final percentage = budget.spendingPercentage;
    final isOverBudget = budget.isOverBudget;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(
                  isOverBudget ? Icons.warning : Icons.check_circle,
                  color: isOverBudget ? Colors.red : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // شريط التقدم
            LinearProgressIndicator(
              value: percentage > 1 ? 1 : percentage,
              backgroundColor: Colors.grey[200],
              color: isOverBudget ? Colors.red : AppConstants.primaryColor,
            ),
            const SizedBox(height: 8),

            // الأرقام
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetAmount('المنفق', budget.spentAmount, Colors.grey),
                _buildBudgetAmount('المتبقي', budget.remainingAmount,
                    isOverBudget ? Colors.red : Colors.green),
                _buildBudgetAmount('المخصص', budget.allocatedAmount, AppConstants.primaryColor),
              ],
            ),
            const SizedBox(height: 8),

            // التاريخ
            Text(
              '${_formatDate(budget.startDate)} - ${_formatDate(budget.endDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض مبلغ الميزانية
  Widget _buildBudgetAmount(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} ر.س',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// إضافة ميزانية جديدة
  void _addNewBudget() {
    _showAddBudgetDialog();
  }

  /// عرض نافذة إضافة ميزانية
  void _showAddBudgetDialog() {
    String selectedCategory = AppConstants.expenseCategories.first;
    double allocatedAmount = 0.0;
    int durationMonths = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة ميزانية جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: AppConstants.expenseCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                  decoration: const InputDecoration(labelText: 'الفئة'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'المبلغ المخصص (ر.س)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    allocatedAmount = double.tryParse(value) ?? 0.0;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'المدة (أشهر)',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  onChanged: (value) {
                    durationMonths = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _createNewBudget(selectedCategory, allocatedAmount, durationMonths);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  /// إنشاء ميزانية جديدة
  void _createNewBudget(String category, double allocatedAmount, int durationMonths) async {
    if (allocatedAmount <= 0) {
      _showError('يرجى إدخال مبلغ صحيح');
      return;
    }

    final newBudget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      allocatedAmount: allocatedAmount,
      spentAmount: 0.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30 * durationMonths)),
    );

    try {
      final budgets = await _databaseService.getBudgets();
      budgets.add(newBudget);
      await _databaseService.saveBudgets(budgets);

      _loadBudgets(); // إعادة تحميل البيانات

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الميزانية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('خطأ في حفظ الميزانية: $e');
    }
  }

  /// عرض رسالة خطأ
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// // lib/screens/budgets_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../model/budget_model.dart';
// import '../services/database_service.dart';
// import '../utils/app_constants.dart';
//
// class BudgetsScreen extends StatefulWidget {
//   const BudgetsScreen({super.key});
//
//   @override
//   State<BudgetsScreen> createState() => _BudgetsScreenState();
// }
//
// class _BudgetsScreenState extends State<BudgetsScreen> {
//   final DatabaseService _databaseService = DatabaseService();
//   List<Budget> _budgets = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBudgets();
//   }
//
//   Future<void> _loadBudgets() async {
//     final budgets = await _databaseService.getBudgets();
//     setState(() {
//       _budgets = budgets;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الميزانيات'),
//         backgroundColor: AppConstants.primaryColor,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: _addNewBudget,
//             tooltip: 'إضافة ميزانية جديدة',
//           ),
//         ],
//       ),
//       body: _budgets.isEmpty ? _buildEmptyState() : _buildBudgetsList(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addNewBudget,
//         backgroundColor: AppConstants.primaryColor,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
//
//   /// واجهة الحالة الفارغة
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey),
//           const SizedBox(height: 16),
//           const Text(
//             'لا توجد ميزانيات',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'أنشئ ميزانيتك الأولى لتتبع مصروفاتك',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _addNewBudget,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppConstants.primaryColor,
//             ),
//             child: const Text('إضافة ميزانية جديدة'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// قائمة الميزانيات
//   Widget _buildBudgetsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _budgets.length,
//       itemBuilder: (context, index) {
//         final budget = _budgets[index];
//         return _buildBudgetCard(budget);
//       },
//     );
//   }
//
//   /// بطاقة الميزانية
//   Widget _buildBudgetCard(Budget budget) {
//     final percentage = budget.spendingPercentage;
//     final isOverBudget = budget.isOverBudget;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // رأس البطاقة
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   budget.category,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Icon(
//                   isOverBudget ? Icons.warning : Icons.check_circle,
//                   color: isOverBudget ? Colors.red : Colors.green,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//
//             // شريط التقدم
//             LinearProgressIndicator(
//               value: percentage > 1 ? 1 : percentage,
//               backgroundColor: Colors.grey[200],
//               color: isOverBudget ? Colors.red : AppConstants.primaryColor,
//             ),
//             const SizedBox(height: 8),
//
//             // الأرقام
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildBudgetAmount('المنفق', budget.spentAmount, Colors.grey),
//                 _buildBudgetAmount('المتبقي', budget.remainingAmount,
//                     isOverBudget ? Colors.red : Colors.green),
//                 _buildBudgetAmount('المخصص', budget.allocatedAmount, AppConstants.primaryColor),
//               ],
//             ),
//             const SizedBox(height: 8),
//
//             // التاريخ
//             Text(
//               '${DateFormat('yyyy-MM-dd').format(budget.startDate)} - ${DateFormat('yyyy-MM-dd').format(budget.endDate)}',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// عرض مبلغ الميزانية
//   Widget _buildBudgetAmount(String label, double amount, Color color) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '${amount.toStringAsFixed(0)} ر.س',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// إضافة ميزانية جديدة
//   void _addNewBudget() {
//     // سيتم تنفيذها في الخطوة التالية
//     print('فتح شاشة إضافة ميزانية جديدة');
//   }
// }