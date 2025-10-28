// lib/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/transaction_model.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(Transaction)? onTransactionAdded;

  const AddTransactionScreen({super.key, this.onTransactionAdded});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  // متغيرات النموذج
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = '';
  String _selectedPaymentMethod = '';
  double _amount = 0.0;
  String _description = '';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة معاملة'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTransaction,
            tooltip: 'حفظ المعاملة',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // نوع المعاملة (دخل/مصروف)
                _buildTypeSelector(),
                const SizedBox(height: 20),

                // المبلغ
                _buildAmountField(),
                const SizedBox(height: 20),

                // الفئة
                _buildCategoryDropdown(),
                const SizedBox(height: 20),

                // طريقة الدفع
                _buildPaymentMethodDropdown(),
                const SizedBox(height: 20),

                // الوصف
                _buildDescriptionField(),
                const SizedBox(height: 20),

                // التاريخ
                _buildDateSelector(),
                const SizedBox(height: 30),

                // زر الحفظ
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// اختيار نوع المعاملة
  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نوع المعاملة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    'مصروف',
                    TransactionType.expense,
                    AppConstants.expenseColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    'دخل',
                    TransactionType.income,
                    AppConstants.incomeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// زر نوع المعاملة
  Widget _buildTypeButton(String text, TransactionType type, Color color) {
    final isSelected = _selectedType == type;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = ''; // إعادة تعيين الفئة عند تغيير النوع
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(text),
    );
  }

  /// حقل إدخال المبلغ
  Widget _buildAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'المبلغ (ر.س)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال المبلغ';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'يرجى إدخال مبلغ صحيح';
        }
        return null;
      },
      onSaved: (value) {
        _amount = double.parse(value!);
      },
    );
  }

  /// قائمة اختيار الفئة
  Widget _buildCategoryDropdown() {
    final categories = _selectedType == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'الفئة',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار الفئة';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  /// قائمة اختيار طريقة الدفع
  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'طريقة الدفع',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.credit_card),
      ),
      value: _selectedPaymentMethod.isNotEmpty ? _selectedPaymentMethod : null,
      items: AppConstants.paymentMethods.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(method),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار طريقة الدفع';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = value!;
        });
      },
    );
  }

  /// حقل الوصف
  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'الوصف (اختياري)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 2,
      onSaved: (value) {
        _description = value ?? '';
      },
    );
  }

  /// اختيار التاريخ
  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'التاريخ',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('yyyy-MM-dd').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// اختيار التاريخ من التقويم
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// زر الحفظ
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'حفظ المعاملة',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// حفظ المعاملة
  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // إنشاء معاملة جديدة
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: _amount,
        category: _selectedCategory,
        description: _description.isEmpty ? _selectedCategory : _description,
        date: _selectedDate,
        type: _selectedType,
        paymentMethod: _selectedPaymentMethod,
      );

      try {
        // حفظ في قاعدة البيانات
        await _databaseService.addTransaction(transaction);

        // إشعار النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ المعاملة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // إرجاع النتيجة إذا كان هناك callback
        if (widget.onTransactionAdded != null) {
          widget.onTransactionAdded!(transaction);
        }

        // العودة للشاشة السابقة
        Navigator.pop(context);
      } catch (e) {
        // إشعار الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}