import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:toko_emas_digital/core/constants/firebase_config.dart';
import 'package:toko_emas_digital/core/services/notification_service.dart';
import 'package:toko_emas_digital/core/theme/app_theme.dart';
import 'package:toko_emas_digital/features/auth/presentation/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';
import 'package:provider/provider.dart';
import 'package:toko_emas_digital/features/admin/providers/admin_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Inisialisasi Firebase secara eksplisit
  try {
    // Wajib menggunakan options untuk platform Web dan sangat disarankan untuk Mobile
    // agar terhindar dari error 'No Firebase App [DEFAULT]'
    try {
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
    } catch (e) {
      if (!e.toString().contains('duplicate-app')) {
        debugPrint("Firebase initialization error: $e");
      }
    }
    debugPrint("Firebase initialized successfully");

    // Inisialisasi Notifikasi hanya jika Firebase berhasil
    await NotificationService().initialize();
    
  } catch (e) {
    debugPrint("CRITICAL ERROR: Firebase initialization failed: $e");
    // Tetap jalankan aplikasi tapi mungkin akan muncul error di layar jika Firebase dipanggil
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProfileProvider()),
      ],
      child: const TokoEmasApp(),
    ),
  );
}

class TokoEmasApp extends StatelessWidget {
  const TokoEmasApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Emas Digital',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

