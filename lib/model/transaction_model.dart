// lib/models/transaction_model.dart

/// نوع المعاملة: دخل أو مصروف
/// [income] للإيرادات والمداخيل
/// [expense] للمصروفات والمدفوعات
enum TransactionType { income, expense }

/// نموذج يمثل معاملة مالية
/// يحتوي على جميع بيانات المعاملة المالية
class Transaction {
  final String id;                    // معرف فريد للمعاملة
  final double amount;               // المبلغ
  final String category;             // الفئة (طعام، مواصلات، راتب...)
  final String description;          // وصف تفصيلي
  final DateTime date;               // تاريخ المعاملة
  final TransactionType type;        // النوع (دخل/مصروف)
  final String paymentMethod;        // طريقة الدفع (نقدي، بطاقة...)

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
    required this.paymentMethod,
  });

  /// تحويل الكائن لـ Map لتخزينه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),  // تحويل التاريخ لنص
      'type': type.toString(),         // تحويل النوع لنص
      'paymentMethod': paymentMethod,
    };
  }

  /// إنشاء كائن Transaction من Map (عند القراءة من قاعدة البيانات)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),  // تحويل النص لتاريخ
      type: map['type'] == 'TransactionType.income'
          ? TransactionType.income
          : TransactionType.expense,
      paymentMethod: map['paymentMethod'],
    );
  }
}