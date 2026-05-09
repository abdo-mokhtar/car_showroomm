import 'package:flutter/material.dart';
import '../../models/car.dart';
import 'add_edit_car_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/cars/cars_cubit.dart';

class CarDetailsScreen extends StatelessWidget {
  final Car car;
  const CarDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          '${car.brand} ${car.model}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditCarScreen(car: car),
                ),
              ).then((_) => context.read<CarsCubit>().loadAllCars());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _infoCard('المعلومات الأساسية', [
              _infoRow('الماركة', car.brand),
              _infoRow('الموديل', car.model),
              _infoRow('السنة', car.year?.toString() ?? '-'),
              _infoRow('اللون', car.color ?? '-'),
              _infoRow('رقم اللوحة', car.plateNumber ?? '-'),
              _infoRow('رقم الشاسيه', car.chassisNumber ?? '-'),
              _infoRow('الكيلومترات', '${car.kilometers} كم'),
              _infoRow('نوع الوقود', car.fuelType ?? '-'),
              _infoRow('ناقل الحركة', car.transmission ?? '-'),
            ]),
            const SizedBox(height: 16),
            _infoCard('التسعير', [
              _infoRow('سعر الشراء', '${car.purchasePrice} ج'),
              _infoRow('سعر البيع المتوقع', '${car.expectedPrice} ج'),
              _infoRow('نوع الملكية',
                  car.ownershipType == 'office' ? 'ملك المكتب' : 'معروضة'),
              _infoRow('الحالة', car.status == 'available' ? 'متاحة' : 'مباعة'),
            ]),
            if (car.ownershipType == 'consignment') ...[
              const SizedBox(height: 16),
              _infoCard('بيانات العرض', [
                _infoRow(
                    'نوع العمولة',
                    car.commissionType == 'percentage'
                        ? 'نسبة %'
                        : 'مبلغ ثابت'),
                _infoRow('قيمة العمولة', '${car.commissionValue}'),
                _infoRow('رسوم العرض', '${car.displayFees} ج'),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
