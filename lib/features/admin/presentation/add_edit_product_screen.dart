import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:toko_emas_digital/common/widgets/custom_input_field.dart';
import 'package:toko_emas_digital/common/widgets/gold_button.dart';
import 'package:toko_emas_digital/features/physical_gold/models/product_model.dart';
import 'package:toko_emas_digital/features/physical_gold/models/category_model.dart';
import '../services/admin_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late TextEditingController _weightController;
  late TextEditingController _karatController;
  late TextEditingController _imageUrlController;

  List<String> _categories = ['Lainnya'];
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  bool _isUrlMode = true;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    
    _selectedCategory = widget.product?.category ?? 'Lainnya';
    
    _weightController = TextEditingController(text: widget.product?.weight.toString() ?? '');
    _karatController = TextEditingController(text: widget.product?.karat.toString() ?? '24');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');

    if (widget.product?.imageUrl.startsWith('data:image') ?? false) {
      _isUrlMode = false;
    }

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categories').get();
      if (snapshot.docs.isNotEmpty) {
        final List<String> fetchedCategories = snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc).name)
            .toList();
        
        setState(() {
          _categories = fetchedCategories;
          if (!_categories.contains(_selectedCategory)) {
            _categories.add(_selectedCategory);
          }
          _isLoadingCategories = false;
        });
      } else {
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        
        // Convert to base64
        final bytes = await _imageFile!.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        _imageUrlController.text = base64Image;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _weightController.dispose();
    _karatController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final productData = {
      'name': _nameController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'description': _descController.text,
      'category': _selectedCategory,
      'weight': int.tryParse(_weightController.text) ?? 0,
      'karat': int.tryParse(_karatController.text) ?? 24,
      'image_url': _imageUrlController.text,
      'is_available': true,
      'seller_id': 'admin', // Default admin id
      'updated_at': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.product != null) {
        await _adminService.updateProduct(widget.product!.id, productData);
      } else {
        productData['created_at'] = FieldValue.serverTimestamp();
        await _adminService.addProduct(productData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product != null ? 'Produk diperbarui!' : 'Produk ditambahkan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      appBar: CustomAppBar(
        title: isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
        showBackButton: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Foto Produk'),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('URL'),
                            selected: _isUrlMode,
                            onSelected: (val) => setState(() => _isUrlMode = val),
                            selectedColor: const Color(0xFFFFD700).withOpacity(0.3),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('File'),
                            selected: !_isUrlMode,
                            onSelected: (val) => setState(() => _isUrlMode = !val),
                            selectedColor: const Color(0xFFFFD700).withOpacity(0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (_isUrlMode)
                    CustomInputField(
                      hintText: 'https://...', 
                      controller: _imageUrlController,
                    )
                  else
                    Column(
                      children: [
                        if (_imageUrlController.text.isNotEmpty)
                          Container(
                            height: 150,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _imageUrlController.text.startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(_imageUrlController.text.split(',').last),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.image_not_supported, size: 50),
                                  ),
                            ),
                          ),
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFFD700)),
                              color: const Color(0xFFFFD700).withOpacity(0.1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload, color: Color(0xFFB8860B)),
                                SizedBox(width: 8),
                                Text(
                                  'Pilih Foto dari Galeri',
                                  style: TextStyle(color: Color(0xFFB8860B), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Nama Produk'),
                  CustomInputField(hintText: 'Contoh: Kalung Emas 24K', controller: _nameController),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Harga (Rp)'),
                            CustomInputField(hintText: '2500000', controller: _priceController, keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Kategori'),
                            _isLoadingCategories 
                              ? const SizedBox(
                                  height: 50, 
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2))
                                )
                              : DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCategory = newValue;
                                      });
                                    }
                                  },
                                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.textSecondary.toColor().withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.textSecondary.toColor().withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFFFD700)),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Berat (gram)'),
                            CustomInputField(hintText: '5', controller: _weightController, keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Kadar (Karat)'),
                            CustomInputField(hintText: '24', controller: _karatController, keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Deskripsi Produk'),
                  CustomInputField(
                    hintText: 'Masukkan deskripsi lengkap', 
                    controller: _descController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  
                  GoldButton(
                    text: isEdit ? 'Update Produk' : 'Simpan Produk',
                    onPressed: _saveProduct,
                  ),
                ],
              ),
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
