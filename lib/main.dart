import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:toko_emas_digital/core/constants/firebase_config.dart';
import 'package:toko_emas_digital/core/services/notification_service.dart';
import 'package:toko_emas_digital/core/theme/app_theme.dart';
import 'package:toko_emas_digital/features/auth/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: kIsWeb ? const FirebaseOptions(
        apiKey: FirebaseConfig.apiKey,
        appId: FirebaseConfig.appId,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        projectId: FirebaseConfig.projectId,
        authDomain: FirebaseConfig.authDomain,
        storageBucket: FirebaseConfig.storageBucket,
        measurementId: FirebaseConfig.measurementId,
      ) : null,
    );
    // Initialize Notifications
    await NotificationService().initialize();
  } catch (e) {
    debugPrint("Initialization failed: $e");
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
