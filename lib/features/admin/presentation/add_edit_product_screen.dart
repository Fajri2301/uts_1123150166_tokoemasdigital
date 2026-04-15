import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:toko_emas_digital/common/widgets/custom_input_field.dart';
import 'package:toko_emas_digital/common/widgets/gold_button.dart';
import 'package:toko_emas_digital/features/digital_gold/models/transaction_model.dart'; // Import model

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // Menggunakan ProductModel agar data lengkap terbaca
  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data lama jika dalam mode edit
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      appBar: CustomAppBar(
        title: isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
        showBackButton: isEdit,
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
                  Text(
                    isEdit ? 'Ubah Foto Produk' : 'Upload Foto Produk',
                    style: TextStyle(color: AppColors.textSecondary.toColor()),
                  ),
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
                  SnackBar(content: Text(isEdit ? 'Perubahan berhasil disimpan!' : 'Produk baru berhasil ditambahkan!')),
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
