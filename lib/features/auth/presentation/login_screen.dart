import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';
import 'package:toko_emas_digital/features/home/presentation/main_screen.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:toko_emas_digital/features/auth/presentation/register_screen.dart';
import 'package:toko_emas_digital/common/widgets/app_field.dart';
import 'package:toko_emas_digital/common/widgets/app_button.dart';
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
              MaterialPageRoute(builder: (_) => const MainScreen()),
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
              MaterialPageRoute(builder: (_) => const MainScreen()),
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
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.dashboard_customize_rounded, color: AppColors.primaryGold, size: 36),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gold Century',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLightGold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selamat datang kembali di pusat investasi emas digital Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

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
                      AppField(
                        label: 'Alamat Email',
                        placeholder: 'Masukkan email Anda',
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
                        placeholder: 'Masukkan password',
                        controller: _passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password wajib diisi';
                          if (!AppValidator.isValidPassword(value)) return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.primaryGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: 'Masuk ke Akun',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.darkGray)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Atau masuk dengan',
                        style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.darkGray)),
                  ],
                ),
                const SizedBox(height: 24),

                AppButton(
                  label: 'Google',
                  onPressed: _isLoading ? () {} : _handleGoogleLogin,
                  variant: AppButtonVariant.outlineWhite,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Daftar Sekarang',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
