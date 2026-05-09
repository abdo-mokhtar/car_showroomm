import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/cars/cars_cubit.dart';
import '../../cubits/cars/cars_state.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../models/car.dart';
import 'add_edit_car_screen.dart';
import 'car_details_screen.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final _searchController = TextEditingController();
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    context.read<CarsCubit>().loadAllCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('السيارات', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditCarScreen()),
              ).then((_) => context.read<CarsCubit>().loadAllCars());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _filterBtn('الكل', 'all'),
                const SizedBox(width: 8),
                _filterBtn('متاحة', 'available'),
                const SizedBox(width: 8),
                _filterBtn('مباعة', 'sold'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'بحث عن سيارة...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF16213E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<CarsCubit>().loadAllCars();
                      } else {
                        context.read<CarsCubit>().searchCars(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<CarsCubit, CarsState>(
              listener: (context, state) {
                if (state is CarsOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green),
                  );
                } else if (state is CarsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is CarsLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFE94560)));
                }
                if (state is CarsLoaded) {
                  final cars = _filterCars(state.cars);
                  if (cars.isEmpty) {
                    return const Center(
                      child: Text('لا توجد سيارات',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) =>
                        _carCard(context, cars[index]),
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

  List<Car> _filterCars(List<Car> cars) {
    if (_filterStatus == 'available')
      return cars.where((c) => c.status == 'available').toList();
    if (_filterStatus == 'sold')
      return cars.where((c) => c.status == 'sold').toList();
    return cars;
  }

  Widget _filterBtn(String label, String value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = value);
        if (value == 'available') {
          context.read<CarsCubit>().loadAvailableCars();
        } else if (value == 'sold') {
          context.read<CarsCubit>().loadSoldCars();
        } else {
          context.read<CarsCubit>().loadAllCars();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE94560) : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _carCard(BuildContext context, Car car) {
    final isAvailable = car.status == 'available';
    final authCubit = context.read<AuthCubit>();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car)),
        ).then((_) => context.read<CarsCubit>().loadAllCars());
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ✅ صورة السيارة
            Expanded(
              child: FutureBuilder(
                future: context.read<CarsCubit>().loadCarImages(car.id!),
                builder: (context, snapshot) {
                  // ✅ Status Badge
                  final badge = Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAvailable ? 'متاحة' : 'مباعة',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  );

                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final imagePath = snapshot.data!.first.imagePath;
                    if (File(imagePath).existsSync()) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.file(
                              File(imagePath),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          badge,
                        ],
                      );
                    }
                  }

                  // ✅ لو مفيش صورة
                  return Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                          color: Color(0xFF0F3460),
                        ),
                        child: const Icon(Icons.directions_car,
                            color: Color(0xFFE94560), size: 50),
                      ),
                      badge,
                    ],
                  );
                },
              ),
            ),

            // ✅ Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${car.year ?? ''} | ${car.color ?? ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (authCubit.isAdmin)
                        Row(
                          children: [
                            InkWell(
                              onTap: () =>
                                  context.read<CarsCubit>().deleteCar(car.id!),
                              child: const Icon(Icons.delete,
                                  color: Colors.red, size: 18),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditCarScreen(car: car)),
                                ).then((_) =>
                                    context.read<CarsCubit>().loadAllCars());
                              },
                              child: const Icon(Icons.edit,
                                  color: Colors.blue, size: 18),
                            ),
                          ],
                        ),
                      Text(
                        '${car.expectedPrice.toStringAsFixed(0)} ج',
                        style: const TextStyle(
                            color: Color(0xFFE94560),
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
