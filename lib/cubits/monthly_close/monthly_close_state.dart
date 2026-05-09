import 'package:equatable/equatable.dart';
import '../../models/monthly_close.dart';

abstract class MonthlyCloseState extends Equatable {
  const MonthlyCloseState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class MonthlyCloseInitial extends MonthlyCloseState {
  const MonthlyCloseInitial();
}

// ✅ جاري التحميل
class MonthlyCloseLoading extends MonthlyCloseState {
  const MonthlyCloseLoading();
}

// ✅ تم تحميل البيانات
class MonthlyCloseLoaded extends MonthlyCloseState {
  final List<MonthlyClose> monthlyCloses;
  final bool isCurrentMonthClosed;

  const MonthlyCloseLoaded({
    required this.monthlyCloses,
    this.isCurrentMonthClosed = false,
  });

  @override
  List<Object?> get props => [monthlyCloses, isCurrentMonthClosed];
}

// ✅ عملية ناجحة
class MonthlyCloseSuccess extends MonthlyCloseState {
  final String message;
  const MonthlyCloseSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class MonthlyCloseError extends MonthlyCloseState {
  final String message;
  const MonthlyCloseError(this.message);

  @override
  List<Object?> get props => [message];
}
