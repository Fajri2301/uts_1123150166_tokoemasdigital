import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:toko_emas_digital/features/physical_gold/models/category_model.dart';
import '../services/admin_service.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      appBar: const CustomAppBar(title: 'Kelola Kategori', showBackButton: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Tidak ada kategori.', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final category = CategoryModel.fromFirestore(doc);
              
              return _buildCategoryItem(context, category);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.goldAccent.toColor(),
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
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
            child: Icon(Icons.category_outlined, color: AppColors.goldAccent.toColor()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showCategoryDialog(context, category: category),
                icon: Icon(Icons.edit, color: AppColors.goldAccent.toColor()),
              ),
              IconButton(
                onPressed: () => _confirmDeleteCategory(context, category),
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final controller = TextEditingController(text: category?.name ?? '');
    final bool isEdit = category != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nama Kategori',
            hintStyle: TextStyle(color: AppColors.textSecondary.toColor()),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.goldAccent.toColor())),
          ),
          autofocus: true,
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
                if (isEdit) {
                  await _adminService.updateCategory(category.id, controller.text);
                } else {
                  await _adminService.addCategory(controller.text);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kategori berhasil ${isEdit ? 'diperbarui' : 'ditambahkan'}')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
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

  void _confirmDeleteCategory(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus Kategori', style: TextStyle(color: Colors.white)),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.deleteCategory(category.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kategori berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus kategori: $e')),
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
