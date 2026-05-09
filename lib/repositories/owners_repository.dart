import '../models/owner.dart';
import 'base_repository.dart';

class OwnersRepository extends BaseRepository {
  // ✅ كل المالكين
  Future<List<Owner>> getAllOwners() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'owners',
        orderBy: 'name ASC',
      );
      return result.map((e) => Owner.fromMap(e)).toList();
    });
  }

  // ✅ مالك بـ id
  Future<Owner?> getOwnerById(int id) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'owners',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return Owner.fromMap(result.first);
    });
  }

  // ✅ بحث عن مالك
  Future<List<Owner>> searchOwners(String query) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'owners',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return result.map((e) => Owner.fromMap(e)).toList();
    });
  }

  // ✅ إضافة مالك
  Future<int> insertOwner(Owner owner) async {
    return execute(() async {
      final database = await db;
      return await database.insert('owners', owner.toMapForInsert());
    });
  }

  // ✅ تعديل مالك
  Future<int> updateOwner(Owner owner) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'owners',
        owner.toMap(),
        where: 'id = ?',
        whereArgs: [owner.id],
      );
    });
  }

  // ✅ حذف مالك
  Future<int> deleteOwner(int id) async {
    return execute(() async {
      final database = await db;
      return await database.delete(
        'owners',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
