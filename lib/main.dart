import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/theme/app_theme.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/cars/cars_cubit.dart';
import 'cubits/customers/customers_cubit.dart';
import 'cubits/owners/owners_cubit.dart';
import 'cubits/sales/sales_cubit.dart';
import 'cubits/installments/installments_cubit.dart';
import 'cubits/expenses/expenses_cubit.dart';
import 'cubits/reports/reports_cubit.dart';
import 'cubits/monthly_close/monthly_close_cubit.dart';
import 'cubits/settings/settings_cubit.dart';
import 'cubits/dashboard/dashboard_cubit.dart';

import 'repositories/users_repository.dart';
import 'repositories/cars_repository.dart';
import 'repositories/car_images_repository.dart';
import 'repositories/customers_repository.dart';
import 'repositories/owners_repository.dart';
import 'repositories/sales_repository.dart';
import 'repositories/installments_repository.dart';
import 'repositories/expenses_repository.dart';
import 'repositories/monthly_close_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/audit_log_repository.dart';
import 'repositories/subscription_repository.dart';

import 'screens/login/login_screen.dart';
import 'screens/subscription/subscription_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // ✅ فحص الاشتراك
  final subRepo = SubscriptionRepository();
  final isValid = await subRepo.isSubscriptionValid();

  runApp(MyApp(isSubscriptionValid: isValid));
}

class MyApp extends StatelessWidget {
  final bool isSubscriptionValid;
  const MyApp({super.key, required this.isSubscriptionValid});

  @override
  Widget build(BuildContext context) {
    final usersRepo = UsersRepository();
    final carsRepo = CarsRepository();
    final carImagesRepo = CarImagesRepository();
    final customersRepo = CustomersRepository();
    final ownersRepo = OwnersRepository();
    final salesRepo = SalesRepository();
    final installmentsRepo = InstallmentsRepository();
    final expensesRepo = ExpensesRepository();
    final monthlyCloseRepo = MonthlyCloseRepository();
    final settingsRepo = SettingsRepository();
    // ignore: unused_local_variable
    final auditLogRepo = AuditLogRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(usersRepo)),
        BlocProvider(
            create: (_) =>
                CarsCubit(carsRepo, expensesRepo, salesRepo, carImagesRepo)),
        BlocProvider(create: (_) => CustomersCubit(customersRepo)),
        BlocProvider(create: (_) => OwnersCubit(ownersRepo)),
        BlocProvider(create: (_) => SalesCubit(salesRepo, carsRepo)),
        BlocProvider(create: (_) => InstallmentsCubit(installmentsRepo)),
        BlocProvider(create: (_) => ExpensesCubit(expensesRepo)),
        BlocProvider(
            create: (_) => ReportsCubit(salesRepo, expensesRepo, carsRepo)),
        BlocProvider(
            create: (_) =>
                MonthlyCloseCubit(monthlyCloseRepo, salesRepo, expensesRepo)),
        BlocProvider(create: (_) => SettingsCubit(settingsRepo)),
        BlocProvider(
            create: (_) =>
                DashboardCubit(salesRepo, carsRepo, installmentsRepo)),
      ],
      child: MaterialApp(
        title: 'Car Showroom',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        theme: AppTheme.darkTheme,
        // ✅ فحص الاشتراك
        home: const SubscriptionScreen(),
      ),
    );
  }
}
