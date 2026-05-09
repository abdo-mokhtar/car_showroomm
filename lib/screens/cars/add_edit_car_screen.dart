import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/cars/cars_cubit.dart';
import '../../cubits/owners/owners_cubit.dart';
import '../../cubits/owners/owners_state.dart';
import '../../models/car.dart';
import '../../widgets/money_text_field.dart';
import '../../core/utils/image_helper.dart';

class AddEditCarScreen extends StatefulWidget {
  final Car? car;
  const AddEditCarScreen({super.key, this.car});

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _chassisController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _expectedPriceController = TextEditingController();
  final _kilometersController = TextEditingController();
  final _commissionController = TextEditingController();
  final _displayFeesController = TextEditingController();
  final _notesController = TextEditingController();

  String _ownershipType = 'office';
  String _carCondition = 'used';
  String _fuelType = 'بنزين';
  String _transmission = 'أوتوماتيك';
  String _commissionType = 'fixed';
  int? _selectedOwnerId;
  List<String> _images = [];

  bool get isEditing => widget.car != null;

  @override
  void initState() {
    super.initState();
    context.read<OwnersCubit>().loadAllOwners();
    if (isEditing) {
      _fillData();
      _loadExistingImages();
    }
  }

  Future<void> _loadExistingImages() async {
    final images =
        await context.read<CarsCubit>().loadCarImages(widget.car!.id!);
    setState(() {
      _images = images.map((e) => e.imagePath).toList();
    });
  }

  void _fillData() {
    final car = widget.car!;
    _brandController.text = car.brand;
    _modelController.text = car.model;
    _yearController.text = car.year?.toString() ?? '';
    _colorController.text = car.color ?? '';
    _plateController.text = car.plateNumber ?? '';
    _chassisController.text = car.chassisNumber ?? '';
    _purchasePriceController.text = car.purchasePrice.toString();
    _expectedPriceController.text = car.expectedPrice.toString();
    _kilometersController.text = car.kilometers.toString();
    _commissionController.text = car.commissionValue.toString();
    _displayFeesController.text = car.displayFees.toString();
    _ownershipType = car.ownershipType;
    _carCondition = car.carCondition ?? 'used';
    _fuelType = car.fuelType ?? 'بنزين';
    _transmission = car.transmission ?? 'أوتوماتيك';
    _commissionType = car.commissionType ?? 'fixed';
    _selectedOwnerId = car.ownerId;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _chassisController.dispose();
    _purchasePriceController.dispose();
    _expectedPriceController.dispose();
    _kilometersController.dispose();
    _commissionController.dispose();
    _displayFeesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final car = Car(
      id: widget.car?.id,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text),
      color: _colorController.text.trim(),
      plateNumber: _plateController.text.trim(),
      chassisNumber: _chassisController.text.trim(),
      purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
      expectedPrice: double.tryParse(_expectedPriceController.text) ?? 0,
      ownershipType: _ownershipType,
      status: widget.car?.status ?? 'available',
      kilometers: int.tryParse(_kilometersController.text) ?? 0,
      fuelType: _fuelType,
      transmission: _transmission,
      carCondition: _carCondition,
      ownerId: _ownershipType == 'consignment' ? _selectedOwnerId : null,
      commissionType: _ownershipType == 'consignment' ? _commissionType : null,
      commissionValue: _ownershipType == 'consignment'
          ? double.tryParse(_commissionController.text) ?? 0
          : 0,
      displayFees: _ownershipType == 'consignment'
          ? double.tryParse(_displayFeesController.text) ?? 0
          : 0,
      monthYear: monthYear,
    );

