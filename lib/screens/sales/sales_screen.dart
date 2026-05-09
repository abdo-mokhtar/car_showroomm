import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/invoice_pdf.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/sales/sales_cubit.dart';
import '../../cubits/sales/sales_state.dart';
import '../../cubits/cars/cars_cubit.dart';
import '../../cubits/customers/customers_cubit.dart';
import '../../cubits/customers/customers_state.dart';
import '../../cubits/cars/cars_state.dart';
import '../../cubits/installments/installments_cubit.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../cubits/settings/settings_state.dart';
import '../../models/sale.dart';
import '../../models/car.dart';
import '../../models/customer.dart';
import '../../models/installment.dart';
import '../../repositories/cars_repository.dart';
import '../../repositories/customers_repository.dart';
import '../../repositories/installments_repository.dart';
import '../../widgets/money_text_field.dart';
import '../installments/installments_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _selectedMonth = '';
  String _filterPayment = 'all';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    context.read<SalesCubit>().loadAllSales();
    context.read<CarsCubit>().loadAvailableCars();
    context.read<CustomersCubit>().loadAllCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('المبيعات', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () => _showAddSaleDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Stats
          BlocBuilder<SalesCubit, SalesState>(
            builder: (context, state) {
              if (state is! SalesLoaded) return const SizedBox();
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _statCard('عدد المبيعات', state.totalCount.toString(),
                        Colors.blue),
                    const SizedBox(width: 12),
                    _statCard(
                        'إجمالي المبيعات',
                        '${state.totalSales.toStringAsFixed(0)} ج',
                        Colors.green),
                    const SizedBox(width: 12),
                    if (context.read<AuthCubit>().isAdmin)
                      _statCard(
                          'صافي الربح',
                          '${state.totalProfit.toStringAsFixed(0)} ج',
                          const Color(0xFFE94560)),
                  ],
                ),
              );
            },
          ),

          // ✅ Month Picker
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

          // ✅ Payment Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _paymentFilterBtn('الكل', 'all'),
                const SizedBox(width: 8),
                _paymentFilterBtn('كاش', 'cash'),
                const SizedBox(width: 8),
                _paymentFilterBtn('تحويل', 'transfer'),
                const SizedBox(width: 8),
                _paymentFilterBtn('شيك', 'check'),
                const SizedBox(width: 8),
                _paymentFilterBtn('تقسيط', 'installment'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ✅ Sales List
          Expanded(
            child: BlocConsumer<SalesCubit, SalesState>(
              listener: (context, state) {
                if (state is SalesOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green),
                  );
                } else if (state is SalesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFE94560)));
                }
                if (state is SalesLoaded) {
                  final filteredSales = _filterPayment == 'all'
                      ? state.sales
                      : state.sales
                          .where((s) => s.paymentType == _filterPayment)
                          .toList();

                  if (filteredSales.isEmpty) {
                    return const Center(
                      child: Text('لا توجد مبيعات',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) =>
                        _saleCard(filteredSales[index]),
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

  Widget _paymentFilterBtn(String label, String value) {
    final isSelected = _filterPayment == value;
    final colors = {
      'all': Colors.grey,
      'cash': Colors.green,
      'transfer': Colors.blue,
      'check': Colors.orange,
      'installment': Colors.purple,
    };
    final color = colors[value] ?? Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _filterPayment = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
          context.read<SalesCubit>().loadSalesByMonth(_selectedMonth);
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

  Widget _saleCard(Sale sale) {
    final authCubit = context.read<AuthCubit>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (authCubit.isAdmin)
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => context
                          .read<SalesCubit>()
                          .deleteSale(sale.id!, sale.carId),
                    ),
                  if (sale.paymentType == 'installment')
                    IconButton(
                      icon: const Icon(Icons.list_alt,
                          color: Colors.purple, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => InstallmentsScreen(sale: sale)),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.print, color: Colors.teal, size: 20),
                    onPressed: () => _printInvoice(sale),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _paymentColor(sale.paymentType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _paymentLabel(sale.paymentType),
                  style: TextStyle(
                      color: _paymentColor(sale.paymentType), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سعر البيع: ${sale.salePrice.toStringAsFixed(0)} ج',
                      style:
                          const TextStyle(color: Colors.green, fontSize: 14)),
                  if (authCubit.isAdmin)
                    Text('الربح: ${sale.profit.toStringAsFixed(0)} ج',
                        style: const TextStyle(
                            color: Color(0xFFE94560), fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('موظف: ${sale.employeeName ?? '-'}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                  Text(sale.saleDate?.substring(0, 10) ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _paymentColor(String? type) {
    switch (type) {
      case 'cash':
        return Colors.green;
      case 'transfer':
        return Colors.blue;
      case 'check':
        return Colors.orange;
      case 'installment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _paymentLabel(String? type) {
    switch (type) {
      case 'cash':
        return 'كاش';
      case 'transfer':
        return 'تحويل';
      case 'check':
        return 'شيك';
      case 'installment':
        return 'تقسيط';
      default:
        return '-';
    }
  }

  void _showAddSaleDialog() {
    final carsState = context.read<CarsCubit>().state;
    final customersState = context.read<CustomersCubit>().state;

    if (carsState is! CarsLoaded || carsState.cars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا توجد سيارات متاحة'), backgroundColor: Colors.red),
      );
      return;
    }

    Car? selectedCar = carsState.cars.first;
    Customer? selectedCustomer;
    String paymentType = 'cash';
    final salePriceController = TextEditingController(
        text: selectedCar?.expectedPrice.toString() ?? '');
    final notesController = TextEditingController();
    final installmentsCountController = TextEditingController(text: '3');
    final installmentAmountController = TextEditingController();
    DateTime firstInstallmentDate =
        DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text('تسجيل بيع جديد',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.right),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Car>(
                    value: selectedCar,
                    decoration: _inputDecoration('السيارة'),
                    dropdownColor: const Color(0xFF0F3460),
                    style: const TextStyle(color: Colors.white),
                    items: carsState.cars
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                  '${c.brand} ${c.model} - ${c.year ?? ''}'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        selectedCar = v;
                        salePriceController.text =
                            v?.expectedPrice.toString() ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (customersState is CustomersLoaded)
                    DropdownButtonFormField<Customer>(
                      value: selectedCustomer,
                      decoration: _inputDecoration('العميل (اختياري)'),
                      dropdownColor: const Color(0xFF0F3460),
                      style: const TextStyle(color: Colors.white),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('بدون عميل')),
                        ...customersState.customers
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c.name)))
                            .toList(),
                      ],
                      onChanged: (v) =>
                          setStateDialog(() => selectedCustomer = v),
                    ),
                  const SizedBox(height: 16),
                  MoneyTextField(
                      controller: salePriceController, label: 'سعر البيع'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: paymentType,
                    decoration: _inputDecoration('طريقة الدفع'),
                    dropdownColor: const Color(0xFF0F3460),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('كاش')),
                      DropdownMenuItem(value: 'transfer', child: Text('تحويل')),
                      DropdownMenuItem(value: 'check', child: Text('شيك')),
                      DropdownMenuItem(
                          value: 'installment', child: Text('تقسيط')),
                    ],
                    onChanged: (v) => setStateDialog(() => paymentType = v!),
                  ),
                  const SizedBox(height: 16),
                  if (paymentType == 'installment') ...[
                    const Divider(color: Colors.white24),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('بيانات التقسيط',
                          style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: installmentsCountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('عدد الأقساط'),
                            onChanged: (v) {
                              final count = int.tryParse(v) ?? 1;
                              final price =
                                  double.tryParse(salePriceController.text) ??
                                      0;
                              if (count > 0) {
                                setStateDialog(() {
                                  installmentAmountController.text =
                                      (price / count).toStringAsFixed(0);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MoneyTextField(
                              controller: installmentAmountController,
                              label: 'قيمة كل قسط'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: firstInstallmentDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null)
                          setStateDialog(() => firstInstallmentDate = picked);
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
                                color: Colors.purple, size: 18),
                            Text(
                              'تاريخ أول قسط: ${firstInstallmentDate.toIso8601String().substring(0, 10)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white24),
                  ],
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
            TextButton(
              onPressed: () async {
                if (selectedCar == null) return;
                final salePrice =
                    double.tryParse(salePriceController.text) ?? 0;
                if (salePrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('برجاء إدخال سعر البيع'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (paymentType == 'installment') {
                  final count =
                      int.tryParse(installmentsCountController.text) ?? 0;
                  final amount =
                      double.tryParse(installmentAmountController.text) ?? 0;
                  if (count <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('برجاء إدخال عدد الأقساط'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('برجاء إدخال قيمة القسط'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                }
                final now = DateTime.now();
                final monthYear =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}';
                double profit = 0;
                if (selectedCar!.ownershipType == 'office') {
                  profit = salePrice - selectedCar!.purchasePrice;
                } else {
                  if (selectedCar!.commissionType == 'percentage') {
                    profit = (salePrice * selectedCar!.commissionValue / 100) +
                        selectedCar!.displayFees;
                  } else {
                    profit =
                        selectedCar!.commissionValue + selectedCar!.displayFees;
                  }
                }
                final sale = Sale(
                  carId: selectedCar!.id!,
                  customerId: selectedCustomer?.id,
                  salePrice: salePrice,
                  paymentType: paymentType,
                  totalAmount: salePrice,
                  paidAmount: paymentType != 'installment' ? salePrice : 0,
                  remainingAmount: paymentType != 'installment' ? 0 : salePrice,
                  profit: profit,
                  saleDate: now.toIso8601String(),
                  employeeName: context.read<AuthCubit>().currentUsername,
                  monthYear: monthYear,
                  notes: notesController.text,
                );
                await context.read<SalesCubit>().insertSale(sale);
                if (paymentType == 'installment') {
                  final count =
                      int.tryParse(installmentsCountController.text) ?? 1;
                  final amount =
                      double.tryParse(installmentAmountController.text) ??
                          (salePrice / count);
                  final salesState = context.read<SalesCubit>().state;
                  if (salesState is SalesLoaded &&
                      salesState.sales.isNotEmpty) {
                    final lastSale = salesState.sales.first;
                    final installments = List.generate(count, (i) {
                      final dueDate = DateTime(
                        firstInstallmentDate.year,
                        firstInstallmentDate.month + i,
                        firstInstallmentDate.day,
                      );
                      return Installment(
                        saleId: lastSale.id!,
                        amount: amount,
                        dueDate: dueDate.toIso8601String().substring(0, 10),
                      );
                    });
                    await context
                        .read<InstallmentsCubit>()
                        .insertInstallments(installments);
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('تسجيل البيع',
                  style: TextStyle(
                      color: Color(0xFFE94560), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printInvoice(Sale sale) async {
    final carsRepo = CarsRepository();
    final customersRepo = CustomersRepository();
    final installmentsRepo = InstallmentsRepository();
    final settingsState = context.read<SettingsCubit>().state;

    final car = await carsRepo.getCarById(sale.carId);
    if (car == null) return;

    Customer? customer;
    if (sale.customerId != null) {
      final customers = await customersRepo.getAllCustomers();
      customer = customers.firstWhere(
        (c) => c.id == sale.customerId,
        orElse: () => Customer(name: '-'),
      );
    }

    List<Installment> installments = [];
    if (sale.paymentType == 'installment') {
      installments = await installmentsRepo.getInstallmentsBySaleId(sale.id!);
    }

    String companyName = 'معرض السيارات';
    String companyPhone = '';
    String companyAddress = '';

    if (settingsState is SettingsLoaded) {
      companyName = settingsState.settings.companyName ?? companyName;
      companyPhone = settingsState.settings.phone ?? '';
      companyAddress = settingsState.settings.address ?? '';
    }

    await InvoicePdf.printInvoice(
      sale: sale,
      car: car,
      customer: customer,
      installments: installments,
      companyName: companyName,
      companyPhone: companyPhone,
      companyAddress: companyAddress,
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
