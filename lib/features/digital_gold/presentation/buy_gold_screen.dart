import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../common/widgets/gold_button.dart';
import '../services/digital_gold_service.dart';

class BuyGoldScreen extends StatefulWidget {
  const BuyGoldScreen({Key? key}) : super(key: key);

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
            backgroundColor: Color(0xFF4CAF50),
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
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Beli Emas Digital',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gold Price Info
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga Emas Saat Ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(_currentGoldPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Gram Input (50 px height)
              const Text(
                'Jumlah Emas (gram)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: AppDimensions.inputHeight,
                child: TextFormField(
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
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Masukkan jumlah gram',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    suffixText: 'gram',
                    suffixStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.padding,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Total Price
              if (_totalPrice > 0)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacingMedium),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(_totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacingMedium),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                    border: Border.all(color: const Color(0xFFF44336)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFF44336)),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),

              // Buy Button (48 px)
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    )
                  : GoldButton(
                      text: 'Beli Sekarang',
                      onPressed: _handleBuyGold,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
