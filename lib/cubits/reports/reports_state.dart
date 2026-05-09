import 'package:equatable/equatable.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

// ✅ جاري التحميل
class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

// ✅ تم تحميل التقرير
class ReportsLoaded extends ReportsState {
  final String monthYear;
  final int carsSold;
  final double totalSales;
  final double totalExpenses;
  final double totalProfit;
  final double officeCarsProfit;
  final double consignmentProfit;
  final String? topEmployee;
  final List<Map<String, dynamic>> expensesSummary;

  const ReportsLoaded({
    required this.monthYear,
    this.carsSold = 0,
    this.totalSales = 0,
    this.totalExpenses = 0,
    this.totalProfit = 0,
    this.officeCarsProfit = 0,
    this.consignmentProfit = 0,
    this.topEmployee,
    this.expensesSummary = const [],
  });

  @override
  List<Object?> get props => [
        monthYear,
        carsSold,
        totalSales,
        totalExpenses,
        totalProfit,
        officeCarsProfit,
        consignmentProfit,
        topEmployee,
        expensesSummary,
      ];
}

// ✅ خطأ
class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
