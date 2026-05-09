import 'package:equatable/equatable.dart';
import '../../models/company_settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الابتدائية
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

// ✅ جاري التحميل
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

// ✅ تم تحميل الإعدادات
class SettingsLoaded extends SettingsState {
  final CompanySettings settings;

  const SettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

// ✅ عملية ناجحة
class SettingsOperationSuccess extends SettingsState {
  final String message;
  const SettingsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ خطأ
class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
