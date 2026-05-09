import 'package:equatable/equatable.dart';
import '../../models/sale.dart';

abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class SalesInitial extends SalesState {
  const SalesInitial();
}

// ✅ جاري التحميل
class SalesLoading extends SalesState {
  const SalesLoading();
}

// ✅ تم تحميل المبيعات
class SalesLoaded extends SalesState {
  final List<Sale> sales;
  final double totalSales;
  final double totalProfit;
  final int totalCount;

  const SalesLoaded({
    required this.sales,
    this.totalSales = 0,
    this.totalProfit = 0,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [sales, totalSales, totalProfit, totalCount];
}

// ✅ عملية ناجحة
class SalesOperationSuccess extends SalesState {
  final String message;
  const SalesOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class SalesError extends SalesState {
  final String message;
  const SalesError(this.message);

  @override
  List<Object?> get props => [message];
}
