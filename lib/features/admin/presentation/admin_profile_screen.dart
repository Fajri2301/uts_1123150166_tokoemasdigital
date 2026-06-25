import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:toko_emas_digital/common/widgets/custom_input_field.dart';
import 'package:toko_emas_digital/common/widgets/gold_button.dart';
import 'package:toko_emas_digital/features/auth/presentation/login_screen.dart';
import 'package:toko_emas_digital/features/admin/providers/admin_profile_provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Meminta provider memuat data jika belum dimuat, ini biasanya dipanggil di init,
    // tapi lebih aman jika dipanggil di level router atau initState pembungkus, 
    // namun karena ini diletakkan di tab dashboard, kita biarkan saja Consumer bereaksi.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Profil Admin', showBackButton: false),
      body: Consumer<AdminProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.userData.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            );
          }

          final user = provider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (provider.errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    color: Colors.redAccent.withOpacity(0.1),
                    child: Text(
                      provider.errorMessage,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                const SizedBox(height: 20),
                // Header Profil
                _buildProfileHeader(provider, user),
                const SizedBox(height: 40),

                // Menu Pengaturan
                _buildMenuTile(
                  Icons.person_outline,
                  'Edit Profil',
                  'Ubah Nama Admin',
                  () => _navigateToEditProfile(context, provider),
                ),
                _buildMenuTile(
                  Icons.email_outlined,
                  'Edit Email',
                  provider.userData['email'] ?? user?.email ?? 'Email',
                  () => _navigateToEditEmail(context, provider),
                ),
                _buildMenuTile(
                  Icons.lock_outline,
                  'Keamanan & Password',
                  'Ubah password Anda',
                  () => _navigateToEditPassword(context, provider),
                ),
                _buildMenuTile(
                  Icons.notifications_none,
                  'Pengaturan Notifikasi',
                  'Kelola preferensi notifikasi',
                  () => _showNotificationSettings(context),
                ),
                _buildMenuTile(
                  Icons.info_outline,
                  'Tentang Aplikasi',
                  'Versi 1.0.0',
                  () => _showAboutDialog(context),
                ),

                const SizedBox(height: 40),

                // Tombol Logout
                _buildLogoutButton(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AdminProfileProvider provider, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.goldAccent,
            child: Icon(Icons.person, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            provider.userData['name'] ?? user?.displayName ?? 'Administrator',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.userData['email'] ?? user?.email ?? 'admin@tokoemas.com',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Role: ${provider.userData['role'] ?? 'admin'}',
              style: const TextStyle(
                color: AppColors.goldAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.goldAccent),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ),
        const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AdminProfileProvider provider) {
    return GoldButton(
      text: 'Keluar Akun',
      onPressed: () => _showLogoutDialog(context, provider),
      isSecondary: true,
    );
  }

  void _navigateToEditProfile(BuildContext context, AdminProfileProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  void _navigateToEditEmail(BuildContext context, AdminProfileProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditEmailScreen(),
      ),
    );
  }

  void _navigateToEditPassword(BuildContext context, AdminProfileProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditPasswordScreen(),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.divider,
        title: const Text('Pengaturan Notifikasi'),
        content: const Text('Fitur ini akan segera hadir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.divider,
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toko Emas Digital'),
            SizedBox(height: 8),
            Text('Versi: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Aplikasi untuk mengelola toko emas digital dan fisik dengan fitur lengkap.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AdminProfileProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.divider,
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== EDIT PROFILE SCREEN ====================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AdminProfileProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.userData['name'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<AdminProfileProvider>(context, listen: false);
    
    final success = await provider.updateProfile(_nameController.text);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Edit Profil', showBackButton: true),
      body: Consumer<AdminProfileProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Informasi Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    hintText: 'Nama Lengkap',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          ),
                        )
                      : GoldButton(
                          text: 'Simpan Perubahan',
                          onPressed: _saveProfile,
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== EDIT EMAIL SCREEN ====================

class EditEmailScreen extends StatefulWidget {
  const EditEmailScreen({Key? key}) : super(key: key);

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AdminProfileProvider>(context, listen: false);
    _emailController = TextEditingController(text: provider.userData['email'] ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<AdminProfileProvider>(context, listen: false);

    final success = await provider.updateEmail(_emailController.text, _passwordController.text);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email berhasil diperbarui (Mohon verifikasi email baru Anda)'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Edit Email', showBackButton: true),
      body: Consumer<AdminProfileProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ubah Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masukkan password Anda untuk mengkonfirmasi perubahan email',
                    style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    hintText: 'Email Baru',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    hintText: 'Password Saat Ini',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          ),
                        )
                      : GoldButton(
                          text: 'Update Email',
                          onPressed: _updateEmail,
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== EDIT PASSWORD SCREEN ====================

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({Key? key}) : super(key: key);

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru dan konfirmasi tidak cocok'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final provider = Provider.of<AdminProfileProvider>(context, listen: false);
    final success = await provider.updatePassword(_currentPasswordController.text, _newPasswordController.text);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Ubah Password', showBackButton: true),
      body: Consumer<AdminProfileProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Keamanan & Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan password Anda minimal 6 karakter dan sulit ditebak',
                    style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    hintText: 'Password Saat Ini',
                    controller: _currentPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password saat ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    hintText: 'Password Baru',
                    controller: _newPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password baru wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    hintText: 'Konfirmasi Password Baru',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password wajib diisi';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          ),
                        )
                      : GoldButton(
                          text: 'Update Password',
                          onPressed: _updatePassword,
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
