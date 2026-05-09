import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/expense.dart';
import '../../repositories/expenses_repository.dart';
import 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpensesRepository _expensesRepository;

  ExpensesCubit(this._expensesRepository) : super(const ExpensesInitial());

  // ✅ تحميل كل المصروفات
  // Future<void> loadAllExpenses() async {
  //   emit(const ExpensesLoading());
  //   try {
  //     final expenses = await _expensesRepository.getAllExpenses();
  //     final totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
  //     emit(ExpensesLoaded(
  //       expenses: expenses,
  //       totalAmount: totalAmount,
  //     ));
  //   } catch (e) {
  //     emit(ExpensesError(e.toString()));
  //   }
  // }

  // ✅ تحميل مصروفات شهر معين
  Future<void> loadExpensesByMonth(String monthYear) async {
    emit(const ExpensesLoading());
    try {
      final expenses = await _expensesRepository.getExpensesByMonth(monthYear);
      final totalAmount =
          await _expensesRepository.getTotalExpensesByMonth(monthYear);
      final summary =
          await _expensesRepository.getExpensesSummaryByMonth(monthYear);
      emit(ExpensesLoaded(
        expenses: expenses,
        totalAmount: totalAmount,
        summary: summary,
      ));
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
  }

  // ✅ تحميل مصروفات سيارة معينة
  Future<void> loadExpensesByCar(int carId) async {
    emit(const ExpensesLoading());
    try {
      final expenses = await _expensesRepository.getExpensesByCarId(carId);
      final totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
      emit(ExpensesLoaded(
        expenses: expenses,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
  }

  // ✅ إضافة مصروف
  Future<void> insertExpense(Expense expense) async {
    try {
      await _expensesRepository.insertExpense(expense);
      emit(const ExpensesOperationSuccess('تم إضافة المصروف بنجاح'));
      await loadAllExpenses();
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
  }

  // ✅ تعديل مصروف
  Future<void> updateExpense(Expense expense) async {
    try {
      await _expensesRepository.updateExpense(expense);
      emit(const ExpensesOperationSuccess('تم تعديل المصروف بنجاح'));
      await loadAllExpenses();
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
  }

// ✅ تحميل كل المصروفات
  Future<void> loadAllExpenses() async {
    emit(const ExpensesLoading());
    try {
      final expenses = await _expensesRepository.getAllExpenses();
      final totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
      emit(ExpensesLoaded(expenses: expenses, totalAmount: totalAmount));
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
  }

  // ✅ حذف مصروف
  Future<void> deleteExpense(int id) async {
    try {
      await _expensesRepository.deleteExpense(id);
      emit(const ExpensesOperationSuccess('تم حذف المصروف بنجاح'));
      await loadAllExpenses();
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
  }
}
