import '../models/sale.dart';
import 'base_repository.dart';

class SalesRepository extends BaseRepository {
  // ✅ كل المبيعات
  Future<List<Sale>> getAllSales() async {
    return execute(() async {
      final database = await db;
      final result = await database.query('sales', orderBy: 'sale_date DESC');
      return result.map((e) => Sale.fromMap(e)).toList();
    });
  }

  // ✅ مبيعات شهر معين
  Future<List<Sale>> getSalesByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        '''SELECT * FROM sales 
           WHERE month_year = ? 
           OR strftime('%Y-%m', sale_date) = ?
           ORDER BY sale_date DESC''',
        [monthYear, monthYear],
      );
      return result.map((e) => Sale.fromMap(e)).toList();
    });
  }

  // ✅ مبيعات عميل معين
  Future<List<Sale>> getSalesByCustomer(int customerId) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'sales',
        where: 'customer_id = ?',
        whereArgs: [customerId],
        orderBy: 'sale_date DESC',
      );
      return result.map((e) => Sale.fromMap(e)).toList();
    });
  }

  // ✅ بيع سيارة معينة
  Future<Sale?> getSaleByCar(int carId) async {
    return execute(() async {
      final database = await db;
      final result = await database
          .query('sales', where: 'car_id = ?', whereArgs: [carId]);
      if (result.isEmpty) return null;
      return Sale.fromMap(result.first);
    });
  }

  // ✅ إضافة بيع
  Future<int> insertSale(Sale sale) async {
    return execute(() async {
      final database = await db;
      return await database.insert('sales', sale.toMapForInsert());
    });
  }

  // ✅ تعديل بيع
  Future<int> updateSale(Sale sale) async {
    return execute(() async {
      final database = await db;
      return await database
          .update('sales', sale.toMap(), where: 'id = ?', whereArgs: [sale.id]);
    });
  }

  // ✅ حذف بيع
  Future<int> deleteSale(int id) async {
    return execute(() async {
      final database = await db;
      return await database.delete('sales', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ✅ إجمالي المبيعات في شهر
  Future<double> getTotalSalesByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        '''SELECT SUM(sale_price) as total FROM sales 
           WHERE month_year = ? 
           OR strftime('%Y-%m', sale_date) = ?''',
        [monthYear, monthYear],
      );
      return (result.first['total'] as num? ?? 0).toDouble();
    });
  }

  // ✅ إجمالي الأرباح في شهر
  Future<double> getTotalProfitByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        '''SELECT SUM(profit) as total FROM sales 
           WHERE month_year = ? 
           OR strftime('%Y-%m', sale_date) = ?''',
        [monthYear, monthYear],
      );
      return (result.first['total'] as num? ?? 0).toDouble();
    });
  }

  // ✅ أفضل موظف مبيعات في شهر
  Future<String?> getTopEmployeeByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        '''SELECT employee_name, COUNT(*) as count 
           FROM sales 
           WHERE (month_year = ? OR strftime('%Y-%m', sale_date) = ?)
           AND employee_name IS NOT NULL
           GROUP BY employee_name 
           ORDER BY count DESC 
           LIMIT 1''',
        [monthYear, monthYear],
      );
      if (result.isEmpty) return null;
      return result.first['employee_name'] as String?;
    });
  }

  // ✅ مبيعات في فترة معينة
  Future<List<Sale>> getSalesByDateRange(
      String startDate, String endDate) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'sales',
        where: 'sale_date >= ? AND sale_date <= ?',
        whereArgs: [startDate, '$endDate 23:59:59'],
        orderBy: 'sale_date DESC',
      );
      return result.map((e) => Sale.fromMap(e)).toList();
    });
  }

  // ✅ آخر المبيعات
  Future<List<Sale>> getLastSales({int limit = 5}) async {
    return execute(() async {
      final database = await db;
      final result = await database.query('sales',
          orderBy: 'sale_date DESC', limit: limit);
      return result.map((e) => Sale.fromMap(e)).toList();
    });
  }

  // ✅ مبيعات آخر 6 شهور للـ Chart
  Future<List<Map<String, dynamic>>> getSalesLast6Months() async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery('''
        SELECT 
          COALESCE(month_year, strftime('%Y-%m', sale_date)) as month_year,
          SUM(sale_price) as total_sales,
          SUM(profit) as total_profit,
          COUNT(*) as count
        FROM sales
        GROUP BY COALESCE(month_year, strftime('%Y-%m', sale_date))
        ORDER BY month_year DESC
        LIMIT 6
      ''');
      return result.toList();
    });
  }

  // ✅ توزيع المبيعات حسب طريقة الدفع
  Future<List<Map<String, dynamic>>> getSalesByPaymentType() async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery('''
        SELECT payment_type, COUNT(*) as count, SUM(sale_price) as total
        FROM sales
        GROUP BY payment_type
      ''');
      return result.toList();
    });
  }

  // ✅ عدد المبيعات في شهر
  Future<int> getSalesCountByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        '''SELECT COUNT(*) as count FROM sales 
           WHERE month_year = ? 
           OR strftime('%Y-%m', sale_date) = ?''',
        [monthYear, monthYear],
      );
      return result.first['count'] as int;
    });
  }
}
