class Expense {
  final int? id;
  final String name;
  final double amount;
  final String? category;
  final int? carId;
  final String? expenseDate;
  final String? monthYear;
  final String? notes;

  Expense({
    this.id,
    required this.name,
    required this.amount,
    this.category,
    this.carId,
    this.expenseDate,
    this.monthYear,
    this.notes,
  });

  bool get isCarExpense => carId != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'car_id': carId,
      'expense_date': expenseDate ?? DateTime.now().toIso8601String(),
      'month_year': monthYear,
      'notes': notes,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'],
      carId: map['car_id'],
      expenseDate: map['expense_date'],
      monthYear: map['month_year'],
      notes: map['notes'],
    );
  }

  Expense copyWith({
    int? id,
    String? name,
    double? amount,
    Object? category = _sentinel,
    Object? carId = _sentinel,
    Object? expenseDate = _sentinel,
    Object? monthYear = _sentinel,
    Object? notes = _sentinel,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category == _sentinel ? this.category : category as String?,
      carId: carId == _sentinel ? this.carId : carId as int?,
      expenseDate:
          expenseDate == _sentinel ? this.expenseDate : expenseDate as String?,
      monthYear: monthYear == _sentinel ? this.monthYear : monthYear as String?,
      notes: notes == _sentinel ? this.notes : notes as String?,
    );
  }

  @override
  String toString() =>
      'Expense(id: $id, name: $name, amount: $amount, category: $category)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

const Object _sentinel = Object();
