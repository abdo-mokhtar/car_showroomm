import '../models/car_image.dart';
import 'base_repository.dart';

class CarImagesRepository extends BaseRepository {
  // ✅ كل صور سيارة معينة
  Future<List<CarImage>> getImagesByCarId(int carId) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'car_images',
        where: 'car_id = ?',
        whereArgs: [carId],
        orderBy: 'created_at ASC',
      );
      return result.map((e) => CarImage.fromMap(e)).toList();
    });
  }

  // ✅ إضافة صورة
  Future<int> insertImage(CarImage image) async {
    return execute(() async {
      final database = await db;
      return await database.insert('car_images', image.toMapForInsert());
    });
  }

  // ✅ إضافة أكتر من صورة دفعة واحدة
  Future<void> insertImages(List<CarImage> images) async {
    return execute(() async {
      final database = await db;
      final batch = database.batch();
      for (final image in images) {
        batch.insert('car_images', image.toMapForInsert());
      }
      await batch.commit(noResult: true);
    });
  }

  // ✅ حذف صورة
  Future<int> deleteImage(int id) async {
    return execute(() async {
      final database = await db;
      return await database.delete(
        'car_images',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ✅ حذف كل صور سيارة
  Future<int> deleteAllImagesByCarId(int carId) async {
    return execute(() async {
      final database = await db;
      return await database.delete(
        'car_images',
        where: 'car_id = ?',
        whereArgs: [carId],
      );
    });
  }

  // ✅ عدد صور سيارة
  Future<int> getImagesCountByCarId(int carId) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM car_images WHERE car_id = ?',
        [carId],
      );
      return result.first['count'] as int;
    });
  }
}
