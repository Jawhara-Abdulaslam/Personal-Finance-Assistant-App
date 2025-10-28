// lib/models/budget_model.dart
class Budget {
  final String id;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get spendingPercentage => allocatedAmount > 0 ? spentAmount / allocatedAmount : 0.0;
  bool get isOverBudget => spentAmount > allocatedAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      allocatedAmount: map['allocatedAmount'],
      spentAmount: map['spentAmount'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
    );
  }
}