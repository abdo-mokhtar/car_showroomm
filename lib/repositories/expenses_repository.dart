import '../models/expense.dart';
import 'base_repository.dart';

class ExpensesRepository extends BaseRepository {
  // ✅ كل المصروفات
  Future<List<Expense>> getAllExpenses() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'expenses',
        orderBy: 'expense_date DESC',
      );
      return result.map((e) => Expense.fromMap(e)).toList();
    });
  }

  // ✅ مصروفات شهر معين
  Future<List<Expense>> getExpensesByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'expenses',
        where: 'month_year = ?',
        whereArgs: [monthYear],
        orderBy: 'expense_date DESC',
      );
      return result.map((e) => Expense.fromMap(e)).toList();
    });
  }

  // ✅ مصروفات سيارة معينة
  Future<List<Expense>> getExpensesByCarId(int carId) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'expenses',
        where: 'car_id = ?',
        whereArgs: [carId],
        orderBy: 'expense_date DESC',
      );
      return result.map((e) => Expense.fromMap(e)).toList();
    });
  }

  // ✅ مصروفات حسب التصنيف
  Future<List<Expense>> getExpensesByCategory(String category) async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'expenses',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'expense_date DESC',
      );
      return result.map((e) => Expense.fromMap(e)).toList();
    });
  }

  // ✅ إضافة مصروف
  Future<int> insertExpense(Expense expense) async {
    return execute(() async {
      final database = await db;
      return await database.insert('expenses', expense.toMapForInsert());
    });
  }

  // ✅ تعديل مصروف
  Future<int> updateExpense(Expense expense) async {
    return execute(() async {
      final database = await db;
      return await database.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    });
  }

  // ✅ حذف مصروف
  Future<int> deleteExpense(int id) async {
    return execute(() async {
      final database = await db;
      return await database.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ✅ إجمالي المصروفات في شهر

  // ✅ إجمالي مصروفات سيارة معينة
  Future<double> getTotalExpensesByCarId(int carId) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE car_id = ?',
        [carId],
      );
      return (result.first['total'] as num? ?? 0).toDouble();
    });
  }

// ✅ مصروفات في فترة معينة
  Future<double> getTotalExpensesByDateRange(
      String startDate, String endDate) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE expense_date >= ? AND expense_date <= ?',
        [startDate, '$endDate 23:59:59'],
      );
      return (result.first['total'] as num? ?? 0).toDouble();
    });
  }

  // ✅ المصروفات مجمعة حسب التصنيف في شهر
// ✅ إجمالي المصروفات في شهر
  Future<double> getTotalExpensesByMonth(String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        '''SELECT SUM(amount) as total FROM expenses 
         WHERE month_year = ? 
         OR strftime('%Y-%m', expense_date) = ?''',
        [monthYear, monthYear],
      );
      return (result.first['total'] as num? ?? 0).toDouble();
    });
  }

// ✅ المصروفات مجمعة حسب التصنيف في شهر
  Future<List<Map<String, dynamic>>> getExpensesSummaryByMonth(
      String monthYear) async {
    return execute(() async {
      final database = await db;
      final result = await database.rawQuery(
        '''SELECT category, SUM(amount) as total 
         FROM expenses 
         WHERE month_year = ? 
         OR strftime('%Y-%m', expense_date) = ?
         GROUP BY category
         ORDER BY total DESC''',
        [monthYear, monthYear],
      );
      return result.toList();
    });
  }
}
