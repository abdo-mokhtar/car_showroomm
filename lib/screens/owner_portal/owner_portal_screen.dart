import 'package:flutter/material.dart';
import '../../models/owner.dart';
import '../../models/car.dart';
import '../../repositories/owners_repository.dart';
import '../../repositories/cars_repository.dart';

class OwnerPortalScreen extends StatefulWidget {
  const OwnerPortalScreen({super.key});

  @override
  State<OwnerPortalScreen> createState() => _OwnerPortalScreenState();
}

class _OwnerPortalScreenState extends State<OwnerPortalScreen> {
  final _phoneController = TextEditingController();
  final _ownersRepo = OwnersRepository();
  final _carsRepo = CarsRepository();

  Owner? _owner;
  List<Car> _cars = [];
  bool _loading = false;
  String? _error;

  double get _totalCommission =>
      _cars.where((c) => c.status == 'sold').fold(0.0, (sum, car) {
        if (car.commissionType == 'percentage') {
          return sum +
              (car.expectedPrice * car.commissionValue / 100) +
              car.displayFees;
        }
        return sum + car.commissionValue + car.displayFees;
      });

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
            const Text('بوابة الملاك', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _owner == null ? _buildLoginView() : _buildOwnerView(),
    );
  }

  Widget _buildLoginView() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline,
                  color: Colors.blue, size: 35),
            ),
            const SizedBox(height: 20),
            const Text(
              'بوابة الملاك',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل رقم هاتفك لعرض سياراتك',
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
                  backgroundColor: Colors.blue,
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

  Widget _buildOwnerView() {
    final availableCars = _cars.where((c) => c.status == 'available').length;
    final soldCars = _cars.where((c) => c.status == 'sold').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ Owner Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _owner = null;
                    _cars = [];
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
                          _owner!.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        if (_owner!.phone != null)
                          Text(_owner!.phone!,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      radius: 25,
                      child: const Icon(Icons.person_outline,
                          color: Colors.blue, size: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Stats
          Row(
            children: [
              _statCard('سيارات متاحة', availableCars.toString(), Colors.green),
              const SizedBox(width: 12),
              _statCard('سيارات مباعة', soldCars.toString(), Colors.blue),
              const SizedBox(width: 12),
              _statCard(
                  'إجمالي العمولات',
                  '${_totalCommission.toStringAsFixed(0)} ج',
                  const Color(0xFFE94560)),
            ],
          ),
          const SizedBox(height: 24),

          // ✅ Cars List
          const Text(
            'سياراتك في المعرض',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_cars.isEmpty)
            const Center(
                child: Text('لا توجد سيارات',
                    style: TextStyle(color: Colors.grey)))
          else
            ..._cars.map((car) => _buildCarCard(car)),
        ],
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    final isAvailable = car.status == 'available';
    double commission = 0;
    if (car.commissionType == 'percentage') {
      commission =
          (car.expectedPrice * car.commissionValue / 100) + car.displayFees;
    } else {
      commission = car.commissionValue + car.displayFees;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable
              ? Colors.green.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAvailable ? 'متاحة' : 'مباعة ✓',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${car.brand} ${car.model} ${car.year ?? ''}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العمولة: ${commission.toStringAsFixed(0)} ج',
                    style: TextStyle(
                      color:
                          isAvailable ? Colors.grey : const Color(0xFFE94560),
                      fontSize: 13,
                      fontWeight:
                          isAvailable ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  Text(
                    car.commissionType == 'percentage'
                        ? 'نسبة ${car.commissionValue}% + رسوم ${car.displayFees.toStringAsFixed(0)} ج'
                        : 'مبلغ ثابت + رسوم ${car.displayFees.toStringAsFixed(0)} ج',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'سعر البيع: ${car.expectedPrice.toStringAsFixed(0)} ج',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  Text(
                    '${car.color ?? ''} | ${car.year ?? ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
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
      final owners = await _ownersRepo.getAllOwners();
      final owner = owners.firstWhere(
        (o) => o.phone == phone,
        orElse: () => throw Exception('not found'),
      );

      final cars = await _carsRepo.getCarsByOwnerId(owner.id!);

      setState(() {
        _owner = owner;
        _cars = cars;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'رقم الهاتف غير موجود';
      });
    }
  }
}
