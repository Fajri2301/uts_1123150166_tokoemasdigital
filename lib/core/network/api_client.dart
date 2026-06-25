import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

// Global Key for accessing context from anywhere without passing it around
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8081/v1';

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ambil token Firebase saat ini
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Global Error Handling
        String errorMessage = 'Terjadi kesalahan pada server';
        
        if (e.response != null) {
          if (e.response!.statusCode == 401) {
            errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
            // Force logout if token is completely dead
            await FirebaseAuth.instance.signOut();
            // TODO: Navigate to login using navigatorKey if implemented
          } else if (e.response!.statusCode == 500) {
            errorMessage = 'Server sedang mengalami gangguan (500).';
          } else {
            errorMessage = e.response!.data['message'] ?? errorMessage;
          }
        } else if (e.type == DioExceptionType.connectionTimeout || 
                   e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Koneksi terputus. Periksa jaringan internet Anda.';
        }

        // Show snackbar using global navigator key if available
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }

        return handler.next(e);
      },
    ));
  }
}
