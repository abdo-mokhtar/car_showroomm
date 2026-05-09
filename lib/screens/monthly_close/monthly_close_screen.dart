import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/monthly_close/monthly_close_cubit.dart';
import '../../cubits/monthly_close/monthly_close_state.dart';
import '../../models/monthly_close.dart';

class MonthlyCloseScreen extends StatefulWidget {
  const MonthlyCloseScreen({super.key});

  @override
  State<MonthlyCloseScreen> createState() => _MonthlyCloseScreenState();
}

class _MonthlyCloseScreenState extends State<MonthlyCloseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MonthlyCloseCubit>().loadAllMonthlyCloses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('إغلاق الشهر', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<MonthlyCloseCubit, MonthlyCloseState>(
        listener: (context, state) {
          if (state is MonthlyCloseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MonthlyCloseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MonthlyCloseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)),
            );
          }
          if (state is MonthlyCloseLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ✅ Current Month Card
                  _currentMonthCard(context, state),
                  const SizedBox(height: 24),

                  // ✅ History
                  if (state.monthlyCloses.isNotEmpty) ...[
                    const Text(
                      'سجل الشهور المغلقة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.monthlyCloses
                        .where((m) => m.isClosed)
                        .map((m) => _historyCard(m)),
                  ],
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _currentMonthCard(BuildContext context, MonthlyCloseLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE94560).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'إغلاق فترة جديدة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'حدد الفترة الزمنية واسمها لإغلاقها',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.lock, color: Colors.white),
              label: const Text(
                'إغلاق فترة جديدة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _confirmCloseMonth(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(MonthlyClose month) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.lock, color: Colors.green, size: 18),
              Text(
                month.periodName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${month.totalProfit.toStringAsFixed(0)} ج',
                style: const TextStyle(
                  color: Color(0xFFE94560),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ربح: ',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${month.carsSold} سيارة',
                style: const TextStyle(color: Colors.blue),
              ),
              const Text(
                'مبيعات: ',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          if (month.closedAt != null)
            Text(
              'أُغلق في: ${month.closedAt!.substring(0, 10)}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.right,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {Color valueColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  void _confirmCloseMonth(BuildContext context) {
    final periodNameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text(
            'إغلاق فترة جديدة',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ اسم الفترة
                TextField(
                  controller: periodNameController,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'اسم الفترة (مثال: يناير 2025)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0F3460),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ من تاريخ
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setStateDialog(() => startDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFFE94560), size: 18),
                        Text(
                          startDate == null
                              ? 'من تاريخ'
                              : startDate!.toIso8601String().substring(0, 10),
                          style: TextStyle(
                            color:
                                startDate == null ? Colors.grey : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ إلى تاريخ
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setStateDialog(() => endDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFFE94560), size: 18),
                        Text(
                          endDate == null
                              ? 'إلى تاريخ'
                              : endDate!.toIso8601String().substring(0, 10),
                          style: TextStyle(
                            color: endDate == null ? Colors.grey : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560)),
              onPressed: () {
                if (periodNameController.text.trim().isEmpty ||
                    startDate == null ||
                    endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('برجاء ملء جميع البيانات'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final userId = context.read<AuthCubit>().currentUserId ?? 0;
                context.read<MonthlyCloseCubit>().closeMonth(
                      closedBy: userId,
                      periodName: periodNameController.text.trim(),
                      startDate: startDate!.toIso8601String().substring(0, 10),
                      endDate: endDate!.toIso8601String().substring(0, 10),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('إغلاق الفترة',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
