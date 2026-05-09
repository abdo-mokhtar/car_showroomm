import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/car.dart';
import '../../models/car_image.dart';
import '../../repositories/cars_repository.dart';
import '../../repositories/expenses_repository.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/car_images_repository.dart';
import 'cars_state.dart';

class CarsCubit extends Cubit<CarsState> {
  final CarsRepository _carsRepository;
  final ExpensesRepository _expensesRepository;
  final SalesRepository _salesRepository;
  final CarImagesRepository _carImagesRepository;

  CarsCubit(
    this._carsRepository,
    this._expensesRepository,
    this._salesRepository,
    this._carImagesRepository,
  ) : super(const CarsInitial());

  // ✅ تحميل كل السيارات
  Future<void> loadAllCars() async {
    emit(const CarsLoading());
    try {
      final cars = await _carsRepository.getAllCars();
      final availableCount = await _carsRepository.getAvailableCarsCount();
      emit(CarsLoaded(
        cars: cars,
        availableCount: availableCount,
        soldCount: cars.where((c) => c.status == 'sold').length,
      ));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ تحميل السيارات المتاحة فقط
  Future<void> loadAvailableCars() async {
    emit(const CarsLoading());
    try {
      final cars = await _carsRepository.getAvailableCars();
      emit(CarsLoaded(
        cars: cars,
        availableCount: cars.length,
        soldCount: 0,
      ));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

// ✅ إضافة سيارة وإرجاع الـ id
  Future<int> insertCarAndGetId(Car car) async {
    try {
      final id = await _carsRepository.insertCarAndGetId(car);
      emit(const CarsOperationSuccess('تم إضافة السيارة بنجاح'));
      await loadAllCars();
      return id;
    } catch (e) {
      emit(CarsError(e.toString()));
      return 0;
    }
  }

  // ✅ تحميل السيارات المباعة
  Future<void> loadSoldCars() async {
    emit(const CarsLoading());
    try {
      final cars = await _carsRepository.getSoldCars();
      emit(CarsLoaded(
        cars: cars,
        availableCount: 0,
        soldCount: cars.length,
      ));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

// ✅ حذف صور سيارة
  Future<void> deleteCarImages(int carId) async {
    try {
      await _carImagesRepository.deleteAllImagesByCarId(carId);
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ بحث
  Future<void> searchCars(String query) async {
    emit(const CarsLoading());
    try {
      final cars = await _carsRepository.searchCars(query);
      emit(CarsLoaded(
        cars: cars,
        availableCount: cars.where((c) => c.status == 'available').length,
        soldCount: cars.where((c) => c.status == 'sold').length,
      ));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ فلترة بالشهر
  Future<void> loadCarsByMonth(String monthYear) async {
    emit(const CarsLoading());
    try {
      final cars = await _carsRepository.getCarsByMonth(monthYear);
      emit(CarsLoaded(
        cars: cars,
        availableCount: cars.where((c) => c.status == 'available').length,
        soldCount: cars.where((c) => c.status == 'sold').length,
      ));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ إضافة سيارة
  Future<void> insertCar(Car car) async {
    try {
      await _carsRepository.insertCar(car);
      emit(const CarsOperationSuccess('تم إضافة السيارة بنجاح'));
      await loadAllCars();
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ تعديل سيارة
  Future<void> updateCar(Car car) async {
    try {
      await _carsRepository.updateCar(car);
      emit(const CarsOperationSuccess('تم تعديل السيارة بنجاح'));
      await loadAllCars();
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ حذف سيارة
  Future<void> deleteCar(int id) async {
    try {
      await _carsRepository.deleteCar(id);
      emit(const CarsOperationSuccess('تم حذف السيارة بنجاح'));
      await loadAllCars();
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ تغيير حالة السيارة لمباعة
  Future<void> markAsSold(int carId) async {
    try {
      await _carsRepository.markAsSold(carId);
      emit(const CarsOperationSuccess('تم تسجيل البيع بنجاح'));
      await loadAllCars();
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ حساب ربح سيارة
  Future<double> calculateCarProfit(Car car) async {
    try {
      final totalExpenses =
          await _expensesRepository.getTotalExpensesByCarId(car.id!);
      return car.calculateProfit(totalExpenses);
    } catch (e) {
      return 0;
    }
  }

  // ✅ حفظ صور السيارة
  Future<void> saveCarImages(int carId, List<String> imagePaths) async {
    try {
      for (final path in imagePaths) {
        final image = CarImage(
          carId: carId,
          imagePath: path,
        );
        await _carImagesRepository.insertImage(image);
      }
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  // ✅ تحميل صور سيارة
  Future<List<CarImage>> loadCarImages(int carId) async {
    try {
      return await _carImagesRepository.getImagesByCarId(carId);
    } catch (e) {
      return [];
    }
  }
}
