import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/installment.dart';
import '../../repositories/installments_repository.dart';
import 'installments_state.dart';

class InstallmentsCubit extends Cubit<InstallmentsState> {
  final InstallmentsRepository _installmentsRepository;

  InstallmentsCubit(this._installmentsRepository)
      : super(const InstallmentsInitial());

  // ✅ تحميل أقساط بيع معين
  Future<void> loadInstallmentsBySaleId(int saleId) async {
    emit(const InstallmentsLoading());
    try {
      final installments =
          await _installmentsRepository.getInstallmentsBySaleId(saleId);
      final totalPaid = installments
          .where((i) => i.paid)
          .fold(0.0, (sum, i) => sum + i.amount);
      final totalUnpaid = installments
          .where((i) => !i.paid)
          .fold(0.0, (sum, i) => sum + i.amount);
      final overdueCount = installments.where((i) => i.isOverdue).length;
      emit(InstallmentsLoaded(
        installments: installments,
        totalPaid: totalPaid,
        totalUnpaid: totalUnpaid,
        overdueCount: overdueCount,
      ));
    } catch (e) {
      emit(InstallmentsError(e.toString()));
    }
  }

  // ✅ تحميل كل الأقساط الغير مدفوعة
  Future<void> loadUnpaidInstallments() async {
    emit(const InstallmentsLoading());
    try {
      final installments =
          await _installmentsRepository.getUnpaidInstallments();
      final totalUnpaid = installments.fold(0.0, (sum, i) => sum + i.amount);
      final overdueCount = installments.where((i) => i.isOverdue).length;
      emit(InstallmentsLoaded(
        installments: installments,
        totalPaid: 0,
        totalUnpaid: totalUnpaid,
        overdueCount: overdueCount,
      ));
    } catch (e) {
      emit(InstallmentsError(e.toString()));
    }
  }

  // ✅ تحميل الأقساط المتأخرة
  Future<void> loadOverdueInstallments() async {
    emit(const InstallmentsLoading());
    try {
      final installments =
          await _installmentsRepository.getOverdueInstallments();
      final totalUnpaid = installments.fold(0.0, (sum, i) => sum + i.amount);
      emit(InstallmentsLoaded(
        installments: installments,
        totalPaid: 0,
        totalUnpaid: totalUnpaid,
        overdueCount: installments.length,
      ));
    } catch (e) {
      emit(InstallmentsError(e.toString()));
    }
  }

  // ✅ إضافة قسط
  Future<void> insertInstallment(Installment installment) async {
    try {
      await _installmentsRepository.insertInstallment(installment);
      emit(const InstallmentsOperationSuccess('تم إضافة القسط بنجاح'));
      await loadInstallmentsBySaleId(installment.saleId);
    } catch (e) {
      emit(InstallmentsError(e.toString()));
    }
  }

  // ✅ إضافة أكتر من قسط
  Future<void> insertInstallments(List<Installment> installments) async {
    try {
      await _installmentsRepository.insertInstallments(installments);
      emit(const InstallmentsOperationSuccess('تم إضافة الأقساط بنجاح'));
      if (installments.isNotEmpty) {
        await loadInstallmentsBySaleId(installments.first.saleId);
      }
    } catch (e) {
      emit(InstallmentsError(e.toString()));
    }
  }

  // ✅ تسجيل دفع قسط
  Future<void> payInstallment(int id, int saleId) async {
    try {
      await _installmentsRepository.payInstallment(id);
      emit(const InstallmentsOperationSuccess('تم تسجيل الدفع بنجاح'));
      await loadInstallmentsBySaleId(saleId);
    } catch (e) {
      emit(InstallmentsError(e.toString()));
    }
  }

  // ✅ حذف قسط
  Future<void> deleteInstallment(int id, int saleId) async {
    try {
      await _installmentsRepository.deleteInstallment(id);
      emit(const InstallmentsOperationSuccess('تم حذف القسط بنجاح'));
      await loadInstallmentsBySaleId(saleId);
    } catch (e) {
      emit(InstallmentsError(e.toString()));
    }
  }
}
