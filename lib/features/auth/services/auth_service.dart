import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiClient _apiClient = ApiClient();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sync user with backend
  Future<void> _syncUserWithBackend(User user, String? name) async {
    try {
      await _apiClient.dio.post('/auth/sync', data: {
        'name': name ?? user.displayName ?? 'User Toko Emas',
        'email': user.email ?? '',
      });
    } catch (e) {
      print('Failed to sync user to backend: $e');
      // Tidak di throw agar user tetap bisa login meski backend bermasalah sementara
    }
  }

  // Sync user manually and get updated data
  Future<Map<String, dynamic>?> syncUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final response = await _apiClient.dio.post('/auth/sync', data: {
          'name': user.displayName ?? 'User Toko Emas',
          'email': user.email ?? '',
        });
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Failed to sync user: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await _syncUserWithBackend(user, name);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        await _syncUserWithBackend(result.user!, null);
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        await _syncUserWithBackend(user, null);
      }

      return user;
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('Info: Google Sign Out dilewati atau error: $e');
    }
    
    await _auth.signOut();
  }

  // Get user data from backend
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      // Kita panggil /auth/sync lagi (sebagai get data) karena backend mengembalikan data user lengkap
      final user = _auth.currentUser;
      if (user != null) {
        final response = await _apiClient.dio.post('/auth/sync', data: {
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
        });
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user role specifically
  Future<String> getUserRole(String userId) async {
    try {
      final data = await getUserData(userId);
      if (data != null) {
        return data['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      return 'user';
    }
  }

  // Update Profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? password,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
      }

      if (email != null && email.isNotEmpty && email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }

      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }

      // Sync updated data
      await _syncUserWithBackend(user, name);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Sesi telah berakhir. Silakan logout dan login kembali untuk mengubah email atau password.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Gagal update profil: $e');
    }
  }
}
