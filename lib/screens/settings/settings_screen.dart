import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../cubits/settings/settings_state.dart';
import '../../models/company_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _currency = 'EGP';
  String _language = 'ar';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fillData(CompanySettings settings) {
    if (_loaded) return;
    _companyNameController.text = settings.companyName ?? '';
    _addressController.text = settings.address ?? '';
    _phoneController.text = settings.phone ?? '';
    _currency = settings.currency;
    _language = settings.language;
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)),
            );
          }
          if (state is SettingsLoaded) {
            _fillData(state.settings);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ✅ Company Info
                  _sectionTitle('بيانات الشركة'),
                  const SizedBox(height: 16),
                  _field(
                    controller: _companyNameController,
                    label: 'اسم المعرض',
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _addressController,
                    label: 'العنوان',
                  ),
                  const SizedBox(height: 24),

                  // ✅ Language
                  _sectionTitle('اللغة'),
                  const SizedBox(height: 16),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _radioBtn('العربية', 'ar'),
                        const SizedBox(width: 24),
                        _radioBtn('English', 'en'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Currency
                  _sectionTitle('العملة'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: _inputDecoration('العملة'),
                    dropdownColor: const Color(0xFF0F3460),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'EGP', child: Text('جنيه مصري')),
                      DropdownMenuItem(value: 'SAR', child: Text('ريال سعودي')),
                      DropdownMenuItem(
                          value: 'AED', child: Text('درهم إماراتي')),
                      DropdownMenuItem(
                          value: 'USD', child: Text('دولار أمريكي')),
                    ],
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                  const SizedBox(height: 32),

                  // ✅ Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final settings = state.settings.copyWith(
                          companyName: _companyNameController.text.trim(),
                          address: _addressController.text.trim(),
                          phone: _phoneController.text.trim(),
                          currency: _currency,
                          language: _language,
                        );
                        context.read<SettingsCubit>().updateSettings(settings);
                      },
                      child: const Text(
                        'حفظ الإعدادات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.circle, color: Color(0xFFE94560), size: 8),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      style: const TextStyle(color: Colors.white),
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
    );
  }

  Widget _radioBtn(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => _language = value),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: _language == value ? Colors.white : Colors.grey,
            ),
          ),
          Radio<String>(
            value: value,
            groupValue: _language,
            activeColor: const Color(0xFFE94560),
            onChanged: (v) => setState(() => _language = v!),
          ),
        ],
      ),
    );
  }
}
