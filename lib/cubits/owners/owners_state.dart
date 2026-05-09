import 'package:equatable/equatable.dart';
import '../../models/owner.dart';

abstract class OwnersState extends Equatable {
  const OwnersState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class OwnersInitial extends OwnersState {
  const OwnersInitial();
}

// ✅ جاري التحميل
class OwnersLoading extends OwnersState {
  const OwnersLoading();
}

// ✅ تم تحميل المالكين
class OwnersLoaded extends OwnersState {
  final List<Owner> owners;

  const OwnersLoaded({required this.owners});

  @override
  List<Object?> get props => [owners];
}

// ✅ عملية ناجحة
class OwnersOperationSuccess extends OwnersState {
  final String message;
  const OwnersOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class OwnersError extends OwnersState {
  final String message;
  const OwnersError(this.message);

  @override
  List<Object?> get props => [message];
}
