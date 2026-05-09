import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/customer.dart';
import '../../repositories/customers_repository.dart';
import 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository _customersRepository;

  CustomersCubit(this._customersRepository) : super(const CustomersInitial());

  // ✅ تحميل كل العملاء
  Future<void> loadAllCustomers() async {
    emit(const CustomersLoading());
    try {
      final customers = await _customersRepository.getAllCustomers();
      final count = await _customersRepository.getCustomersCount();
      emit(CustomersLoaded(
        customers: customers,
        totalCount: count,
      ));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  // ✅ بحث عن عميل
  Future<void> searchCustomers(String query) async {
    emit(const CustomersLoading());
    try {
      final customers = await _customersRepository.searchCustomers(query);
      emit(CustomersLoaded(
        customers: customers,
        totalCount: customers.length,
      ));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  // ✅ إضافة عميل
  Future<void> insertCustomer(Customer customer) async {
    try {
      await _customersRepository.insertCustomer(customer);
      emit(const CustomersOperationSuccess('تم إضافة العميل بنجاح'));
      await loadAllCustomers();
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  // ✅ تعديل عميل
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customersRepository.updateCustomer(customer);
      emit(const CustomersOperationSuccess('تم تعديل العميل بنجاح'));
      await loadAllCustomers();
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  // ✅ حذف عميل
  Future<void> deleteCustomer(int id) async {
    try {
      await _customersRepository.deleteCustomer(id);
      emit(const CustomersOperationSuccess('تم حذف العميل بنجاح'));
      await loadAllCustomers();
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }
}
