import 'package:equatable/equatable.dart';
import '../../models/installment.dart';

abstract class InstallmentsState extends Equatable {
  const InstallmentsState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class InstallmentsInitial extends InstallmentsState {
  const InstallmentsInitial();
}

// ✅ جاري التحميل
class InstallmentsLoading extends InstallmentsState {
  const InstallmentsLoading();
}

// ✅ تم تحميل الأقساط
class InstallmentsLoaded extends InstallmentsState {
  final List<Installment> installments;
  final double totalPaid;
  final double totalUnpaid;
  final int overdueCount;

  const InstallmentsLoaded({
    required this.installments,
    this.totalPaid = 0,
    this.totalUnpaid = 0,
    this.overdueCount = 0,
  });

  @override
  List<Object?> get props => [
        installments,
        totalPaid,
        totalUnpaid,
        overdueCount,
      ];
}

// ✅ عملية ناجحة
class InstallmentsOperationSuccess extends InstallmentsState {
  final String message;
  const InstallmentsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class InstallmentsError extends InstallmentsState {
  final String message;
  const InstallmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
