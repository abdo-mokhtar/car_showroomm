import '../models/company_settings.dart';
import 'base_repository.dart';

class SettingsRepository extends BaseRepository {
  // ✅ جيب الإعدادات
  Future<CompanySettings?> getSettings() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'company_settings',
        limit: 1,
      );
      if (result.isEmpty) return null;
      return CompanySettings.fromMap(result.first);
    });
  }

  // ✅ تحديث الإعدادات
  Future<int> updateSettings(CompanySettings settings) async {
    return execute(() async {
      final database = await db;
      final existing = await getSettings();
      if (existing == null) {
        return await database.insert(
          'company_settings',
          settings.toMapForInsert(),
        );
      } else {
        return await database.update(
          'company_settings',
          settings.toMap(),
          where: 'id = ?',
          whereArgs: [existing.id],
        );
      }
    });
  }

  // ✅ تحديث اللغة فقط
  Future<int> updateLanguage(String language) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'company_settings',
        {'language': language},
      );
    });
  }

  // ✅ تحديث العملة فقط
  Future<int> updateCurrency(String currency) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'company_settings',
        {'currency': currency},
      );
    });
  }

  // ✅ تحديث اللوجو
  Future<int> updateLogo(String logoPath) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'company_settings',
        {'logo_path': logoPath},
      );
    });
  }
}
