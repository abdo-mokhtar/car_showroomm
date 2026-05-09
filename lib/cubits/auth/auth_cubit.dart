import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../repositories/users_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final UsersRepository _usersRepository;
  User? currentUser;

  AuthCubit(this._usersRepository) : super(const AuthInitial());

  // ✅ تسجيل الدخول
  Future<void> login(String username, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _usersRepository.login(username, password);
      if (user == null) {
        emit(const AuthFailure('اسم المستخدم أو كلمة المرور غلط'));
        return;
      }
      currentUser = user;
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // ✅ تسجيل الخروج
  void logout() {
    currentUser = null;
    emit(const AuthLoggedOut());
  }

  // ✅ التحقق من الصلاحيات
  bool get isAdmin => currentUser?.isAdmin ?? false;
  bool get isEmployee => currentUser?.isEmployee ?? false;
  int? get currentUserId => currentUser?.id;
  String? get currentUsername => currentUser?.username;
}
