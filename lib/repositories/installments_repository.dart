import '../models/installment.dart';
import 'base_repository.dart';

class InstallmentsRepository extends BaseRepository {
  // ✅ كل أقساط بيع معين
  Future<List<Installment>> getInstallmentsBySaleId(int saleId) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'installments',
        where: 'sale_id = ?',
        whereArgs: [saleId],
        orderBy: 'due_date ASC',
      );
      return result.map((e) => Installment.fromMap(e)).toList();
    });
  }

  // ✅ كل الأقساط الغير مدفوعة
  Future<List<Installment>> getUnpaidInstallments() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'installments',
        where: 'paid = ?',
        whereArgs: [0],
        orderBy: 'due_date ASC',
      );
      return result.map((e) => Installment.fromMap(e)).toList();
    });
  }

  // ✅ الأقساط المتأخرة
  Future<List<Installment>> getOverdueInstallments() async {
    return execute(() async {
      final database = await db;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final result = await database.query(
        'installments',
        where: 'paid = ? AND due_date < ?',
        whereArgs: [0, today],
        orderBy: 'due_date ASC',
      );
      return result.map((e) => Installment.fromMap(e)).toList();
    });
  }

  // ✅ إضافة قسط
  Future<int> insertInstallment(Installment installment) async {
    return execute(() async {
      final database = await db;
      return await database.insert(
        'installments',
        installment.toMapForInsert(),
      );
    });
  }

  // ✅ إضافة أكتر من قسط دفعة واحدة
  Future<void> insertInstallments(List<Installment> installments) async {
    return execute(() async {
      final database = await db;
      final batch = database.batch();
      for (final installment in installments) {
        batch.insert('installments', installment.toMapForInsert());
      }
      await batch.commit(noResult: true);
    });
  }

  // ✅ تسجيل دفع قسط
  Future<int> payInstallment(int id) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'installments',
        {
          'paid': 1,
          'paid_date': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ✅ تعديل قسط
  Future<int> updateInstallment(Installment installment) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'installments',
        installment.toMap(),
        where: 'id = ?',
        whereArgs: [installment.id],
      );
    });
  }

  // ✅ حذف قسط
  Future<int> deleteInstallment(int id) async {
    return execute(() async {
      final database = await db;
      return await database.delete(
        'installments',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

// ✅ عدد الأقساط المتأخرة
  Future<int> getOverdueCount() async {
    return execute(() async {
      final database = await db;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM installments WHERE paid = 0 AND due_date < ?',
        [today],
      );
      return result.first['count'] as int;
    });
  }

  // ✅ إجمالي الأقساط المدفوعة لبيع معين
  Future<double> getTotalPaidBySaleId(int saleId) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT SUM(amount) as total FROM installments WHERE sale_id = ? AND paid = 1',
        [saleId],
      );
      return (result.first['total'] as num? ?? 0).toDouble();
    });
  }
}
