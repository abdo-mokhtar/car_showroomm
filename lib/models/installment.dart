class Installment {
  final int? id;
  final int saleId;
  final double amount;
  final String dueDate;
  final bool paid;
  final String? paidDate;
  final String? notes;

  Installment({
    this.id,
    required this.saleId,
    required this.amount,
    required this.dueDate,
    this.paid = false,
    this.paidDate,
    this.notes,
  });

  bool get isOverdue {
    if (paid) return false;
    final due = DateTime.tryParse(dueDate);
    if (due == null) return false;
    return DateTime.now().isAfter(due);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'amount': amount,
      'due_date': dueDate,
      'paid': paid ? 1 : 0,
      'paid_date': paidDate,
      'notes': notes,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      id: map['id'],
      saleId: map['sale_id'],
      amount: (map['amount'] as num? ?? 0).toDouble(),
      dueDate: map['due_date'] ?? '',
      paid: (map['paid'] ?? 0) == 1,
      paidDate: map['paid_date'],
      notes: map['notes'],
    );
  }

  Installment copyWith({
    int? id,
    int? saleId,
    double? amount,
    String? dueDate,
    bool? paid,
    Object? paidDate = _sentinel,
    Object? notes = _sentinel,
  }) {
    return Installment(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paid: paid ?? this.paid,
      paidDate: paidDate == _sentinel ? this.paidDate : paidDate as String?,
      notes: notes == _sentinel ? this.notes : notes as String?,
    );
  }

  @override
  String toString() =>
      'Installment(id: $id, saleId: $saleId, amount: $amount, paid: $paid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Installment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

const Object _sentinel = Object();
