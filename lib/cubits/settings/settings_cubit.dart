import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/company_settings.dart';
import '../../repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(const SettingsInitial());

  // ✅ تحميل الإعدادات
  Future<void> loadSettings() async {
    emit(const SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      if (settings == null) {
        emit(const SettingsError('لم يتم العثور على الإعدادات'));
        return;
      }
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ✅ تحديث الإعدادات
  Future<void> updateSettings(CompanySettings settings) async {
    try {
      await _settingsRepository.updateSettings(settings);
      emit(const SettingsOperationSuccess('تم تحديث الإعدادات بنجاح'));
      await loadSettings();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ✅ تغيير اللغة
  Future<void> updateLanguage(String language) async {
    try {
      await _settingsRepository.updateLanguage(language);
      emit(const SettingsOperationSuccess('تم تغيير اللغة بنجاح'));
      await loadSettings();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ✅ تغيير العملة
  Future<void> updateCurrency(String currency) async {
    try {
      await _settingsRepository.updateCurrency(currency);
      emit(const SettingsOperationSuccess('تم تغيير العملة بنجاح'));
      await loadSettings();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ✅ تحديث اللوجو
  Future<void> updateLogo(String logoPath) async {
    try {
      await _settingsRepository.updateLogo(logoPath);
      emit(const SettingsOperationSuccess('تم تحديث الشعار بنجاح'));
      await loadSettings();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
