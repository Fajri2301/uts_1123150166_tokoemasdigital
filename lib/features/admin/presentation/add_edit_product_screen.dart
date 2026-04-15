import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:toko_emas_digital/common/widgets/custom_input_field.dart';
import 'package:toko_emas_digital/common/widgets/gold_button.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId; // Tambahkan parameter productId untuk mode edit
  const AddEditProductScreen({Key? key, this.productId}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.productId != null;

    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      appBar: CustomAppBar(
        title: isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
        showBackButton: isEdit, // Tampilkan tombol kembali jika dalam mode edit
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Image Placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.divider.toColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldAccent.toColor().withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: AppColors.goldAccent.toColor(), size: 40),
                  const SizedBox(height: 8),
                  Text('Upload Foto Produk', style: TextStyle(color: AppColors.textSecondary.toColor())),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildLabel('Nama Produk'),
            CustomInputField(hintText: 'Masukkan nama perhiasan', controller: _nameController),
            const SizedBox(height: 16),
            
            _buildLabel('Harga (Rp)'),
            CustomInputField(hintText: 'Contoh: 2500000', controller: _priceController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            
            _buildLabel('Kategori'),
            CustomInputField(hintText: 'Cincin / Kalung / Gelang', controller: _categoryController),
            const SizedBox(height: 16),
            
            _buildLabel('Deskripsi Produk'),
            CustomInputField(hintText: 'Masukkan deskripsi lengkap', controller: _descController),
            const SizedBox(height: 32),
            
            GoldButton(
              text: isEdit ? 'Update Produk' : 'Simpan Produk',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Produk berhasil diperbarui!' : 'Produk berhasil disimpan!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(color: AppColors.textPrimary.toColor(), fontWeight: FontWeight.bold),
      ),
    );
  }
}
