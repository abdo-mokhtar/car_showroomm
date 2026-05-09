import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;
import '../core/database/database_helper.dart';
import '../core/error/database_exception.dart';

abstract class BaseRepository {
  Future<Database> get db async => await DatabaseHelper.instance.database;

  Future<T> execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(e.toString(), error: e);
    }
  }
}
