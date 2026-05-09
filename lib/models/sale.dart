class Sale {
  final int? id;
  final int carId;
  final int? customerId;
  final double salePrice;
  final String? paymentType; // cash / transfer / check / installment
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final double profit;
  final String? saleDate;
  final String? employeeName;
  final String? monthYear;
  final String? notes;

  Sale({
    this.id,
    required this.carId,
    this.customerId,
    required this.salePrice,
    this.paymentType,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.profit = 0,
    this.saleDate,
    this.employeeName,
    this.monthYear,
    this.notes,
  });

  bool get isFullyPaid => remainingAmount <= 0;
  bool get hasInstallments => paymentType == 'installment';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'car_id': carId,
      'customer_id': customerId,
      'sale_price': salePrice,
      'payment_type': paymentType,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'profit': profit,
      'sale_date': saleDate ?? DateTime.now().toIso8601String(),
      'employee_name': employeeName,
      'month_year': monthYear,
      'notes': notes,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      carId: map['car_id'],
      customerId: map['customer_id'],
      salePrice: (map['sale_price'] ?? 0).toDouble(),
      paymentType: map['payment_type'],
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      paidAmount: (map['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (map['remaining_amount'] ?? 0).toDouble(),
      profit: (map['profit'] ?? 0).toDouble(),
      saleDate: map['sale_date'],
      employeeName: map['employee_name'],
      monthYear: map['month_year'],
      notes: map['notes'],
    );
  }

  Sale copyWith({
    int? id,
    int? carId,
    Object? customerId = _sentinel,
    double? salePrice,
    Object? paymentType = _sentinel,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    double? profit,
    Object? saleDate = _sentinel,
    Object? employeeName = _sentinel,
    Object? monthYear = _sentinel,
    Object? notes = _sentinel,
  }) {
    return Sale(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      customerId:
          customerId == _sentinel ? this.customerId : customerId as int?,
      salePrice: salePrice ?? this.salePrice,
      paymentType:
          paymentType == _sentinel ? this.paymentType : paymentType as String?,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      profit: profit ?? this.profit,
      saleDate: saleDate == _sentinel ? this.saleDate : saleDate as String?,
      employeeName: employeeName == _sentinel
          ? this.employeeName
          : employeeName as String?,
      monthYear: monthYear == _sentinel ? this.monthYear : monthYear as String?,
      notes: notes == _sentinel ? this.notes : notes as String?,
    );
  }

  @override
  String toString() =>
      'Sale(id: $id, carId: $carId, salePrice: $salePrice, profit: $profit)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

const Object _sentinel = Object();
