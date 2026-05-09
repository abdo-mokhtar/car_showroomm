import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/owners/owners_cubit.dart';
import '../../cubits/owners/owners_state.dart';
import '../../models/owner.dart';

class OwnersScreen extends StatefulWidget {
  const OwnersScreen({super.key});

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OwnersCubit>().loadAllOwners();
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
        title: const Text('المالكين', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () => _showOwnerDialog(),
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
                hintText: 'بحث عن مالك...',
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
                  context.read<OwnersCubit>().loadAllOwners();
                } else {
                  context.read<OwnersCubit>().searchOwners(value);
                }
              },
            ),
          ),

          // ✅ Owners List
          Expanded(
            child: BlocConsumer<OwnersCubit, OwnersState>(
              listener: (context, state) {
                if (state is OwnersOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is OwnersError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OwnersLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE94560)),
                  );
                }
                if (state is OwnersLoaded) {
                  if (state.owners.isEmpty) {
                    return const Center(
                      child: Text('لا يوجد مالكين',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.owners.length,
                    itemBuilder: (context, index) {
                      return _ownerCard(state.owners[index]);
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

  Widget _ownerCard(Owner owner) {
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
                  onPressed: () => _confirmDelete(owner),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _showOwnerDialog(owner: owner),
                ),
              ],
            ),
          const Spacer(),
          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                owner.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (owner.phone != null)
                Text(
                  owner.phone!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              if (owner.nationalId != null)
                Text(
                  'رقم الهوية: ${owner.nationalId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Avatar
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: const Icon(Icons.person_outline, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Owner owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('تأكيد الحذف',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.right),
        content: Text(
          'هل أنت متأكد من حذف "${owner.name}"؟',
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
              context.read<OwnersCubit>().deleteOwner(owner.id!);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOwnerDialog({Owner? owner}) {
    final isEditing = owner != null;
    final nameController = TextEditingController(text: owner?.name ?? '');
    final phoneController = TextEditingController(text: owner?.phone ?? '');
    final nationalIdController =
        TextEditingController(text: owner?.nationalId ?? '');
    final notesController = TextEditingController(text: owner?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          isEditing ? 'تعديل مالك' : 'إضافة مالك',
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
                controller: nationalIdController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('رقم الهوية'),
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
              final newOwner = Owner(
                id: owner?.id,
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                nationalId: nationalIdController.text.trim(),
                notes: notesController.text.trim(),
              );
              if (isEditing) {
                context.read<OwnersCubit>().updateOwner(newOwner);
              } else {
                context.read<OwnersCubit>().insertOwner(newOwner);
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
