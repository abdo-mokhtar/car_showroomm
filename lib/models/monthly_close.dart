class MonthlyClose {
  final int? id;
  final String periodName;
  final String startDate;
  final String endDate;
  final String? monthYear;
  final double totalSales;
  final double totalExpenses;
  final double totalProfit;
  final int carsSold;
  final int? closedBy;
  final String? closedAt;
  final bool isClosed;
  final String? notes;

  MonthlyClose({
    this.id,
    required this.periodName,
    required this.startDate,
    required this.endDate,
    this.monthYear,
    this.totalSales = 0,
    this.totalExpenses = 0,
    this.totalProfit = 0,
    this.carsSold = 0,
    this.closedBy,
    this.closedAt,
    this.isClosed = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'period_name': periodName,
      'start_date': startDate,
      'end_date': endDate,
      'month_year': monthYear,
      'total_sales': totalSales,
      'total_expenses': totalExpenses,
      'total_profit': totalProfit,
      'cars_sold': carsSold,
      'closed_by': closedBy,
      'closed_at': closedAt,
      'is_closed': isClosed ? 1 : 0,
      'notes': notes,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory MonthlyClose.fromMap(Map<String, dynamic> map) {
    return MonthlyClose(
      id: map['id'],
      periodName: map['period_name'] ?? '',
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'] ?? '',
      monthYear: map['month_year'],
      totalSales: (map['total_sales'] ?? 0).toDouble(),
      totalExpenses: (map['total_expenses'] ?? 0).toDouble(),
      totalProfit: (map['total_profit'] ?? 0).toDouble(),
      carsSold: map['cars_sold'] ?? 0,
      closedBy: map['closed_by'],
      closedAt: map['closed_at'],
      isClosed: (map['is_closed'] ?? 0) == 1,
      notes: map['notes'],
    );
  }

  MonthlyClose copyWith({
    int? id,
    String? periodName,
    String? startDate,
    String? endDate,
    Object? monthYear = _sentinel,
    double? totalSales,
    double? totalExpenses,
    double? totalProfit,
    int? carsSold,
    Object? closedBy = _sentinel,
    Object? closedAt = _sentinel,
    bool? isClosed,
    Object? notes = _sentinel,
  }) {
    return MonthlyClose(
      id: id ?? this.id,
      periodName: periodName ?? this.periodName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      monthYear: monthYear == _sentinel ? this.monthYear : monthYear as String?,
      totalSales: totalSales ?? this.totalSales,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalProfit: totalProfit ?? this.totalProfit,
      carsSold: carsSold ?? this.carsSold,
      closedBy: closedBy == _sentinel ? this.closedBy : closedBy as int?,
      closedAt: closedAt == _sentinel ? this.closedAt : closedAt as String?,
      isClosed: isClosed ?? this.isClosed,
      notes: notes == _sentinel ? this.notes : notes as String?,
    );
  }

  @override
  String toString() =>
      'MonthlyClose(id: $id, periodName: $periodName, isClosed: $isClosed)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlyClose && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

const Object _sentinel = Object();
