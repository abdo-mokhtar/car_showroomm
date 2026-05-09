import '../models/monthly_close.dart';
import 'base_repository.dart';

class MonthlyCloseRepository extends BaseRepository {
  // ✅ كل الفترات
  Future<List<MonthlyClose>> getAllMonthlyCloses() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'monthly_close',
        orderBy: 'start_date DESC',
      );
      return result.map((e) => MonthlyClose.fromMap(e)).toList();
    });
  }

  // ✅ إضافة فترة جديدة
  Future<int> insertOrUpdateMonthlyClose(MonthlyClose monthlyClose) async {
    return execute(() async {
      final database = await db;
      return await database.insert(
        'monthly_close',
        monthlyClose.toMapForInsert(),
      );
    });
  }

  // ✅ آخر فترة مغلقة
  Future<MonthlyClose?> getLastClosedMonth() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'monthly_close',
        where: 'is_closed = 1',
        orderBy: 'start_date DESC',
        limit: 1,
      );
      if (result.isEmpty) return null;
      return MonthlyClose.fromMap(result.first);
    });
  }
}
