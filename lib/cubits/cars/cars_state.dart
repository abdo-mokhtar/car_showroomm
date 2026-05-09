import 'package:equatable/equatable.dart';
import '../../models/car.dart';

abstract class CarsState extends Equatable {
  const CarsState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class CarsInitial extends CarsState {
  const CarsInitial();
}

// ✅ جاري التحميل
class CarsLoading extends CarsState {
  const CarsLoading();
}

// ✅ تم تحميل السيارات
class CarsLoaded extends CarsState {
  final List<Car> cars;
  final int availableCount;
  final int soldCount;

  const CarsLoaded({
    required this.cars,
    this.availableCount = 0,
    this.soldCount = 0,
  });

  @override
  List<Object?> get props => [cars, availableCount, soldCount];
}

// ✅ عملية ناجحة (إضافة / تعديل / حذف)
class CarsOperationSuccess extends CarsState {
  final String message;
  const CarsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class CarsError extends CarsState {
  final String message;
  const CarsError(this.message);

  @override
  List<Object?> get props => [message];
}