    if (isEditing) {
      // ✅ تعديل السيارة
      await context.read<CarsCubit>().updateCar(car);
      // ✅ احذف الصور القديمة وحط الجديدة
      // ignore: use_build_context_synchronously
      await context.read<CarsCubit>().deleteCarImages(car.id!);
      if (_images.isNotEmpty) {
        await context.read<CarsCubit>().saveCarImages(car.id!, _images);
      }
    } else {
      // ✅ إضافة سيارة جديدة وجيب الـ id
      final carId = await context.read<CarsCubit>().insertCarAndGetId(car);
      if (_images.isNotEmpty && carId > 0) {
        await context.read<CarsCubit>().saveCarImages(carId, _images);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          isEditing ? 'تعديل سيارة' : 'إضافة سيارة',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'حفظ',
              style: TextStyle(
                color: Color(0xFFE94560),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ✅ Basic Info
              _sectionTitle('المعلومات الأساسية'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _brandController,
                      label: 'الماركة *',
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _field(
                      controller: _modelController,
                      label: 'الموديل *',
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _field(
                      controller: _yearController,
                      label: 'السنة',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child:
                          _field(controller: _colorController, label: 'اللون')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _field(
                          controller: _plateController, label: 'رقم اللوحة')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _field(
                          controller: _chassisController,
                          label: 'رقم الشاسيه')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _kilometersController,
                      label: 'الكيلومترات',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dropdown(
                      label: 'نوع الوقود',
                      value: _fuelType,
                      items: ['بنزين', 'ديزل', 'كهربائي', 'هايبرد'],
                      onChanged: (v) => setState(() => _fuelType = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dropdown(
                      label: 'ناقل الحركة',
                      value: _transmission,
                      items: ['أوتوماتيك', 'مانيوال'],
                      onChanged: (v) => setState(() => _transmission = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ Pricing
              _sectionTitle('التسعير'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MoneyTextField(
                      controller: _purchasePriceController,
                      label: 'سعر الشراء',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MoneyTextField(
                      controller: _expectedPriceController,
                      label: 'سعر البيع المتوقع',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dropdown(
                      label: 'الحالة',
                      value: _carCondition,
                      items: ['new', 'used'],
                      itemLabels: ['جديدة', 'مستعملة'],
                      onChanged: (v) => setState(() => _carCondition = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ Ownership
              _sectionTitle('نوع الملكية'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _radioBtn('معروضة', 'consignment'),
                  const SizedBox(width: 24),
                  _radioBtn('ملك المكتب', 'office'),
                ],
              ),

              if (_ownershipType == 'consignment') ...[
                const SizedBox(height: 16),
                BlocBuilder<OwnersCubit, OwnersState>(
                  builder: (context, state) {
                    if (state is! OwnersLoaded) return const SizedBox();
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedOwnerId,
                            decoration: _inputDecoration('المالك'),
                            dropdownColor: const Color(0xFF0F3460),
                            style: const TextStyle(color: Colors.white),
                            items: state.owners
                                .map((o) => DropdownMenuItem(
                                    value: o.id, child: Text(o.name)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedOwnerId = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _dropdown(
                            label: 'نوع العمولة',
                            value: _commissionType,
                            items: ['fixed', 'percentage'],
                            itemLabels: ['مبلغ ثابت', 'نسبة %'],
                            onChanged: (v) =>
                                setState(() => _commissionType = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MoneyTextField(
                            controller: _commissionController,
                            label: _commissionType == 'percentage'
                                ? 'نسبة العمولة %'
                                : 'قيمة العمولة',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MoneyTextField(
                            controller: _displayFeesController,
                            label: 'رسوم العرض',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),

              // ✅ صور السيارة
              _sectionTitle('صور السيارة'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final paths =
                                await ImageHelper.pickMultipleImages();
                            if (paths.isNotEmpty) {
                              setState(() => _images.addAll(paths));
                            }
                          },
                          icon: const Icon(Icons.add_photo_alternate,
                              color: Color(0xFFE94560)),
                          label: const Text('إضافة صور',
                              style: TextStyle(color: Color(0xFFE94560))),
                        ),
                        Text(
                          '${_images.length} صورة',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(_images[index])),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 12,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _images.removeAt(index)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text('لا توجد صور',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Notes
              _sectionTitle('ملاحظات'),
              const SizedBox(height: 16),
              _field(
                  controller: _notesController, label: 'ملاحظات', maxLines: 3),
              const SizedBox(height: 32),

              // ✅ Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEditing ? 'تحديث السيارة' : 'إضافة السيارة',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        const Icon(Icons.circle, color: Color(0xFFE94560), size: 8),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF16213E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.red),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    List<String>? itemLabels,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      dropdownColor: const Color(0xFF0F3460),
      style: const TextStyle(color: Colors.white),
      items: items.asMap().entries.map((e) {
        return DropdownMenuItem(
          value: e.value,
          child: Text(itemLabels?[e.key] ?? e.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _radioBtn(String label, String value) {
    final isSelected = _ownershipType == value;
    return GestureDetector(
      onTap: () => setState(() => _ownershipType = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _ownershipType,
            activeColor: const Color(0xFFE94560),
            onChanged: (v) => setState(() => _ownershipType = v!),
          ),
          Text(label,
              style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
        ],
      ),
    );
  }
}
