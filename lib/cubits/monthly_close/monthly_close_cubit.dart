import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/monthly_close.dart';
import '../../repositories/monthly_close_repository.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/expenses_repository.dart';
import 'monthly_close_state.dart';

class MonthlyCloseCubit extends Cubit<MonthlyCloseState> {
  final MonthlyCloseRepository _monthlyCloseRepository;
  final SalesRepository _salesRepository;
  final ExpensesRepository _expensesRepository;

  MonthlyCloseCubit(
    this._monthlyCloseRepository,
    this._salesRepository,
    this._expensesRepository,
  ) : super(const MonthlyCloseInitial());

  // ✅ تحميل كل الفترات
  Future<void> loadAllMonthlyCloses() async {
    emit(const MonthlyCloseLoading());
    try {
      final monthlyCloses = await _monthlyCloseRepository.getAllMonthlyCloses();
      emit(MonthlyCloseLoaded(
        monthlyCloses: monthlyCloses,
        isCurrentMonthClosed: false,
      ));
    } catch (e) {
      emit(MonthlyCloseError(e.toString()));
    }
  }

  // ✅ إغلاق فترة
  Future<void> closeMonth({
    required int closedBy,
    required String periodName,
    required String startDate,
    required String endDate,
  }) async {
    emit(const MonthlyCloseLoading());
    try {
      // حساب الأرقام بناءً على الفترة
      final sales =
          await _salesRepository.getSalesByDateRange(startDate, endDate);
      final totalSales = sales.fold(0.0, (sum, s) => sum + s.salePrice);
      final totalProfit = sales.fold(0.0, (sum, s) => sum + s.profit);
      final totalExpenses = await _expensesRepository
          .getTotalExpensesByDateRange(startDate, endDate);

      final monthlyClose = MonthlyClose(
        periodName: periodName,
        startDate: startDate,
        endDate: endDate,
        totalSales: totalSales,
        totalExpenses: totalExpenses,
        totalProfit: totalProfit,
        carsSold: sales.length,
        closedBy: closedBy,
        closedAt: DateTime.now().toIso8601String(),
        isClosed: true,
      );

      await _monthlyCloseRepository.insertOrUpdateMonthlyClose(monthlyClose);
      emit(const MonthlyCloseSuccess('تم إغلاق الفترة بنجاح'));
      await loadAllMonthlyCloses();
    } catch (e) {
      emit(MonthlyCloseError(e.toString()));
    }
  }
}
