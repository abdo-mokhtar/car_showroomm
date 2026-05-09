import 'package:equatable/equatable.dart';
import '../../models/sale.dart';
import '../../models/car.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<Sale> lastSales;
  final List<Car> availableCars;
  final int overdueInstallments;
  final List<Map<String, dynamic>> last6MonthsSales;
  final List<Map<String, dynamic>> salesByPaymentType;
  final int availableCarsCount;
  final int soldThisMonth;
  final double totalSalesThisMonth;
  final double totalProfitThisMonth;

  const DashboardLoaded({
    required this.lastSales,
    required this.availableCars,
    required this.overdueInstallments,
    required this.last6MonthsSales,
    required this.salesByPaymentType,
    required this.availableCarsCount,
    required this.soldThisMonth,
    required this.totalSalesThisMonth,
    required this.totalProfitThisMonth,
  });

  @override
  List<Object?> get props => [
        lastSales,
        availableCars,
        overdueInstallments,
        last6MonthsSales,
        salesByPaymentType,
        availableCarsCount,
        soldThisMonth,
        totalSalesThisMonth,
        totalProfitThisMonth,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
