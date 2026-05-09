import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/installments/installments_cubit.dart';
import '../../cubits/installments/installments_state.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../models/installment.dart';
import '../../models/sale.dart';
import '../../widgets/money_text_field.dart';

class InstallmentsScreen extends StatefulWidget {
  final Sale sale;
  const InstallmentsScreen({super.key, required this.sale});

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InstallmentsCubit>().loadInstallmentsBySaleId(widget.sale.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('الأقساط', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () => _showAddInstallmentDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Stats
          BlocBuilder<InstallmentsCubit, InstallmentsState>(
            builder: (context, state) {
              if (state is! InstallmentsLoaded) return const SizedBox();
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _statCard(
                        'المدفوع',
                        '${state.totalPaid.toStringAsFixed(0)} ج',
                        Colors.green),
                    const SizedBox(width: 12),
                    _statCard(
                        'المتبقي',
                        '${state.totalUnpaid.toStringAsFixed(0)} ج',
                        Colors.orange),
                    const SizedBox(width: 12),
                    _statCard(
                        'متأخرة', state.overdueCount.toString(), Colors.red),
                  ],
                ),
              );
            },
          ),

          // ✅ Installments List
          Expanded(
            child: BlocConsumer<InstallmentsCubit, InstallmentsState>(
              listener: (context, state) {
                if (state is InstallmentsOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is InstallmentsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is InstallmentsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE94560)),
                  );
                }
                if (state is InstallmentsLoaded) {
                  if (state.installments.isEmpty) {
                    return const Center(
                      child: Text('لا توجد أقساط',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.installments.length,
                    itemBuilder: (context, index) {
                      return _installmentCard(
                          state.installments[index], index + 1);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _installmentCard(Installment installment, int index) {
    final isOverdue = installment.isOverdue;
    final isPaid = installment.paid;
    final authCubit = context.read<AuthCubit>();

    Color statusColor = isPaid
        ? Colors.green
        : isOverdue
            ? Colors.red
            : Colors.orange;

    String statusLabel = isPaid
        ? 'مدفوع ✓'
        : isOverdue
            ? 'متأخر !'
            : 'في الانتظار';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Actions
          Row(
            children: [
              if (!isPaid)
                IconButton(
                  icon: const Icon(Icons.check_circle,
                      color: Colors.green, size: 22),
                  onPressed: () => _confirmPay(installment),
                ),
              if (authCubit.isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => context
                      .read<InstallmentsCubit>()
                      .deleteInstallment(installment.id!, widget.sale.id!),
                ),
            ],
          ),
          const Spacer(),
          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'القسط $index',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'تاريخ الاستحقاق: ${installment.dueDate?.substring(0, 10) ?? '-'}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (isPaid && installment.paidDate != null)
                Text(
                  'تاريخ الدفع: ${installment.paidDate!.substring(0, 10)}',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Amount
          Text(
            '${installment.amount.toStringAsFixed(0)} ج',
            style: TextStyle(
              color: statusColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPay(Installment installment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'تأكيد الدفع',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل تم استلام ${installment.amount.toStringAsFixed(0)} ج؟',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              context.read<InstallmentsCubit>().payInstallment(
                    installment.id!,
                    widget.sale.id!,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddInstallmentDialog() {
    final amountController = TextEditingController();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text(
            'إضافة قسط',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ المبلغ
                MoneyTextField(
                  controller: amountController,
                  label: 'مبلغ القسط',
                ),
                const SizedBox(height: 16),

                // ✅ تاريخ الاستحقاق
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setStateDialog(() => dueDate = picked);
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
                          dueDate == null
                              ? 'تاريخ الاستحقاق'
                              : dueDate!.toIso8601String().substring(0, 10),
                          style: TextStyle(
                            color: dueDate == null ? Colors.grey : Colors.white,
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
                if (amountController.text.isEmpty || dueDate == null) return;

                final installment = Installment(
                  saleId: widget.sale.id!,
                  amount: double.tryParse(amountController.text) ?? 0,
                  dueDate: dueDate!.toIso8601String().substring(0, 10),
                  paid: false,
                );

                context
                    .read<InstallmentsCubit>()
                    .insertInstallment(installment);
                Navigator.pop(ctx);
              },
              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
