import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';
import 'package:toko_emas_digital/features/profile/services/user_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Minta izin FCM (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('FCM Permission granted');

      // Dapatkan & kirim FCM Token ke backend
      String? token = await _fcm.getToken();
      if (kDebugMode) print('FCM Token: $token');
      if (token != null) {
        try {
          await UserService().updateFCMToken(token);
        } catch (e) {
          if (kDebugMode) print('Failed to sync FCM token: $e');
        }
      }

      // Handle background/terminated messages (FCM handles ini otomatis di status bar)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages — tampilkan sebagai SnackBar di dalam aplikasi
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) print('Foreground message: ${message.notification?.title}');

        final notification = message.notification;
        if (notification != null) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (notification.body != null)
                      Text(
                        notification.body!,
                        style: const TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                  ],
                ),
                backgroundColor: AppColors.primaryGold,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      });
    } else {
      if (kDebugMode) print('FCM Permission denied');
    }
  }
}

// Handler untuk background/terminated messages — WAJIB top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) print('Background message: ${message.messageId}');
}
