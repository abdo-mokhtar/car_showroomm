import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../cubits/reports/reports_cubit.dart';
import '../../cubits/reports/reports_state.dart';
import '../../repositories/sales_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedMonth = '';
  String _filterPayment = 'all';
  String _filterEmployee = 'all';
  String _filterOwnership = 'all';
  List<String> _employees = [];
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadEmployees();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsCubit>().loadReport(
          _selectedMonth,
          paymentType: _filterPayment,
          employeeName: _filterEmployee,
          ownershipType: _filterOwnership,
        );
  }

  Future<void> _loadEmployees() async {
    final salesRepo = SalesRepository();
    final sales = await salesRepo.getAllSales();
    final names =
        sales.map((s) => s.employeeName).whereType<String>().toSet().toList();
    setState(() => _employees = names);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('التقارير', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
// ✅ وأضيف بعده
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _filterDropdown(
                  value: _filterOwnership,
                  items: {
                    'all': 'كل الملكيات',
                    'office': 'ملك المكتب',
                    'consignment': 'معروضة',
                  },
                  onChanged: (v) {
                    setState(() => _filterOwnership = v!);
                    _loadReport();
                  },
                ),
                const SizedBox(width: 12),
                _filterDropdown(
                  value: _filterEmployee,
                  items: {
                    'all': 'كل الموظفين',
                    ..._employees.asMap().map((_, e) => MapEntry(e, e)),
                  },
                  onChanged: (v) {
                    setState(() => _filterEmployee = v!);
                    _loadReport();
                  },
                ),
                const SizedBox(width: 12),
                _filterDropdown(
                  value: _filterPayment,
                  items: {
                    'all': 'كل طرق الدفع',
                    'cash': 'كاش',
                    'transfer': 'تحويل',
                    'check': 'شيك',
                    'installment': 'تقسيط',
                  },
                  onChanged: (v) {
                    setState(() => _filterPayment = v!);
                    _loadReport();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE94560)),
                  );
                }
                if (state is ReportsLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ✅ Stats Grid
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2,
                          children: [
                            _reportCard(
                                'السيارات المباعة',
                                state.carsSold.toString(),
                                Icons.directions_car,
                                Colors.blue),
                            _reportCard(
                                'إجمالي المبيعات',
                                '${state.totalSales.toStringAsFixed(0)} ج',
                                Icons.attach_money,
                                Colors.green),
                            _reportCard(
                                'إجمالي المصروفات',
                                '${state.totalExpenses.toStringAsFixed(0)} ج',
                                Icons.money_off,
                                Colors.orange),
                            _reportCard(
                                'أرباح ملك المكتب',
                                '${state.officeCarsProfit.toStringAsFixed(0)} ج',
                                Icons.business,
                                Colors.purple),
                            _reportCard(
                                'أرباح المعروضة',
                                '${state.consignmentProfit.toStringAsFixed(0)} ج',
                                Icons.handshake,
                                Colors.teal),
                            _reportCard(
                                'صافي الربح',
                                '${state.totalProfit.toStringAsFixed(0)} ج',
                                Icons.trending_up,
                                const Color(0xFFE94560)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ✅ Charts Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Bar Chart - مقارنة المبيعات والمصروفات والأرباح
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
                                      'مقارنة المبيعات والمصروفات',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _legendItem('صافي الربح',
                                            const Color(0xFFE94560)),
                                        const SizedBox(width: 16),
                                        _legendItem('المصروفات', Colors.orange),
                                        const SizedBox(width: 16),
                                        _legendItem('المبيعات', Colors.green),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 220,
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY: state.totalSales * 1.2,
                                          barTouchData: BarTouchData(
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                              getTooltipItem: (group,
                                                  groupIndex, rod, rodIndex) {
                                                final labels = [
                                                  'مبيعات',
                                                  'مصروفات',
                                                  'أرباح'
                                                ];
                                                return BarTooltipItem(
                                                  '${labels[rodIndex]}\n${rod.toY.toStringAsFixed(0)} ج',
                                                  const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11),
                                                );
                                              },
                                            ),
                                          ),
                                          titlesData: FlTitlesData(
                                            rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            leftTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  const labels = [
                                                    'المبيعات',
                                                    'المصروفات',
                                                    'الأرباح'
                                                  ];
                                                  if (value.toInt() >=
                                                      labels.length)
                                                    return const SizedBox();
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                        labels[value.toInt()],
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10)),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            getDrawingHorizontalLine: (value) =>
                                                FlLine(
                                                    color: Colors.white10,
                                                    strokeWidth: 1),
                                          ),
                                          barGroups: [
                                            BarChartGroupData(x: 0, barRods: [
                                              BarChartRodData(
                                                  toY: state.totalSales,
                                                  color: Colors.green,
                                                  width: 40,
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                            ]),
                                            BarChartGroupData(x: 1, barRods: [
                                              BarChartRodData(
                                                  toY: state.totalExpenses,
                                                  color: Colors.orange,
                                                  width: 40,
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                            ]),
                                            BarChartGroupData(x: 2, barRods: [
                                              BarChartRodData(
                                                  toY: state.totalProfit,
                                                  color:
                                                      const Color(0xFFE94560),
                                                  width: 40,
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // ✅ Pie Chart - توزيع الأرباح
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
                                      'توزيع الأرباح',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 220,
                                      child: state.totalProfit <= 0
                                          ? const Center(
                                              child: Text('لا توجد بيانات',
                                                  style: TextStyle(
                                                      color: Colors.grey)))
                                          : PieChart(
                                              PieChartData(
                                                sectionsSpace: 3,
                                                centerSpaceRadius: 45,
                                                sections: [
                                                  PieChartSectionData(
                                                    color: Colors.purple,
                                                    value:
                                                        state.officeCarsProfit,
                                                    title: state.totalProfit > 0
                                                        ? '${(state.officeCarsProfit / state.totalProfit * 100).toStringAsFixed(0)}%'
                                                        : '0%',
                                                    radius: 65,
                                                    titleStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  PieChartSectionData(
                                                    color: Colors.teal,
                                                    value:
                                                        state.consignmentProfit,
                                                    title: state.totalProfit > 0
                                                        ? '${(state.consignmentProfit / state.totalProfit * 100).toStringAsFixed(0)}%'
                                                        : '0%',
                                                    radius: 65,
                                                    titleStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    _legendItem(
                                        'أرباح ملك المكتب', Colors.purple),
                                    const SizedBox(height: 8),
                                    _legendItem('أرباح المعروضة', Colors.teal),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ✅ Top Employee
                        if (state.topEmployee != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('أفضل موظف مبيعات',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(state.topEmployee!,
                                        style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.emoji_events,
                                    color: Colors.amber, size: 40),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),

                        // ✅ Expenses Summary + Bar Chart
                        if (state.expensesSummary.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Expenses List
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16213E),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('توزيع المصروفات',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const Divider(color: Colors.white24),
                                      ...state.expensesSummary.map((e) =>
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    '${(e['total'] as num).toStringAsFixed(0)} ج',
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFFE94560),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    e['category']?.toString() ??
                                                        '-',
                                                    style: const TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Expenses Pie Chart
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16213E),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('توزيع المصروفات بيانياً',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 220,
                                        child: PieChart(
                                          PieChartData(
                                            sectionsSpace: 3,
                                            centerSpaceRadius: 40,
                                            sections: state.expensesSummary
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              final colors = [
                                                Colors.blue,
                                                Colors.orange,
                                                Colors.green,
                                                Colors.purple,
                                                Colors.teal,
                                                Colors.red
                                              ];
                                              final total =
                                                  state.expensesSummary.fold(
                                                      0.0,
                                                      (sum, item) =>
                                                          sum +
                                                          (item['total']
                                                              as num));
                                              final value =
                                                  (e.value['total'] as num)
                                                      .toDouble();
                                              return PieChartSectionData(
                                                color: colors[
                                                    e.key % colors.length],
                                                value: value,
                                                title: total > 0
                                                    ? '${(value / total * 100).toStringAsFixed(0)}%'
                                                    : '0%',
                                                radius: 60,
                                                titleStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ...state.expensesSummary
                                          .asMap()
                                          .entries
                                          .map((e) {
                                        final colors = [
                                          Colors.blue,
                                          Colors.orange,
                                          Colors.green,
                                          Colors.purple,
                                          Colors.teal,
                                          Colors.red
                                        ];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: _legendItem(
                                              e.value['category']?.toString() ??
                                                  '-',
                                              colors[e.key % colors.length]),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }
                if (state is ReportsError) {
                  return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.red)));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required Map<String, String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF0F3460),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _monthPicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          helpText: 'اختر الشهر',
        );
        if (picked != null) {
          setState(() {
            _selectedMonth =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
          });
          // ✅ غير loadReport عشان يطبق الفلاتر
          _loadReport();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month,
                color: Color(0xFFE94560), size: 18),
            const SizedBox(width: 8),
            Text(_selectedMonth, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(width: 4),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
      ],
    );
  }
}
