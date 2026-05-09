import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/sale.dart';
import '../../models/car.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/cars_repository.dart';
import '../../repositories/installments_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SalesRepository _salesRepository;
  final CarsRepository _carsRepository;
  final InstallmentsRepository _installmentsRepository;

  DashboardCubit(
    this._salesRepository,
    this._carsRepository,
    this._installmentsRepository,
  ) : super(const DashboardInitial());

  Future<void> loadDashboard() async {
    emit(const DashboardLoading());
    try {
      final now = DateTime.now();
      final allSales = await _salesRepository.getLastSales(limit: 1);
      final monthYear = allSales.isNotEmpty
          ? allSales.first.monthYear ??
              '${now.year}-${now.month.toString().padLeft(2, '0')}'
          : '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final results = await Future.wait([
        _salesRepository.getLastSales(limit: 5),
        _carsRepository.getAvailableCars(),
        _installmentsRepository.getOverdueCount(),
        _salesRepository.getSalesLast6Months(),
        _salesRepository.getSalesByPaymentType(),
        _carsRepository.getAvailableCarsCount(),
        _salesRepository.getSalesCountByMonth(monthYear),
        _salesRepository.getTotalSalesByMonth(monthYear),
        _salesRepository.getTotalProfitByMonth(monthYear),
      ]);

      emit(DashboardLoaded(
        lastSales: (results[0] as List).cast<Sale>(),
        availableCars: (results[1] as List).cast<Car>(),
        overdueInstallments: results[2] as int,
        last6MonthsSales: (results[3] as List).cast<Map<String, dynamic>>(),
        salesByPaymentType: (results[4] as List).cast<Map<String, dynamic>>(),
        availableCarsCount: results[5] as int,
        soldThisMonth: results[6] as int,
        totalSalesThisMonth: results[7] as double,
        totalProfitThisMonth: results[8] as double,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
