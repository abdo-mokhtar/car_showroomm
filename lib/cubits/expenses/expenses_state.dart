import 'package:equatable/equatable.dart';
import '../../models/expense.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class ExpensesInitial extends ExpensesState {
  const ExpensesInitial();
}

// ✅ جاري التحميل
class ExpensesLoading extends ExpensesState {
  const ExpensesLoading();
}

// ✅ تم تحميل المصروفات
class ExpensesLoaded extends ExpensesState {
  final List<Expense> expenses;
  final double totalAmount;
  final List<Map<String, dynamic>> summary;

  const ExpensesLoaded({
    required this.expenses,
    this.totalAmount = 0,
    this.summary = const [],
  });

  @override
  List<Object?> get props => [expenses, totalAmount, summary];
}

// ✅ عملية ناجحة
class ExpensesOperationSuccess extends ExpensesState {
  final String message;
  const ExpensesOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class ExpensesError extends ExpensesState {
  final String message;
  const ExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}
