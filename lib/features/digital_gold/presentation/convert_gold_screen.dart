import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/services/firestore_service.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/gold_button.dart';
import '../services/digital_gold_service.dart';

class ConvertGoldScreen extends StatefulWidget {
  const ConvertGoldScreen({Key? key}) : super(key: key);

  @override
  State<ConvertGoldScreen> createState() => _ConvertGoldScreenState();
}

class _ConvertGoldScreenState extends State<ConvertGoldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gramController = TextEditingController();
  final _addressController = TextEditingController();
  final _digitalGoldService = DigitalGoldService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _errorMessage;
  double _userGoldBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUserById(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _userGoldBalance = (userData['gold_balance'] ?? 0.0).toDouble();
        });
      }
    }
  }

  Future<void> _handleConvert() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      double grams = double.parse(_gramController.text);
      bool success = await _digitalGoldService.convertToPhysical(
        userId: user.uid,
        gramAmount: grams,
        address: _addressController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengkonversi emas!'),
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
          'Cetak Emas (Batangan)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Konversi Emas Digital ke Fisik',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saldo Anda: ${CurrencyFormatter.formatGram(_userGoldBalance)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⚠️ Emas akan dikonversi menjadi batangan fisik dan dikirim ke alamat Anda.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Gram Input (50 px height)
              const Text(
                'Jumlah Emas yang Dikonversi (gram)',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah wajib diisi';
                    }
                    double? grams = double.tryParse(value);
                    if (grams == null || grams <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }
                    if (grams > _userGoldBalance) {
                      return 'Saldo tidak mencukupi';
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

              // Address Input
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 100),
                child: TextFormField(
                  controller: _addressController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat wajib diisi';
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Masukkan alamat lengkap',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.padding),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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

              // Convert Button (48 px)
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    )
                  : GoldButton(
                      text: 'Konversi ke Emas Fisik',
                      onPressed: _handleConvert,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
