import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/customers/customers_cubit.dart';
import '../../cubits/customers/customers_state.dart';
import '../../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomersCubit>().loadAllCustomers();
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
        title: const Text('العملاء', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () => _showCustomerDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'بحث عن عميل...',
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
                  context.read<CustomersCubit>().loadAllCustomers();
                } else {
                  context.read<CustomersCubit>().searchCustomers(value);
                }
              },
            ),
          ),

          // ✅ Customers List
          Expanded(
            child: BlocConsumer<CustomersCubit, CustomersState>(
              listener: (context, state) {
                if (state is CustomersOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is CustomersError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is CustomersLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE94560)),
                  );
                }
                if (state is CustomersLoaded) {
                  if (state.customers.isEmpty) {
                    return const Center(
                      child: Text('لا يوجد عملاء',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {
                      return _customerCard(state.customers[index]);
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

  Widget _customerCard(Customer customer) {
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
                  onPressed: () => _confirmDelete(customer),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _showCustomerDialog(customer: customer),
                ),
              ],
            ),
          const Spacer(),
          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (customer.phone != null)
                Text(
                  customer.phone!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              if (customer.address != null)
                Text(
                  customer.address!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Avatar
          CircleAvatar(
            backgroundColor: const Color(0xFFE94560).withOpacity(0.2),
            child: const Icon(Icons.person, color: Color(0xFFE94560)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('تأكيد الحذف',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.right),
        content: Text(
          'هل أنت متأكد من حذف "${customer.name}"؟',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CustomersCubit>().deleteCustomer(customer.id!);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCustomerDialog({Customer? customer}) {
    final isEditing = customer != null;
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final addressController =
        TextEditingController(text: customer?.address ?? '');
    final notesController = TextEditingController(text: customer?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          isEditing ? 'تعديل عميل' : 'إضافة عميل',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('الاسم *'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('رقم الهاتف'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('العنوان'),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560)),
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final newCustomer = Customer(
                id: customer?.id,
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                address: addressController.text.trim(),
                notes: notesController.text.trim(),
              );
              if (isEditing) {
                context.read<CustomersCubit>().updateCustomer(newCustomer);
              } else {
                context.read<CustomersCubit>().insertCustomer(newCustomer);
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
