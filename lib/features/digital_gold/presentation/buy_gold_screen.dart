import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/app_field.dart';
import '../services/digital_gold_service.dart';

class BuyGoldScreen extends StatefulWidget {
  const BuyGoldScreen({super.key});

  @override
  State<BuyGoldScreen> createState() => _BuyGoldScreenState();
}

class _BuyGoldScreenState extends State<BuyGoldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gramController = TextEditingController();
  final _digitalGoldService = DigitalGoldService();
  bool _isLoading = false;
  String? _errorMessage;
  double _currentGoldPrice = 0.0;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadGoldPrice();
  }

  Future<void> _loadGoldPrice() async {
    final price = await _digitalGoldService.getCurrentGoldPrice();
    if (mounted) {
      setState(() {
        _currentGoldPrice = price;
      });
    }
  }

  void _calculateTotal(String value) {
    double grams = double.tryParse(value) ?? 0.0;
    setState(() {
      _totalPrice = grams * _currentGoldPrice;
    });
  }

  Future<void> _handleBuyGold() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      double grams = double.parse(_gramController.text);
      bool success = await _digitalGoldService.buyGold(
        userId: user.uid,
        gramAmount: grams,
        pricePerGram: _currentGoldPrice,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil membeli emas!'),
            backgroundColor: AppColors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Beli Emas Digital',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gold Price Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.shadowSoft,
                  border: Border.all(color: AppColors.line2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga Emas Saat Ini',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(_currentGoldPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Gram Input
              AppField(
                label: 'Jumlah Emas (gram)',
                hint: '0.00',
                controller: _gramController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: _calculateTotal,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  double? grams = double.tryParse(value);
                  if (grams == null || grams <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Total Price
              if (_totalPrice > 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(_totalPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.redSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),

              // Buy Button
              AppButton(
                text: 'Beli Sekarang',
                icon: Icons.shopping_cart_checkout_rounded,
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : _handleBuyGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
