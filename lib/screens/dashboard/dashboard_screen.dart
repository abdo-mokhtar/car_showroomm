import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../customer_portal/customer_portal_screen.dart';
import '../login/login_screen.dart';
import '../cars/cars_screen.dart';
import '../owner_portal/owner_portal_screen.dart';
import '../sales/sales_screen.dart';
import '../expenses/expenses_screen.dart';
import '../reports/reports_screen.dart';
import '../customers/customers_screen.dart';
import '../owners/owners_screen.dart';
import '../settings/settings_screen.dart';
import '../monthly_close/monthly_close_screen.dart';
import '../user/users_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Row(
        children: [
          _buildSidebar(context, authCubit),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, authCubit),
                Expanded(
                  child: BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE94560)),
                        );
                      }
                      if (state is DashboardLoaded) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildWelcome(authCubit),
                              const SizedBox(height: 24),

                              // ✅ Stats Row
                              _buildStatsRow(state, authCubit),
                              const SizedBox(height: 24),

                              // ✅ الأقساط المتأخرة Alert
                              if (state.overdueInstallments > 0)
                                _buildOverdueAlert(state.overdueInstallments),
                              if (state.overdueInstallments > 0)
                                const SizedBox(height: 24),

                              // ✅ Chart + آخر المبيعات
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Chart
                                  Expanded(
                                    flex: 3,
                                    child: _buildChart(state),
                                  ),
                                  const SizedBox(width: 16),
                                  // آخر المبيعات
                                  Expanded(
                                    flex: 2,
                                    child: _buildLastSales(state),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // ✅ Quick Actions
                              _buildQuickActions(context),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Stats Row
  Widget _buildStatsRow(DashboardLoaded state, AuthCubit authCubit) {
    return Row(
      children: [
        Expanded(
            child: _statCard(
                'سيارات متاحة',
                state.availableCarsCount.toString(),
                Icons.directions_car,
                Colors.blue)),
        const SizedBox(width: 16),
        Expanded(
            child: _statCard('مباعة هذا الشهر', state.soldThisMonth.toString(),
                Icons.sell, Colors.green)),
        const SizedBox(width: 16),
        Expanded(
            child: _statCard(
                'إجمالي المبيعات',
                '${state.totalSalesThisMonth.toStringAsFixed(0)} ج',
                Icons.attach_money,
                Colors.orange)),
        const SizedBox(width: 16),
        if (authCubit.isAdmin)
          Expanded(
              child: _statCard(
                  'صافي الربح',
                  '${state.totalProfitThisMonth.toStringAsFixed(0)} ج',
                  Icons.trending_up,
                  const Color(0xFFE94560))),
      ],
    );
  }

  // ✅ Overdue Alert
  Widget _buildOverdueAlert(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'يوجد $count قسط متأخر - برجاء المتابعة',
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.warning, color: Colors.red),
        ],
      ),
    );
  }

  // ✅ Chart
  Widget _buildChart(DashboardLoaded state) {
    return Column(
      children: [
        // ✅ Row: Bar Chart + Pie Chart
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Bar Chart - المبيعات والأرباح
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'المبيعات والأرباح - آخر 6 شهور',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _legendItem('الأرباح', Colors.green),
                        const SizedBox(width: 16),
                        _legendItem('المبيعات', const Color(0xFFE94560)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: state.last6MonthsSales.isEmpty
                          ? const Center(
                              child: Text('لا توجد بيانات',
                                  style: TextStyle(color: Colors.grey)))
                          : _buildBarChart(state),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // ✅ Pie Chart - توزيع طرق الدفع
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'توزيع طرق الدفع',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: state.salesByPaymentType.isEmpty
                          ? const Center(
                              child: Text('لا توجد بيانات',
                                  style: TextStyle(color: Colors.grey)))
                          : _buildPieChart(state),
                    ),
                    const SizedBox(height: 16),
                    // Pie Legend
                    ..._buildPieLegend(state),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ✅ Line Chart - نمو المبيعات
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'نمو المبيعات - آخر 6 شهور',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: state.last6MonthsSales.isEmpty
                    ? const Center(
                        child: Text('لا توجد بيانات',
                            style: TextStyle(color: Colors.grey)))
                    : _buildLineChart(state),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(DashboardLoaded state) {
    final data = state.last6MonthsSales.reversed.toList();
    final maxY = data
            .map((e) => (e['total_sales'] as num? ?? 0).toDouble())
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0 ? 'مبيعات' : 'أرباح';
              return BarTooltipItem(
                '$label\n${rod.toY.toStringAsFixed(0)} ج',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                // ✅ اعرض كل month مرة واحدة بس
                if (value != value.roundToDouble()) return const SizedBox();
                final month = data[index]['month_year']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    month.length >= 7 ? month.substring(5) : month,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          ),
        ),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value['total_sales'] as num? ?? 0).toDouble(),
                color: const Color(0xFFE94560),
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: (e.value['total_profit'] as num? ?? 0).toDouble(),
                color: Colors.green,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(DashboardLoaded state) {
    final data = state.last6MonthsSales.reversed.toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox();
                final month =
                    data[value.toInt()]['month_year']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    month.length >= 7 ? month.substring(5) : month,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(0)} ج',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(
                e.key.toDouble(),
                (e.value['total_sales'] as num? ?? 0).toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: const Color(0xFFE94560),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFFE94560),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFE94560).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(DashboardLoaded state) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];
    final total = state.salesByPaymentType
        .fold(0.0, (sum, e) => sum + (e['count'] as num? ?? 0));

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: state.salesByPaymentType.asMap().entries.map((e) {
          final count = (e.value['count'] as num? ?? 0).toDouble();
          final percent = total > 0 ? (count / total * 100) : 0;
          return PieChartSectionData(
            color: colors[e.key % colors.length],
            value: count,
            title: '${percent.toStringAsFixed(0)}%',
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildPieLegend(DashboardLoaded state) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];
    final labels = {
      'cash': 'كاش',
      'transfer': 'تحويل',
      'check': 'شيك',
      'installment': 'تقسيط'
    };

    return state.salesByPaymentType.asMap().entries.map((e) {
      final type = e.value['payment_type']?.toString() ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${e.value['count']} مبيعات',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(width: 8),
            Text(
              labels[type] ?? type,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[e.key % colors.length],
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(width: 4),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  // ✅ آخر المبيعات
  Widget _buildLastSales(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'آخر المبيعات',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (state.lastSales.isEmpty)
            const Center(
                child: Text('لا توجد مبيعات',
                    style: TextStyle(color: Colors.grey)))
          else
            ...state.lastSales.map((sale) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${sale.salePrice.toStringAsFixed(0)} ج',
                        style: const TextStyle(
                            color: Color(0xFFE94560),
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            sale.employeeName ?? '-',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          Text(
                            sale.saleDate?.substring(0, 10) ?? '',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AuthCubit authCubit) {
    return Container(
      width: 220,
      color: const Color(0xFF16213E),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.directions_car,
                size: 35, color: Color(0xFFE94560)),
          ),
          const SizedBox(height: 10),
          const Text('معرض السيارات',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _sidebarItem(context, Icons.person_outline, 'بوابة الملاك',
                      const OwnerPortalScreen()),
                  _sidebarItem(context, Icons.people_outline, 'بوابة العملاء',
                      const CustomerPortalScreen()),
                  _sidebarItem(context, Icons.dashboard, 'الرئيسية', null),
                  _sidebarItem(context, Icons.directions_car, 'السيارات',
                      const CarsScreen()),
                  _sidebarItem(context, Icons.point_of_sale, 'المبيعات',
                      const SalesScreen()),
                  _sidebarItem(context, Icons.people, 'العملاء',
                      const CustomersScreen()),
                  _sidebarItem(
                      context, Icons.person, 'المالكين', const OwnersScreen()),
                  _sidebarItem(context, Icons.money_off, 'المصروفات',
                      const ExpensesScreen()),
                  _sidebarItem(context, Icons.bar_chart, 'التقارير',
                      const ReportsScreen()),
                  if (authCubit.isAdmin) ...[
                    _sidebarItem(context, Icons.manage_accounts, 'المستخدمين',
                        const UsersScreen()),
                    _sidebarItem(context, Icons.lock_clock, 'إغلاق الشهر',
                        const MonthlyCloseScreen()),
                    _sidebarItem(context, Icons.settings, 'الإعدادات',
                        const SettingsScreen()),
                  ],
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFE94560)),
            title: const Text('خروج', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sidebarItem(
      BuildContext context, IconData icon, String title, Widget? screen) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE94560), size: 22),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 13)),
      onTap: screen == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
              ).then((_) {
                // ✅ refresh الداشبورد لما ترجع
                if (context.mounted) {
                  context.read<DashboardCubit>().loadDashboard();
                }
              });
            },
    );
  }

  Widget _buildTopBar(BuildContext context, AuthCubit authCubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      color: const Color(0xFF16213E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'لوحة التحكم',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              // ✅ Notification Bell
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final overdueCount =
                      state is DashboardLoaded ? state.overdueInstallments : 0;
                  return GestureDetector(
                    onTap: () => _showOverdueInstallments(context, state),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: overdueCount > 0
                                ? Colors.red.withOpacity(0.1)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications,
                            color:
                                overdueCount > 0 ? Colors.red : Colors.white54,
                            size: 22,
                          ),
                        ),
                        if (overdueCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                overdueCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              const Icon(Icons.person, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text(
                authCubit.currentUsername ?? '',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      authCubit.isAdmin ? const Color(0xFFE94560) : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  authCubit.isAdmin ? 'مدير' : 'موظف',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOverdueInstallments(BuildContext context, DashboardState state) {
    if (state is! DashboardLoaded || state.overdueInstallments == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد أقساط متأخرة ✅'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'أقساط متأخرة (${state.overdueInstallments})',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.warning, color: Colors.red),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'يوجد ${state.overdueInstallments} قسط متأخر',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'برجاء متابعة العملاء وتحصيل الأقساط',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.warning_amber,
                        color: Colors.red, size: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560)),
            onPressed: () {
              Navigator.pop(ctx);
              // ✅ روح لشاشة المبيعات
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesScreen()),
              );
            },
            child: const Text('عرض المبيعات',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(AuthCubit authCubit) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'أهلاً، ${authCubit.currentUsername ?? ''} 👋',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${now.day}/${now.month}/${now.year}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('وصول سريع',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _quickActionCard(context,
                icon: Icons.add_circle,
                title: 'إضافة سيارة',
                color: Colors.blue,
                screen: const CarsScreen()),
            const SizedBox(width: 16),
            _quickActionCard(context,
                icon: Icons.point_of_sale,
                title: 'تسجيل بيع',
                color: Colors.green,
                screen: const SalesScreen()),
            const SizedBox(width: 16),
            _quickActionCard(context,
                icon: Icons.money_off,
                title: 'إضافة مصروف',
                color: Colors.orange,
                screen: const ExpensesScreen()),
            const SizedBox(width: 16),
            _quickActionCard(context,
                icon: Icons.bar_chart,
                title: 'التقارير',
                color: const Color(0xFFE94560),
                screen: const ReportsScreen()),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required Widget screen}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ).then((_) {
          // ✅ refresh الداشبورد لما ترجع
          if (context.mounted) {
            context.read<DashboardCubit>().loadDashboard();
          }
        }),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
