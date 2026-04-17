import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': 'user',
          'gold_balance': 0.0,
          'created_at': FieldValue.serverTimestamp(),
        });
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
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        // Check if user already exists in Firestore, if not create new
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Google User',
            'email': user.email,
            'role': 'user',
            'gold_balance': 0.0,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Hanya coba logout Google jika user memang terdeteksi login dengan Google
      // dan bungkus dalam try-catch agar tidak crash di Web jika Client ID belum diset
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      // Log error tapi jangan biarkan menghalangi logout utama
      print('Info: Google Sign Out dilewati atau error: $e');
    }
    
    // Logout utama dari Firebase
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Get user role specifically
  Future<String> getUserRole(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
      // Update Name
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).update({'name': name});
      }

      // Update Email
      if (email != null && email.isNotEmpty && email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
        await _firestore.collection('users').doc(user.uid).update({'email': email});
      }

      // Update Password
      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }
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
