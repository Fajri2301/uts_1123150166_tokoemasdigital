import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toko_emas_digital/features/profile/services/user_service.dart';

// Notification channel untuk Android
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'toko_emas_high_importance', // id
  'Notifikasi Toko Emas', // name
  description: 'Notifikasi transaksi dan promo dari Toko Emas Digital.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Inisialisasi flutter_local_notifications
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _localNotif.initialize(initSettings);

    // 2. Buat Android Notification Channel (wajib untuk Android 8+)
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Minta izin FCM (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('FCM Permission granted');

      // 4. Pastikan foreground notifications tampil
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Dapatkan & kirim FCM Token ke backend
      String? token = await _fcm.getToken();
      if (kDebugMode) print('FCM Token: $token');
      if (token != null) {
        try {
          await UserService().updateFCMToken(token);
        } catch (e) {
          if (kDebugMode) print('Failed to sync FCM token: $e');
        }
      }

      // 6. Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 7. Handle foreground messages — tampilkan sebagai heads-up popup
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Foreground message: ${message.notification?.title}');
        }

        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotif.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                ticker: notification.title,
              ),
            ),
          );
        }
      });
    } else {
      if (kDebugMode) print('FCM Permission denied');
    }
  }
}

// Handler untuk background/terminated messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message: ${message.messageId}');
  }
}

