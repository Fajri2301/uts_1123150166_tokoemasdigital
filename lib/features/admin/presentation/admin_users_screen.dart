import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import '../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      appBar: const CustomAppBar(title: 'Kelola User', showBackButton: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Tidak ada user.', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final userData = doc.data() as Map<String, dynamic>;
              final userId = doc.id;
              
              return _buildUserItem(context, userId, userData);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, String userId, Map<String, dynamic> userData) {
    final String name = userData['full_name'] ?? userData['name'] ?? 'No Name';
    final String email = userData['email'] ?? 'No Email';
    final String role = userData['role'] ?? 'user';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.divider.toColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.goldAccent.toColor().withOpacity(0.1),
            child: Icon(Icons.person, color: AppColors.goldAccent.toColor()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  email,
                  style: TextStyle(color: AppColors.textSecondary.toColor(), fontSize: 13),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: role == 'admin' ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: role == 'admin' ? Colors.redAccent : Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showChangePasswordDialog(context, userId, name),
                icon: Icon(Icons.lock_reset, color: AppColors.goldAccent.toColor()),
                tooltip: 'Ganti Password',
              ),
              IconButton(
                onPressed: () => _confirmDeleteUser(context, userId, name),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Hapus User',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, String userId, String name) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Ganti Password - $name', style: const TextStyle(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Password Baru',
            hintStyle: TextStyle(color: AppColors.textSecondary.toColor()),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent.toColor())),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              try {
                await _adminService.updateUserPassword(userId, controller.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diperbarui')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update password: $e')),
                  );
                }
              }
            },
            child: Text('Simpan', style: TextStyle(color: AppColors.goldAccent.toColor())),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, String userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
        content: Text('Apakah Anda yakin ingin menghapus user "$name"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.deleteUser(userId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus user: $e')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
