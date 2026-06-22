import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/app_field.dart';
import '../services/digital_gold_service.dart';

class ConvertGoldScreen extends StatefulWidget {
  const ConvertGoldScreen({super.key});

  @override
  State<ConvertGoldScreen> createState() => _ConvertGoldScreenState();
}

class _ConvertGoldScreenState extends State<ConvertGoldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gramController = TextEditingController();
  final _addressController = TextEditingController();
  final _digitalGoldService = DigitalGoldService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleConvertGold() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      double grams = double.parse(_gramController.text);
      String address = _addressController.text;

      bool success = await _digitalGoldService.convertToPhysical(
        userId: user.uid,
        gramAmount: grams,
        address: address,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengajukan konversi emas!'),
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
          'Konversi Emas Fisik',
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blueSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        'Konversi minimal 1 gram. Emas fisik akan dikirimkan ke alamat Anda. Pastikan alamat lengkap.',
                        style: TextStyle(color: AppColors.blue, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gram Input
              AppField(
                label: 'Jumlah Emas (gram)',
                hint: 'Minimal 1',
                controller: _gramController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  double? grams = double.tryParse(value);
                  if (grams == null || grams < 1) {
                    return 'Minimal konversi adalah 1 gram';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address Input
              AppField(
                label: 'Alamat Pengiriman Lengkap',
                hint: 'Masukkan alamat lengkap beserta kode pos',
                controller: _addressController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

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

              // Convert Button
              AppButton(
                text: 'Proses Konversi',
                icon: Icons.print_rounded,
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : _handleConvertGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
