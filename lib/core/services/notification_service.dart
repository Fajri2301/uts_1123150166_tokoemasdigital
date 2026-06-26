import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toko_emas_digital/features/profile/services/user_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Inisialisasi pengaturan untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Inisialisasi pengaturan untuk iOS/macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(initializationSettings);

    // 2. Minta izin FCM (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Konfigurasi agar FCM tetap memunculkan Heads-Up notification di Foreground (iOS)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
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

      // Handle background/terminated messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages - PAKSA MUNCUL POPBAR SISTEM (menggunakan flutter_local_notifications)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) print('Foreground message: ${message.notification?.title}');

        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null) {
          // Konfigurasi Notifikasi Channel (Penting untuk Android 8.0+)
          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails(
            'high_importance_channel', // channelId
            'High Importance Notifications', // channelName
            channelDescription: 'Channel ini digunakan untuk notifikasi penting/broadcast.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            showWhen: true,
          );

          const NotificationDetails notificationDetails =
              NotificationDetails(android: androidNotificationDetails);

          // Tampilkan notifikasi secara paksa
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            notificationDetails,
          );
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
