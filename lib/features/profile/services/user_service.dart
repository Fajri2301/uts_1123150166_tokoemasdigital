import 'package:dio/dio.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/user/profile');
      return response.data['data'];
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        throw Exception(e.response?.data['error'] ?? 'Gagal mengambil data profil');
      }
      throw Exception('Terjadi kesalahan jaringan');
    }
  }

  Future<void> updatePIN(String pin) async {
    try {
      await _apiClient.dio.post('/user/pin', data: {'pin': pin});
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        throw Exception(e.response?.data['error'] ?? 'Gagal memperbarui PIN');
      }
      throw Exception('Terjadi kesalahan jaringan');
    }
  }

  Future<void> verifyPIN(String pin) async {
    try {
      await _apiClient.dio.post('/user/pin/verify', data: {'pin': pin});
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        throw Exception(e.response?.data['error'] ?? 'Gagal memverifikasi PIN');
      }
      throw Exception('Terjadi kesalahan jaringan');
    }
  }

  Future<void> updateBank(String bankName, String bankAccount) async {
    try {
      await _apiClient.dio.post('/user/bank', data: {
        'bank_name': bankName,
        'bank_account': bankAccount,
      });
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        throw Exception(e.response?.data['error'] ?? 'Gagal memperbarui data Bank');
      }
      throw Exception('Terjadi kesalahan jaringan');
    }
  }

  Future<void> verifyKYC() async {
    try {
      await _apiClient.dio.post('/user/kyc');
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        throw Exception(e.response?.data['error'] ?? 'Gagal memverifikasi KYC');
      }
      throw Exception('Terjadi kesalahan jaringan');
    }
  }

  Future<void> updateFCMToken(String token) async {
    try {
      await _apiClient.dio.post('/user/fcm-token', data: {'fcm_token': token});
    } catch (e) {
      // Ignored for now
    }
  }

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/user/notifications');
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      throw Exception('Gagal mengambil notifikasi');
    }
  }
}
