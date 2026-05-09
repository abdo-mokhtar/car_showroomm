import '../models/customer.dart';
import 'base_repository.dart';

class CustomersRepository extends BaseRepository {
  // ✅ كل العملاء
  Future<List<Customer>> getAllCustomers() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'customers',
        orderBy: 'name ASC',
      );
      return result.map((e) => Customer.fromMap(e)).toList();
    });
  }

  // ✅ عميل بـ id
  Future<Customer?> getCustomerById(int id) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'customers',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return Customer.fromMap(result.first);
    });
  }

  // ✅ بحث عن عميل
  Future<List<Customer>> searchCustomers(String query) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'customers',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return result.map((e) => Customer.fromMap(e)).toList();
    });
  }

  // ✅ إضافة عميل
  Future<int> insertCustomer(Customer customer) async {
    return execute(() async {
      final database = await db;
      return await database.insert('customers', customer.toMapForInsert());
    });
  }

  // ✅ تعديل عميل
  Future<int> updateCustomer(Customer customer) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'customers',
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    });
  }

  // ✅ حذف عميل
  Future<int> deleteCustomer(int id) async {
    return execute(() async {
      final database = await db;
      return await database.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ✅ عدد العملاء
  Future<int> getCustomersCount() async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM customers',
      );
      return result.first['count'] as int;
    });
  }
}
