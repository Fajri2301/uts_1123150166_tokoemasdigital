import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // Sesuaikan URL jika dites di perangkat fisik vs emulator
    // Emulator Android: 10.0.2.2, Fisik/Web: IP Local (misal 192.168.x.x)
    // Ganti 127.0.0.1 dengan IP address laptop Anda agar bisa diakses dari HP fisik
    const String baseUrl = 'http://192.168.115.10:8081/v1';

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
    ));
  }
}
