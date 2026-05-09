import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/expenses/expenses_cubit.dart';
import '../../cubits/expenses/expenses_state.dart';
import '../../cubits/cars/cars_cubit.dart';
import '../../cubits/cars/cars_state.dart';
import '../../models/expense.dart';
import '../../widgets/money_text_field.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedMonth = '';
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    // ✅ جيب كل المصروفات مش بس الشهر الحالي
    context.read<ExpensesCubit>().loadAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('المصروفات', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () => _showAddExpenseDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Stats
          BlocBuilder<ExpensesCubit, ExpensesState>(
            builder: (context, state) {
              if (state is! ExpensesLoaded) return const SizedBox();
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _statCard('عدد المصروفات', state.expenses.length.toString(),
                        Colors.blue),
                    const SizedBox(width: 12),
                    _statCard(
                        'إجمالي المصروفات',
                        '${state.totalAmount.toStringAsFixed(0)} ج',
                        const Color(0xFFE94560)),
                  ],
                ),
              );
            },
          ),

          // ✅ Month Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('الشهر:', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                _monthPicker(),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ✅ Expenses List
          Expanded(
            child: BlocConsumer<ExpensesCubit, ExpensesState>(
              listener: (context, state) {
                if (state is ExpensesOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is ExpensesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ExpensesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE94560)),
                  );
                }
                if (state is ExpensesLoaded) {
                  if (state.expenses.isEmpty) {
                    return const Center(
                      child: Text('لا توجد مصروفات',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      return _expenseCard(state.expenses[index]);
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
          context.read<ExpensesCubit>().loadExpensesByMonth(_selectedMonth);
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

  Widget _expenseCard(Expense expense) {
    final authCubit = context.read<AuthCubit>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Actions
          if (authCubit.isAdmin)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () =>
                      context.read<ExpensesCubit>().deleteExpense(expense.id!),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _showAddExpenseDialog(expense: expense),
                ),
              ],
            ),
          const Spacer(),
          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                expense.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    expense.expenseDate?.substring(0, 10) ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  if (expense.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        expense.category!,
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Amount
          Text(
            '${expense.amount.toStringAsFixed(0)} ج',
            style: const TextStyle(
              color: Color(0xFFE94560),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog({Expense? expense}) {
    final isEditing = expense != null;
    final nameController = TextEditingController(text: expense?.name ?? '');
    final amountController =
        TextEditingController(text: expense?.amount.toString() ?? '');
    final notesController = TextEditingController(text: expense?.notes ?? '');
    String category = expense?.category ?? 'إيجار';
    int? selectedCarId = expense?.carId;

    final categories = [
      'إيجار',
      'كهرباء',
      'صيانة',
      'دعاية',
      'تشغيل',
      'سيارة',
      'أخرى'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: Text(
            isEditing ? 'تعديل مصروف' : 'إضافة مصروف',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('اسم المصروف'),
                  ),
                  const SizedBox(height: 16),
                  MoneyTextField(
                    controller: amountController,
                    label: 'المبلغ',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: _inputDecoration('التصنيف'),
                    dropdownColor: const Color(0xFF0F3460),
                    style: const TextStyle(color: Colors.white),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => category = v!),
                  ),
                  const SizedBox(height: 16),
                  // ✅ ربط بسيارة (اختياري)
                  if (category == 'سيارة')
                    BlocBuilder<CarsCubit, CarsState>(
                      builder: (context, state) {
                        if (state is! CarsLoaded) {
                          return const SizedBox();
                        }
                        return DropdownButtonFormField<int?>(
                          value: selectedCarId,
                          decoration: _inputDecoration('السيارة (اختياري)'),
                          dropdownColor: const Color(0xFF0F3460),
                          style: const TextStyle(color: Colors.white),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('بدون سيارة'),
                            ),
                            ...state.cars.map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text('${c.brand} ${c.model}'),
                                )),
                          ],
                          onChanged: (v) =>
                              setStateDialog(() => selectedCarId = v),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('ملاحظات'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final now = DateTime.now();
                final monthYear =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}';

                final newExpense = Expense(
                  id: expense?.id,
                  name: nameController.text.trim(),
                  amount: double.tryParse(amountController.text) ?? 0,
                  category: category,
                  carId: selectedCarId,
                  expenseDate: now.toIso8601String(),
                  monthYear: monthYear,
                  notes: notesController.text,
                );

                if (isEditing) {
                  context.read<ExpensesCubit>().updateExpense(newExpense);
                } else {
                  context.read<ExpensesCubit>().insertExpense(newExpense);
                }

                Navigator.pop(context);
              },
              child: Text(
                isEditing ? 'تحديث' : 'إضافة',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF0F3460),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
