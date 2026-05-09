import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../models/sale.dart';
import '../../models/installment.dart';
import '../../repositories/customers_repository.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/installments_repository.dart';
import '../../repositories/cars_repository.dart';
import '../../models/car.dart';

class CustomerPortalScreen extends StatefulWidget {
  const CustomerPortalScreen({super.key});

  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  final _phoneController = TextEditingController();
  final _customersRepo = CustomersRepository();
  final _salesRepo = SalesRepository();
  final _installmentsRepo = InstallmentsRepository();
  final _carsRepo = CarsRepository();

  Customer? _customer;
  List<Map<String, dynamic>> _salesData = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title:
            const Text('بوابة العملاء', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _customer == null ? _buildLoginView() : _buildCustomerView(),
    );
  }

  // ✅ شاشة الدخول برقم الهاتف
  Widget _buildLoginView() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE94560).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.person, color: Color(0xFFE94560), size: 35),
            ),
            const SizedBox(height: 20),
            const Text(
              'بوابة العملاء',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل رقم هاتفك لعرض بياناتك',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: '01XXXXXXXXX',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF0F3460),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                errorText: _error,
                errorStyle: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('دخول',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ شاشة بيانات العميل
  Widget _buildCustomerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ بيانات العميل
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFFE94560).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _customer = null;
                    _salesData = [];
                    _phoneController.clear();
                  }),
                  child:
                      const Text('خروج', style: TextStyle(color: Colors.red)),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _customer!.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        if (_customer!.phone != null)
                          Text(_customer!.phone!,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE94560).withOpacity(0.2),
                      radius: 25,
                      child: const Icon(Icons.person,
                          color: Color(0xFFE94560), size: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ✅ المبيعات والأقساط
          if (_salesData.isEmpty)
            const Center(
                child: Text('لا توجد مبيعات',
                    style: TextStyle(color: Colors.grey)))
          else
            ..._salesData.map((data) => _buildSaleCard(data)),
        ],
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> data) {
    final sale = data['sale'] as Sale;
    final car = data['car'] as Car?;
    final installments = data['installments'] as List<Installment>;
    final paid = installments.where((i) => i.paid).length;
    final total = installments.length;
    final overdue = installments.where((i) => i.isOverdue).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ✅ Car Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Payment Badge
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      car != null
                          ? '${car.brand} ${car.model} ${car.year ?? ''}'
                          : 'سيارة',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      sale.saleDate?.substring(0, 10) ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const Icon(Icons.directions_car,
                    color: Color(0xFFE94560), size: 32),
              ],
            ),
          ),

          // ✅ Price Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF0F3460).withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoItem('إجمالي السعر',
                    '${sale.salePrice.toStringAsFixed(0)} ج', Colors.white),
                _infoItem('المدفوع', '${sale.paidAmount.toStringAsFixed(0)} ج',
                    Colors.green),
                _infoItem(
                    'المتبقي',
                    '${sale.remainingAmount.toStringAsFixed(0)} ج',
                    Colors.orange),
              ],
            ),
          ),

          // ✅ Installments
          if (installments.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (overdue > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$overdue متأخر',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 11),
                          ),
                        ),
                      Text(
                        'الأقساط ($paid/$total)',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...installments.map((inst) => _buildInstallmentRow(inst)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstallmentRow(Installment installment) {
    final isOverdue = installment.isOverdue;
    final isPaid = installment.paid;
    Color color = isPaid
        ? Colors.green
        : isOverdue
            ? Colors.red
            : Colors.orange;
    String status = isPaid
        ? '✓ مدفوع'
        : isOverdue
            ? '! متأخر'
            : 'في الانتظار';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Text(status, style: TextStyle(color: color, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              Text(
                installment.dueDate.substring(0, 10),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Text(
            '${installment.amount.toStringAsFixed(0)} ج',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'برجاء إدخال رقم الهاتف');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final customers = await _customersRepo.getAllCustomers();
      final customer = customers.firstWhere(
        (c) => c.phone == phone,
        orElse: () => throw Exception('not found'),
      );

      final sales = await _salesRepo.getSalesByCustomer(customer.id!);
      final salesData = <Map<String, dynamic>>[];

      for (final sale in sales) {
        final car = await _carsRepo.getCarById(sale.carId);
        final installments = sale.paymentType == 'installment'
            ? await _installmentsRepo.getInstallmentsBySaleId(sale.id!)
            : <Installment>[];

        salesData.add({
          'sale': sale,
          'car': car,
          'installments': installments,
        });
      }

      setState(() {
        _customer = customer;
        _salesData = salesData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'رقم الهاتف غير موجود';
      });
    }
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
}
