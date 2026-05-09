import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('car_showroom.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('admin', 'employee')),
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.insert('users', {
      'username': 'admin',
      'password':
          '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.execute('''
      CREATE TABLE owners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        national_id TEXT,
        notes TEXT,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE cars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER,
        color TEXT,
        plate_number TEXT,
        chassis_number TEXT,
        purchase_price REAL DEFAULT 0,
        expected_price REAL DEFAULT 0,
        ownership_type TEXT NOT NULL CHECK(ownership_type IN ('office', 'consignment')),
        status TEXT NOT NULL DEFAULT 'available' CHECK(status IN ('available', 'sold')),
        kilometers INTEGER DEFAULT 0,
        fuel_type TEXT,
        transmission TEXT,
        engine_capacity TEXT,
        car_condition TEXT CHECK(car_condition IN ('new', 'used')),
        accessories TEXT,
        technical_notes TEXT,
        purchase_date TEXT,
        purchased_from TEXT,
        purchase_payment_method TEXT,
        owner_id INTEGER,
        commission_type TEXT CHECK(commission_type IN ('percentage', 'fixed')),
        commission_value REAL DEFAULT 0,
        display_fees REAL DEFAULT 0,
        month_year TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (owner_id) REFERENCES owners (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE car_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        car_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (car_id) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        notes TEXT,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        car_id INTEGER NOT NULL,
        customer_id INTEGER,
        sale_price REAL NOT NULL DEFAULT 0,
        payment_type TEXT CHECK(payment_type IN ('cash', 'transfer', 'check', 'installment')),
        total_amount REAL DEFAULT 0,
        paid_amount REAL DEFAULT 0,
        remaining_amount REAL DEFAULT 0,
        profit REAL DEFAULT 0,
        sale_date TEXT,
        employee_name TEXT,
        month_year TEXT,
        notes TEXT,
        FOREIGN KEY (car_id) REFERENCES cars (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        due_date TEXT,
        paid INTEGER DEFAULT 0,
        paid_date TEXT,
        notes TEXT,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        category TEXT,
        car_id INTEGER,
        expense_date TEXT,
        month_year TEXT,
        notes TEXT,
        FOREIGN KEY (car_id) REFERENCES cars (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE monthly_close (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        period_name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        month_year TEXT,
        total_sales REAL DEFAULT 0,
        total_expenses REAL DEFAULT 0,
        total_profit REAL DEFAULT 0,
        cars_sold INTEGER DEFAULT 0,
        closed_by INTEGER,
        closed_at TEXT,
        is_closed INTEGER DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (closed_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE company_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT,
        logo_path TEXT,
        address TEXT,
        phone TEXT,
        currency TEXT DEFAULT 'EGP',
        language TEXT DEFAULT 'ar',
        manager_signature TEXT
      )
    ''');
// SUBSCRIPTIONS
    await db.execute('''
  CREATE TABLE subscriptions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    activation_code TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    plan TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,
    activated_at TEXT DEFAULT (datetime('now'))
  )
''');
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        table_name TEXT,
        record_id INTEGER,
        old_value TEXT,
        new_value TEXT,
        timestamp TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('CREATE INDEX idx_cars_status ON cars(status)');
    await db.execute('CREATE INDEX idx_cars_month ON cars(month_year)');
    await db.execute('CREATE INDEX idx_sales_month ON sales(month_year)');
    await db.execute('CREATE INDEX idx_expenses_month ON expenses(month_year)');

    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    // ✅ Users
    await db.insert('users', {
      'username': 'احمد',
      'password':
          '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
      'role': 'employee'
    });
    await db.insert('users', {
      'username': 'محمد',
      'password':
          '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
      'role': 'employee'
    });

    // ✅ Owners
    await db.insert('owners', {'name': 'خالد محمد', 'phone': '01012345678'});
    await db.insert('owners', {'name': 'سامي علي', 'phone': '01098765432'});

    // ✅ Customers
    await db.insert('customers', {'name': 'عمر أحمد', 'phone': '01111111111'});
    await db.insert('customers', {'name': 'يوسف حسن', 'phone': '01222222222'});
    await db.insert('customers', {'name': 'كريم سعيد', 'phone': '01333333333'});
    await db.insert('customers', {'name': 'مصطفى علي', 'phone': '01444444444'});
    await db
        .insert('customers', {'name': 'هاني محمود', 'phone': '01555555555'});

    // ✅ Cars
    await db.insert('cars', {
      'brand': 'تويوتا',
      'model': 'كامري',
      'year': 2022,
      'color': 'أبيض',
      'plate_number': 'أ ب ج 1234',
      'purchase_price': 280000.0,
      'expected_price': 320000.0,
      'ownership_type': 'office',
      'status': 'sold',
      'kilometers': 15000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'used',
      'month_year': '2026-01'
    });
    await db.insert('cars', {
      'brand': 'هوندا',
      'model': 'سيفيك',
      'year': 2023,
      'color': 'أسود',
      'plate_number': 'د ه و 5678',
      'purchase_price': 220000.0,
      'expected_price': 260000.0,
      'ownership_type': 'office',
      'status': 'sold',
      'kilometers': 8000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'used',
      'month_year': '2026-01'
    });
    await db.insert('cars', {
      'brand': 'هيونداي',
      'model': 'النترا',
      'year': 2021,
      'color': 'فضي',
      'plate_number': 'ز ح ط 9012',
      'purchase_price': 180000.0,
      'expected_price': 210000.0,
      'ownership_type': 'consignment',
      'status': 'sold',
      'kilometers': 25000,
      'fuel_type': 'بنزين',
      'transmission': 'مانيوال',
      'car_condition': 'used',
      'owner_id': 1,
      'commission_type': 'fixed',
      'commission_value': 5000.0,
      'display_fees': 1000.0,
      'month_year': '2026-01'
    });
    await db.insert('cars', {
      'brand': 'كيا',
      'model': 'سيراتو',
      'year': 2022,
      'color': 'أحمر',
      'plate_number': 'ي ك ل 3456',
      'purchase_price': 195000.0,
      'expected_price': 230000.0,
      'ownership_type': 'office',
      'status': 'sold',
      'kilometers': 12000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'used',
      'month_year': '2026-02'
    });
    await db.insert('cars', {
      'brand': 'مرسيدس',
      'model': 'C200',
      'year': 2020,
      'color': 'أبيض',
      'plate_number': 'م ن س 7890',
      'purchase_price': 550000.0,
      'expected_price': 620000.0,
      'ownership_type': 'office',
      'status': 'sold',
      'kilometers': 35000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'used',
      'month_year': '2026-02'
    });
    await db.insert('cars', {
      'brand': 'نيسان',
      'model': 'صني',
      'year': 2023,
      'color': 'أزرق',
      'plate_number': 'ع ف ص 1111',
      'purchase_price': 150000.0,
      'expected_price': 175000.0,
      'ownership_type': 'office',
      'status': 'sold',
      'kilometers': 5000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'new',
      'month_year': '2026-02'
    });
    await db.insert('cars', {
      'brand': 'BMW',
      'model': 'X5',
      'year': 2021,
      'color': 'أسود',
      'plate_number': 'ق ر ش 2222',
      'purchase_price': 800000.0,
      'expected_price': 900000.0,
      'ownership_type': 'office',
      'status': 'sold',
      'kilometers': 20000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'used',
      'month_year': '2026-03'
    });
    await db.insert('cars', {
      'brand': 'تويوتا',
      'model': 'لاندكروزر',
      'year': 2023,
      'color': 'أبيض',
      'plate_number': 'ل م ن 3333',
      'purchase_price': 1200000.0,
      'expected_price': 1350000.0,
      'ownership_type': 'office',
      'status': 'available',
      'kilometers': 10000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'used',
      'month_year': '2026-03'
    });
    await db.insert('cars', {
      'brand': 'هيونداي',
      'model': 'توسان',
      'year': 2022,
      'color': 'رمادي',
      'plate_number': 'ه و ز 4444',
      'purchase_price': 350000.0,
      'expected_price': 400000.0,
      'ownership_type': 'consignment',
      'status': 'available',
      'kilometers': 18000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'used',
      'owner_id': 2,
      'commission_type': 'percentage',
      'commission_value': 5.0,
      'display_fees': 2000.0,
      'month_year': '2026-03'
    });
    await db.insert('cars', {
      'brand': 'كيا',
      'model': 'سبورتاج',
      'year': 2023,
      'color': 'أبيض',
      'plate_number': 'ح ط ي 5555',
      'purchase_price': 420000.0,
      'expected_price': 480000.0,
      'ownership_type': 'office',
      'status': 'available',
      'kilometers': 5000,
      'fuel_type': 'بنزين',
      'transmission': 'أوتوماتيك',
      'car_condition': 'new',
      'month_year': '2026-03'
    });

    // ✅ Sales
    await db.insert('sales', {
      'car_id': 1,
      'customer_id': 1,
      'sale_price': 320000.0,
      'payment_type': 'cash',
      'total_amount': 320000.0,
      'paid_amount': 320000.0,
      'remaining_amount': 0.0,
      'profit': 40000.0,
      'sale_date': '2026-01-10',
      'employee_name': 'احمد',
      'month_year': '2026-01'
    });
    await db.insert('sales', {
      'car_id': 2,
      'customer_id': 2,
      'sale_price': 260000.0,
      'payment_type': 'transfer',
      'total_amount': 260000.0,
      'paid_amount': 260000.0,
      'remaining_amount': 0.0,
      'profit': 40000.0,
      'sale_date': '2026-01-15',
      'employee_name': 'محمد',
      'month_year': '2026-01'
    });
    await db.insert('sales', {
      'car_id': 3,
      'customer_id': 3,
      'sale_price': 210000.0,
      'payment_type': 'installment',
      'total_amount': 210000.0,
      'paid_amount': 70000.0,
      'remaining_amount': 140000.0,
      'profit': 24000.0,
      'sale_date': '2026-01-20',
      'employee_name': 'احمد',
      'month_year': '2026-01'
    });
    await db.insert('sales', {
      'car_id': 4,
      'customer_id': 4,
      'sale_price': 230000.0,
      'payment_type': 'cash',
      'total_amount': 230000.0,
      'paid_amount': 230000.0,
      'remaining_amount': 0.0,
      'profit': 35000.0,
      'sale_date': '2026-02-05',
      'employee_name': 'محمد',
      'month_year': '2026-02'
    });
    await db.insert('sales', {
      'car_id': 5,
      'customer_id': 5,
      'sale_price': 620000.0,
      'payment_type': 'transfer',
      'total_amount': 620000.0,
      'paid_amount': 620000.0,
      'remaining_amount': 0.0,
      'profit': 70000.0,
      'sale_date': '2026-02-10',
      'employee_name': 'احمد',
      'month_year': '2026-02'
    });
    await db.insert('sales', {
      'car_id': 6,
      'customer_id': 1,
      'sale_price': 175000.0,
      'payment_type': 'check',
      'total_amount': 175000.0,
      'paid_amount': 175000.0,
      'remaining_amount': 0.0,
      'profit': 25000.0,
      'sale_date': '2026-02-20',
      'employee_name': 'محمد',
      'month_year': '2026-02'
    });
    await db.insert('sales', {
      'car_id': 7,
      'customer_id': 2,
      'sale_price': 900000.0,
      'payment_type': 'cash',
      'total_amount': 900000.0,
      'paid_amount': 900000.0,
      'remaining_amount': 0.0,
      'profit': 100000.0,
      'sale_date': '2026-03-01',
      'employee_name': 'احمد',
      'month_year': '2026-03'
    });
    await db.insert('sales', {
      'car_id': 4,
      'customer_id': 3,
      'sale_price': 195000.0,
      'payment_type': 'installment',
      'total_amount': 195000.0,
      'paid_amount': 65000.0,
      'remaining_amount': 130000.0,
      'profit': 20000.0,
      'sale_date': '2026-03-05',
      'employee_name': 'محمد',
      'month_year': '2026-03'
    });
    await db.insert('sales', {
      'car_id': 5,
      'customer_id': 4,
      'sale_price': 580000.0,
      'payment_type': 'transfer',
      'total_amount': 580000.0,
      'paid_amount': 580000.0,
      'remaining_amount': 0.0,
      'profit': 80000.0,
      'sale_date': '2026-03-10',
      'employee_name': 'احمد',
      'month_year': '2026-03'
    });

    // ✅ Installments
    await db.insert('installments', {
      'sale_id': 3,
      'amount': 70000.0,
      'due_date': '2026-02-20',
      'paid': 1,
      'paid_date': '2026-02-18'
    });
    await db.insert('installments', {
      'sale_id': 3,
      'amount': 70000.0,
      'due_date': '2026-03-20',
      'paid': 1,
      'paid_date': '2026-03-19'
    });
    await db.insert('installments',
        {'sale_id': 3, 'amount': 70000.0, 'due_date': '2026-04-20', 'paid': 0});
    await db.insert('installments',
        {'sale_id': 8, 'amount': 65000.0, 'due_date': '2026-04-05', 'paid': 0});
    await db.insert('installments',
        {'sale_id': 8, 'amount': 65000.0, 'due_date': '2025-12-05', 'paid': 0});
    await db.insert('installments',
        {'sale_id': 8, 'amount': 65000.0, 'due_date': '2026-06-05', 'paid': 0});

    // ✅ Expenses
    await db.insert('expenses', {
      'name': 'إيجار المعرض',
      'amount': 5000.0,
      'category': 'إيجار',
      'expense_date': '2026-01-01',
      'month_year': '2026-01'
    });
    await db.insert('expenses', {
      'name': 'فاتورة كهرباء',
      'amount': 800.0,
      'category': 'كهرباء',
      'expense_date': '2026-01-05',
      'month_year': '2026-01'
    });
    await db.insert('expenses', {
      'name': 'دعاية وإعلان',
      'amount': 2000.0,
      'category': 'دعاية',
      'expense_date': '2026-01-10',
      'month_year': '2026-01'
    });
    await db.insert('expenses', {
      'name': 'إيجار المعرض',
      'amount': 5000.0,
      'category': 'إيجار',
      'expense_date': '2026-02-01',
      'month_year': '2026-02'
    });
    await db.insert('expenses', {
      'name': 'صيانة',
      'amount': 1500.0,
      'category': 'صيانة',
      'expense_date': '2026-02-15',
      'month_year': '2026-02'
    });
    await db.insert('expenses', {
      'name': 'فاتورة كهرباء',
      'amount': 900.0,
      'category': 'كهرباء',
      'expense_date': '2026-02-05',
      'month_year': '2026-02'
    });
    await db.insert('expenses', {
      'name': 'تشغيل',
      'amount': 1200.0,
      'category': 'تشغيل',
      'expense_date': '2026-02-20',
      'month_year': '2026-02'
    });
    await db.insert('expenses', {
      'name': 'إيجار المعرض',
      'amount': 5000.0,
      'category': 'إيجار',
      'expense_date': '2026-03-01',
      'month_year': '2026-03'
    });
    await db.insert('expenses', {
      'name': 'دعاية وإعلان',
      'amount': 3000.0,
      'category': 'دعاية',
      'expense_date': '2026-03-10',
      'month_year': '2026-03'
    });
    await db.insert('expenses', {
      'name': 'فاتورة كهرباء',
      'amount': 750.0,
      'category': 'كهرباء',
      'expense_date': '2026-03-05',
      'month_year': '2026-03'
    });
    await db.insert('expenses', {
      'name': 'تشغيل',
      'amount': 2500.0,
      'category': 'تشغيل',
      'expense_date': '2026-03-15',
      'month_year': '2026-03'
    });

    // ✅ Settings
    await db.insert('company_settings', {
      'company_name': 'معرض النجوم للسيارات',
      'phone': '01000000000',
      'address': 'القاهرة - مصر',
      'currency': 'EGP',
      'language': 'ar',
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
