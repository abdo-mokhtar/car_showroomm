import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../models/user.dart';
import '../../repositories/users_repository.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _usersRepository = UsersRepository();
  List<User> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await _usersRepository.getAllUsers();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  // ✅ إضافة / تعديل User
  void _showUserDialog({User? user}) {
    final isEditing = user != null;
    final usernameController =
        TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? 'employee';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: Text(
            isEditing ? 'تعديل مستخدم' : 'إضافة مستخدم',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username
                TextField(
                  controller: usernameController,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('اسم المستخدم'),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    isEditing
                        ? 'كلمة المرور الجديدة (اتركها فاضية لو مش عايز تغير)'
                        : 'كلمة المرور',
                  ),
                ),
                const SizedBox(height: 16),

                // Role
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFF0F3460),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('الصلاحية'),
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('مدير'),
                    ),
                    DropdownMenuItem(
                      value: 'employee',
                      child: Text('موظف'),
                    ),
                  ],
                  onChanged: (v) => setStateDialog(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
              ),
              onPressed: () async {
                if (usernameController.text.trim().isEmpty) return;

                if (isEditing) {
                  // ✅ تعديل
                  final updatedUser = user.copyWith(
                    username: usernameController.text.trim(),
                    password: passwordController.text.isNotEmpty
                        ? passwordController.text.trim()
                        : user.password,
                    role: selectedRole,
                  );

                  // لو الباسورد فاضي نحتفظ بالقديم
                  if (passwordController.text.isEmpty) {
                    await _usersRepository
                        .updateUserWithoutPassword(updatedUser);
                  } else {
                    await _usersRepository.updateUser(updatedUser);
                  }
                } else {
                  // ✅ إضافة
                  if (passwordController.text.trim().isEmpty) return;
                  final newUser = User(
                    username: usernameController.text.trim(),
                    password: passwordController.text.trim(),
                    role: selectedRole,
                  );
                  await _usersRepository.insertUser(newUser);
                }

                if (context.mounted) Navigator.pop(context);
                await _loadUsers();
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

  // ✅ تغيير Password فقط
  void _showChangePasswordDialog(User user) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          'تغيير كلمة مرور: ${user.username}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('كلمة المرور الجديدة'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('تأكيد كلمة المرور'),
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
              backgroundColor: const Color(0xFFE94560),
            ),
            onPressed: () async {
              if (passwordController.text.isEmpty) return;
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمتا المرور غير متطابقتين'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              await _usersRepository.updateUser(
                user.copyWith(password: passwordController.text.trim()),
              );
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تغيير كلمة المرور بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'تغيير',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ حذف User
  void _deleteUser(User user) {
    final currentUser = context.read<AuthCubit>().currentUser;

    // منع حذف نفسه
    if (user.id == currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكنك حذف حسابك الحالي'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل أنت متأكد من حذف "${user.username}"؟',
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
            onPressed: () async {
              await _usersRepository.deleteUser(user.id!);
              if (context.mounted) Navigator.pop(context);
              await _loadUsers();
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () => _showUserDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isCurrentUser =
                    user.id == context.read<AuthCubit>().currentUserId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(16),
                    border: isCurrentUser
                        ? Border.all(
                            color: const Color(0xFFE94560).withOpacity(0.5))
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Actions
                      Row(
                        children: [
                          // حذف
                          if (!isCurrentUser)
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () => _deleteUser(user),
                            ),
                          // تغيير باسورد
                          IconButton(
                            icon: const Icon(Icons.lock_reset,
                                color: Colors.orange, size: 20),
                            onPressed: () => _showChangePasswordDialog(user),
                          ),
                          // تعديل
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            onPressed: () => _showUserDialog(user: user),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              if (isCurrentUser)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE94560)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'أنت',
                                    style: TextStyle(
                                      color: Color(0xFFE94560),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              Text(
                                user.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: user.isAdmin
                                  ? const Color(0xFFE94560).withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.isAdmin ? 'مدير' : 'موظف',
                              style: TextStyle(
                                color: user.isAdmin
                                    ? const Color(0xFFE94560)
                                    : Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Avatar
                      CircleAvatar(
                        backgroundColor: user.isAdmin
                            ? const Color(0xFFE94560).withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        child: Icon(
                          user.isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          color: user.isAdmin
                              ? const Color(0xFFE94560)
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
