import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/sale.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/cars_repository.dart';
import 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository _salesRepository;
  final CarsRepository _carsRepository;

  SalesCubit(
    this._salesRepository,
    this._carsRepository,
  ) : super(const SalesInitial());

  // ✅ تحميل كل المبيعات
  Future<void> loadAllSales() async {
    emit(const SalesLoading());
    try {
      final sales = await _salesRepository.getAllSales();
      final totalSales = sales.fold(0.0, (sum, s) => sum + s.salePrice);
      final totalProfit = sales.fold(0.0, (sum, s) => sum + s.profit);
      emit(SalesLoaded(
        sales: sales,
        totalSales: totalSales,
        totalProfit: totalProfit,
        totalCount: sales.length,
      ));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  // ✅ تحميل مبيعات شهر معين
  Future<void> loadSalesByMonth(String monthYear) async {
    emit(const SalesLoading());
    try {
      final sales = await _salesRepository.getSalesByMonth(monthYear);
      final totalSales = await _salesRepository.getTotalSalesByMonth(monthYear);
      final totalProfit =
          await _salesRepository.getTotalProfitByMonth(monthYear);
      emit(SalesLoaded(
        sales: sales,
        totalSales: totalSales,
        totalProfit: totalProfit,
        totalCount: sales.length,
      ));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  // ✅ تسجيل بيع جديد
  Future<void> insertSale(Sale sale) async {
    try {
      await _salesRepository.insertSale(sale);
      await _carsRepository.markAsSold(sale.carId);
      emit(const SalesOperationSuccess('تم تسجيل البيع بنجاح'));
      await loadAllSales();
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  // ✅ تعديل بيع
  Future<void> updateSale(Sale sale) async {
    try {
      await _salesRepository.updateSale(sale);
      emit(const SalesOperationSuccess('تم تعديل البيع بنجاح'));
      await loadAllSales();
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  // ✅ حذف بيع
  Future<void> deleteSale(int id, int carId) async {
    try {
      await _salesRepository.deleteSale(id);
      // ✅ رجّع حالة السيارة لمتاحة
      await _carsRepository.updateCar(
        (await _carsRepository.getCarById(carId))!
            .copyWith(status: 'available'),
      );
      emit(const SalesOperationSuccess('تم حذف البيع بنجاح'));
      await loadAllSales();
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  // ✅ مبيعات عميل معين
  Future<void> loadSalesByCustomer(int customerId) async {
    emit(const SalesLoading());
    try {
      final sales = await _salesRepository.getSalesByCustomer(customerId);
      final totalSales = sales.fold(0.0, (sum, s) => sum + s.salePrice);
      final totalProfit = sales.fold(0.0, (sum, s) => sum + s.profit);
      emit(SalesLoaded(
        sales: sales,
        totalSales: totalSales,
        totalProfit: totalProfit,
        totalCount: sales.length,
      ));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
}
