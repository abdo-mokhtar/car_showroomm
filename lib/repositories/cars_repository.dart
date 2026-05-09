import '../models/car.dart';
import 'base_repository.dart';

class CarsRepository extends BaseRepository {
  // ✅ كل السيارات
  Future<List<Car>> getAllCars() async {
    return execute(() async {
      final database = await db;
      final result = await database.query('cars', orderBy: 'created_at DESC');
      return result.map((e) => Car.fromMap(e)).toList();
    });
  }

  // ✅ السيارات المتاحة فقط
  Future<List<Car>> getAvailableCars() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'cars',
        where: 'status = ?',
        whereArgs: ['available'],
        orderBy: 'created_at DESC',
      );
      return result.map((e) => Car.fromMap(e)).toList();
    });
  }

  // ✅ السيارات المباعة
  Future<List<Car>> getSoldCars() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'cars',
        where: 'status = ?',
        whereArgs: ['sold'],
        orderBy: 'created_at DESC',
      );
      return result.map((e) => Car.fromMap(e)).toList();
    });
  }

  // ✅ سيارات شهر معين
  Future<List<Car>> getCarsByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'cars',
        where: 'month_year = ?',
        whereArgs: [monthYear],
        orderBy: 'created_at DESC',
      );
      return result.map((e) => Car.fromMap(e)).toList();
    });
  }

  // ✅ بحث عن سيارة
  Future<List<Car>> searchCars(String query) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'cars',
        where:
            'brand LIKE ? OR model LIKE ? OR plate_number LIKE ? OR chassis_number LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      return result.map((e) => Car.fromMap(e)).toList();
    });
  }

  // ✅ سيارة بـ id
  Future<Car?> getCarById(int id) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'cars',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return Car.fromMap(result.first);
    });
  }

  // ✅ إضافة سيارة
  Future<int> insertCar(Car car) async {
    return execute(() async {
      final database = await db;
      return await database.insert('cars', car.toMapForInsert());
    });
  }

  // ✅ تعديل سيارة
  Future<int> updateCar(Car car) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'cars',
        car.toMap(),
        where: 'id = ?',
        whereArgs: [car.id],
      );
    });
  }

  // ✅ تغيير حالة السيارة لمباعة
  Future<int> markAsSold(int carId) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'cars',
        {'status': 'sold'},
        where: 'id = ?',
        whereArgs: [carId],
      );
    });
  }

  // ✅ حذف سيارة
// ✅ احذف الصور الأول ثم السيارة
  Future<int> deleteCar(int id) async {
    return execute(() async {
      final database = await db;
      // احذف الصور الأول
      await database.delete(
        'car_images',
        where: 'car_id = ?',
        whereArgs: [id],
      );
      // ثم احذف السيارة
      return await database.delete(
        'cars',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ✅ عدد السيارات المتاحة
  Future<int> getAvailableCarsCount() async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM cars WHERE status = ?',
        ['available'],
      );
      return result.first['count'] as int;
    });
  }

// ✅ سيارات مالك معين
  Future<List<Car>> getCarsByOwnerId(int ownerId) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'cars',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
        orderBy: 'created_at DESC',
      );
      return result.map((e) => Car.fromMap(e)).toList();
    });
  }

// ✅ إضافة سيارة وإرجاع الـ id
  Future<int> insertCarAndGetId(Car car) async {
    return execute(() async {
      final database = await db;
      return await database.insert('cars', car.toMapForInsert());
    });
  }

  // ✅ عدد السيارات المباعة في شهر
  Future<int> getSoldCarsCountByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM cars WHERE status = ? AND month_year = ?',
        ['sold', monthYear],
      );
      return result.first['count'] as int;
    });
  }
}
