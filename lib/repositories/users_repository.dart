import 'package:car_showroom/models/user.dart';
import 'base_repository.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UsersRepository extends BaseRepository {
  // ✅ تشفير الباسورد
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ✅ تسجيل الدخول
  Future<User?> login(String username, String password) async {
    return execute(() async {
      final database = await db;
      final hashedPassword = _hashPassword(password);
      final result = await database.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, hashedPassword],
      );
      if (result.isEmpty) return null;
      return User.fromMap(result.first);
    });
  }

  // ✅ كل المستخدمين
  Future<List<User>> getAllUsers() async {
    return execute(() async {
      final database = await db;
      final result = await database.query('users', orderBy: 'id ASC');
      return result.map((e) => User.fromMap(e)).toList();
    });
  }

  // ✅ إضافة مستخدم
  Future<int> insertUser(User user) async {
    return execute(() async {
      final database = await db;
      final map = user.toMapForInsert();
      map['password'] = _hashPassword(user.password);
      return await database.insert('users', map);
    });
  }

  // ✅ تعديل مستخدم
  Future<int> updateUser(User user) async {
    return execute(() async {
      final database = await db;
      final map = user.toMap();
      map['password'] = _hashPassword(user.password);
      return await database.update(
        'users',
        map,
        where: 'id = ?',
        whereArgs: [user.id],
      );
    });
  }

// ✅ تعديل من غير تغيير الباسورد
  Future<int> updateUserWithoutPassword(User user) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'users',
        {
          'username': user.username,
          'role': user.role,
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
    });
  }

  // ✅ حذف مستخدم
  Future<int> deleteUser(int id) async {
    return execute(() async {
      final database = await db;
      return await database.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ✅ التحقق من وجود username
  Future<bool> usernameExists(String username) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty;
    });
  }
}
// ✅ تعديل من غير تغيير الباسورد
