import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toko_emas_digital/core/services/notification_service.dart';
import 'package:toko_emas_digital/core/theme/app_theme.dart';
import 'package:toko_emas_digital/features/auth/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
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
