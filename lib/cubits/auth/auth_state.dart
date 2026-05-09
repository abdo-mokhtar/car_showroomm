import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class AuthInitial extends AuthState {
  const AuthInitial();
}

// ✅ جاري تسجيل الدخول
class AuthLoading extends AuthState {
  const AuthLoading();
}

// ✅ تسجيل الدخول نجح
class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// ✅ تسجيل الدخول فشل
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ تسجيل الخروج
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
