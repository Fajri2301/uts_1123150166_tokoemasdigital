import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';

class AdminProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  User? get currentUser => _auth.currentUser;

  AdminProfileProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Dengan arsitektur Server-Driven Sync, backend akan auto-update saat kita panggil endpoint apapun
        // Tapi kita bisa gunakan auth/sync secara eksplisit untuk mengambil data profil lengkap
        final res = await _authService.syncUser();
        if (res != null && res.containsKey('data')) {
          _userData = {
            'name': res['data']['name'] ?? user.displayName ?? '',
            'email': res['data']['email'] ?? user.email ?? '',
            'role': res['data']['role'] ?? 'admin',
          };
        } else {
          _userData = {
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'role': 'admin',
          };
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data profil: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String name) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1. Update Firebase
        await user.updateDisplayName(name.trim());
        await user.reload();
        
        // 2. Sinkronkan dengan backend secara eksplisit
        await _authService.syncUser();
        
        // 3. Muat ulang data lokal
        await loadUserData();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateEmail(String newEmail, String currentPassword) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user before updating email
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update email in Firebase Auth
        await user.verifyBeforeUpdateEmail(newEmail.trim());

        // Sync perubahan ke Golang Backend
        await _authService.syncUser();
        
        await loadUserData();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui email: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui password: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
