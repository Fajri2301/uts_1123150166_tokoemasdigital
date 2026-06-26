import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:toko_emas_digital/features/home/presentation/main_screen.dart';
import '../../../common/widgets/app_field.dart';
import '../../../common/widgets/app_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryLightGold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lengkapi data di bawah ini untuk mulai berinvestasi di Toko Emas Digital.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.redSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.darkGray),
                    boxShadow: AppColors.shadowCard,
                  ),
                  child: Column(
                    children: [
                      // Input Fields
                      AppField(
                        label: 'Nama Lengkap',
                        placeholder: 'Contoh: John Doe',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nama wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      AppField(
                        label: 'Alamat Email',
                        placeholder: 'Masukkan email aktif',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email wajib diisi';
                          if (!AppValidator.isValidEmail(value)) return 'Email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      AppField(
                        label: 'Password',
                        placeholder: 'Minimal 6 karakter',
                        controller: _passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password wajib diisi';
                          if (!AppValidator.isValidPassword(value)) return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      AppField(
                        label: 'Konfirmasi Password',
                        placeholder: 'Ketik ulang password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                          if (value != _passwordController.text) return 'Password tidak sama';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // Register Button
                      AppButton(
                        label: 'Daftar Sekarang',
                        onPressed: _handleRegister,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          color: AppColors.primaryLightGold,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
