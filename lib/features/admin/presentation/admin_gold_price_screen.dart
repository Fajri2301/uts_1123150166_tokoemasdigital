import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/common/widgets/admin_scaffold.dart';
import 'package:toko_emas_digital/common/widgets/custom_input_field.dart';
import 'package:toko_emas_digital/common/widgets/gold_button.dart';
import '../services/admin_service.dart';

class AdminGoldPriceScreen extends StatefulWidget {
  const AdminGoldPriceScreen({Key? key}) : super(key: key);

  @override
  State<AdminGoldPriceScreen> createState() => _AdminGoldPriceScreenState();
}

class _AdminGoldPriceScreenState extends State<AdminGoldPriceScreen> {
  final AdminService _adminService = AdminService();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  double _currentPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentPrice();
  }

  Future<void> _loadCurrentPrice() async {
    final price = await _adminService.getCurrentGoldPrice();
    if (mounted) {
      setState(() {
        _currentPrice = price;
        _priceController.text = price > 0 ? price.toString() : '';
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga wajib diisi'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga harus berupa angka positif'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _adminService.updateGoldPrice(price);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harga emas berhasil diupdate'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadCurrentPrice();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update harga: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Update Harga Emas',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Price Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.padding),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Harga Emas Saat Ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentPrice > 0
                        ? CurrencyFormatter.formatRupiah(_currentPrice)
                        : 'Belum diatur',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'per gram',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Input Harga Baru
            const Text(
              'Harga Baru (per gram)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              hintText: 'Masukkan harga baru (Rp)',
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  )
                : GoldButton(
                    text: 'Update Harga Emas',
                    onPressed: _handleUpdate,
                  ),
          ],
        ),
      ),
    );
  }
}
