import 'package:equatable/equatable.dart';
import '../../models/customer.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

// ✅ جاري التحميل
class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

// ✅ تم تحميل العملاء
class CustomersLoaded extends CustomersState {
  final List<Customer> customers;
  final int totalCount;

  const CustomersLoaded({
    required this.customers,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [customers, totalCount];
}

// ✅ عملية ناجحة
class CustomersOperationSuccess extends CustomersState {
  final String message;
  const CustomersOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class CustomersError extends CustomersState {
  final String message;
  const CustomersError(this.message);

  @override
  List<Object?> get props => [message];
}
