import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/profile/services/user_service.dart';
import 'package:toko_emas_digital/features/home/presentation/main_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final UserService _userService = UserService();
  String _pin = '';
  bool _isLoading = false;
  String? _errorMessage;

  void _onNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
        _errorMessage = null; // Clear error on typing
      });
      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    try {
      await _userService.verifyPIN(_pin);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'PIN Salah. Silakan coba lagi.';
          _pin = '';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope prevents back button
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF100E0C),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.lock_outline_rounded, color: AppColors.primaryGold, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Masukkan PIN Keamanan',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  bool isFilled = index < _pin.length;
                  bool hasError = _errorMessage != null;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled 
                          ? (hasError ? Colors.redAccent : AppColors.primaryGold)
                          : Colors.transparent,
                      border: Border.all(
                        color: hasError 
                            ? Colors.redAccent 
                            : AppColors.primaryGold.withValues(alpha: 0.5), 
                        width: 2
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(fontFamily: 'Inter', color: Colors.redAccent, fontSize: 14)),
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
              const SizedBox(height: 40),
            ],
          ),
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
