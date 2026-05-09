import '../models/audit_log.dart';
import 'base_repository.dart';

class AuditLogRepository extends BaseRepository {
  // ✅ كل السجلات
  Future<List<AuditLog>> getAllLogs() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'audit_logs',
        orderBy: 'timestamp DESC',
      );
      return result.map((e) => AuditLog.fromMap(e)).toList();
    });
  }

  // ✅ سجلات مستخدم معين
  Future<List<AuditLog>> getLogsByUser(int userId) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'audit_logs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
      );
      return result.map((e) => AuditLog.fromMap(e)).toList();
    });
  }

  // ✅ سجلات جدول معين
  Future<List<AuditLog>> getLogsByTable(String tableName) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'audit_logs',
        where: 'table_name = ?',
        whereArgs: [tableName],
        orderBy: 'timestamp DESC',
      );
      return result.map((e) => AuditLog.fromMap(e)).toList();
    });
  }

  // ✅ سجلات اليوم
  Future<List<AuditLog>> getTodayLogs() async {
    return execute(() async {
      final database = await db;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final result = await database.query(
        'audit_logs',
        where: 'timestamp LIKE ?',
        whereArgs: ['$today%'],
        orderBy: 'timestamp DESC',
      );
      return result.map((e) => AuditLog.fromMap(e)).toList();
    });
  }

  // ✅ إضافة سجل
  Future<int> insertLog(AuditLog log) async {
    return execute(() async {
      final database = await db;
      return await database.insert('audit_logs', log.toMapForInsert());
    });
  }

  // ✅ إضافة سجل بشكل مبسط
  Future<int> log({
    required int? userId,
    required String action,
    required String tableName,
    int? recordId,
    String? oldValue,
    String? newValue,
  }) async {
    return insertLog(AuditLog(
      userId: userId,
      action: action,
      tableName: tableName,
      recordId: recordId,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: DateTime.now().toIso8601String(),
    ));
  }

  // ✅ حذف سجلات قديمة (أكبر من 90 يوم)
  Future<int> deleteOldLogs() async {
    return execute(() async {
      final database = await db;
      final cutoff =
          DateTime.now().subtract(const Duration(days: 90)).toIso8601String();
      return await database.delete(
        'audit_logs',
        where: 'timestamp < ?',
        whereArgs: [cutoff],
      );
    });
  }
}
