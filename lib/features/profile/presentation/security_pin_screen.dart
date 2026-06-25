import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/profile/services/user_service.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  final UserService _userService = UserService();
  String _pin = '';
  bool _isLoading = false;

  void _onNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
      });
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _submitPin() async {
    if (_pin.length != 6) return;
    
    setState(() => _isLoading = true);
    try {
      await _userService.updatePIN(_pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN berhasil disimpan')),
        );
        Navigator.pop(context, true); // return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100E0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
        title: const Text(
          'Atur PIN Keamanan',
          style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Masukkan 6 Digit PIN',
              style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length ? AppColors.primaryGold : Colors.transparent,
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5), width: 2),
                  ),
                );
              }),
            ),
            const Spacer(),
            if (_isLoading) 
              const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildNumpadRow(['1', '2', '3']),
                    _buildNumpadRow(['4', '5', '6']),
                    _buildNumpadRow(['7', '8', '9']),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumpadButton(''),
                        _buildNumpadButton('0'),
                        _buildNumpadButton('<', isDelete: true),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pin.length == 6 && !_isLoading ? _submitPin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan PIN', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((num) => _buildNumpadButton(num)).toList(),
    );
  }

  Widget _buildNumpadButton(String label, {bool isDelete = false}) {
    if (label.isEmpty) return const SizedBox(width: 80, height: 80);

    return InkWell(
      onTap: isDelete ? _onDeletePressed : () => _onNumberPressed(label),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: isDelete
            ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 28)
            : Text(
                label,
                style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
              ),
      ),
    );
  }
}
