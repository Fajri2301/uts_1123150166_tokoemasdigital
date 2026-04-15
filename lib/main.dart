import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:toko_emas_digital/core/constants/firebase_config.dart';
import 'package:toko_emas_digital/core/services/notification_service.dart';
import 'package:toko_emas_digital/core/theme/app_theme.dart';
import 'package:toko_emas_digital/features/auth/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase secara eksplisit
  try {
    if (kIsWeb) {
      // Wajib menggunakan options untuk platform Web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: FirebaseConfig.apiKey,
          appId: FirebaseConfig.appId,
          messagingSenderId: FirebaseConfig.messagingSenderId,
          projectId: FirebaseConfig.projectId,
          authDomain: FirebaseConfig.authDomain,
          storageBucket: FirebaseConfig.storageBucket,
          measurementId: FirebaseConfig.measurementId,
        ),
      );
      debugPrint("Firebase initialized for Web");
    } else {
      // Android/iOS otomatis membaca dari google-services.json / GoogleService-Info.plist
      await Firebase.initializeApp();
      debugPrint("Firebase initialized for Mobile");
    }

    // Inisialisasi Notifikasi hanya jika Firebase berhasil
    await NotificationService().initialize();
    
  } catch (e) {
    debugPrint("CRITICAL ERROR: Firebase initialization failed: $e");
    // Tetap jalankan aplikasi tapi mungkin akan muncul error di layar jika Firebase dipanggil
  }
  
  runApp(const TokoEmasApp());
}

class TokoEmasApp extends StatelessWidget {
  const TokoEmasApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Emas Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
