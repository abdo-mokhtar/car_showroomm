import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/expenses_repository.dart';
import '../../repositories/cars_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final SalesRepository _salesRepository;
  final ExpensesRepository _expensesRepository;
  final CarsRepository _carsRepository;

  ReportsCubit(
    this._salesRepository,
    this._expensesRepository,
    this._carsRepository,
  ) : super(const ReportsInitial());

  // ✅ تحميل تقرير شهر معين
  Future<void> loadReport(
    String monthYear, {
    String? paymentType,
    String? employeeName,
    String? ownershipType,
  }) async {
    emit(const ReportsLoading());
    try {
      final allSales = await _salesRepository.getSalesByMonth(monthYear);

      // ✅ تطبيق الفلاتر
      var filteredSales = allSales;

      if (paymentType != null && paymentType != 'all') {
        filteredSales =
            filteredSales.where((s) => s.paymentType == paymentType).toList();
      }

      if (employeeName != null && employeeName != 'all') {
        filteredSales =
            filteredSales.where((s) => s.employeeName == employeeName).toList();
      }

      // ✅ حساب الأرقام بناءً على الفلاتر
      double totalSales = 0;
      double totalProfit = 0;
      double officeCarsProfit = 0;
      double consignmentProfit = 0;
      int carsSold = filteredSales.length;

      for (final sale in filteredSales) {
        final car = await _carsRepository.getCarById(sale.carId);
        if (car == null) continue;

        // ✅ فلتر نوع الملكية
        if (ownershipType != null && ownershipType != 'all') {
          if (car.ownershipType != ownershipType) continue;
        }

        totalSales += sale.salePrice;
        totalProfit += sale.profit;

        if (car.ownershipType == 'office') {
          officeCarsProfit += sale.profit;
        } else {
          consignmentProfit += sale.profit;
        }
      }

      final totalExpenses =
          await _expensesRepository.getTotalExpensesByMonth(monthYear);
      final expensesSummary =
          await _expensesRepository.getExpensesSummaryByMonth(monthYear);

      // ✅ أفضل موظف من الفلاتر
      String? topEmployee;
      if (filteredSales.isNotEmpty) {
        final employeeCount = <String, int>{};
        for (final sale in filteredSales) {
          if (sale.employeeName != null) {
            employeeCount[sale.employeeName!] =
                (employeeCount[sale.employeeName!] ?? 0) + 1;
          }
        }
        if (employeeCount.isNotEmpty) {
          topEmployee = employeeCount.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
        }
      }

      emit(ReportsLoaded(
        monthYear: monthYear,
        carsSold: carsSold,
        totalSales: totalSales,
        totalExpenses: totalExpenses,
        totalProfit: totalProfit,
        officeCarsProfit: officeCarsProfit,
        consignmentProfit: consignmentProfit,
        topEmployee: topEmployee,
        expensesSummary: expensesSummary,
      ));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }
}
