import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';
import 'package:toko_emas_digital/features/home/presentation/home_screen.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:toko_emas_digital/features/auth/presentation/register_screen.dart';
import 'package:toko_emas_digital/common/widgets/app_field.dart';
import 'package:toko_emas_digital/common/widgets/app_button.dart';
import 'package:toko_emas_digital/common/widgets/app_logo.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/app_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (user != null && mounted) {
        String role = await _authService.getUserRole(user.uid);
        if (mounted) {
          if (role == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
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

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        String role = await _authService.getUserRole(user.uid);
        if (mounted) {
          if (role == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const AppLogo(size: 80, isLight: true),
                const SizedBox(height: 32),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk ke akun Toko Emas Anda untuk melanjutkan',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

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
                      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),

                AppField(
                  label: 'Email',
                  hint: 'Masukkan email',
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
                  hint: 'Masukkan password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password wajib diisi';
                    if (!AppValidator.isValidPassword(value)) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                AppButton(
                  text: 'Masuk',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.line)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Atau masuk dengan',
                        style: TextStyle(color: AppColors.slate500, fontSize: 13),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.line)),
                  ],
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'Google',
                  onPressed: _isLoading ? () {} : _handleGoogleLogin,
                  variant: AppButtonVariant.outline,
                  icon: Icons.g_mobiledata,
                ),
                
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: AppColors.slate500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
