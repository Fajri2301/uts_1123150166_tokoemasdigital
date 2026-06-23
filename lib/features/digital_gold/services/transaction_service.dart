import 'package:dio/dio.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';
import 'package:toko_emas_digital/features/digital_gold/models/transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, double>> getWalletBalance() async {
    try {
      final response = await _apiClient.dio.get('/gold/balance');
      final data = response.data['data'];
      return {
        'grams': (data['grams'] ?? 0.0).toDouble(),
        'rupiah': (data['rupiah_balance'] ?? 0.0).toDouble(),
      };
    } catch (e) {
      return {'grams': 0.0, 'rupiah': 0.0};
    }
  }

  Future<bool> buyDigitalGold(double grams, String paymentMethod) async {
    try {
      final response = await _apiClient.dio.post('/gold/buy', data: {
        'gram_amount': grams,
        'payment_method': paymentMethod,
      });
      return response.data['success'] == true;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          throw Exception(data['message'] ?? data['error'] ?? data.toString());
        }
      }
      throw Exception('Gagal membeli emas digital: $e');
    }
  }

  Future<bool> sellDigitalGold(double grams) async {
    try {
      final response = await _apiClient.dio.post('/gold/sell', data: {
        'gram_amount': grams,
      });
      return response.data['success'] == true;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          throw Exception(data['message'] ?? data['error'] ?? data.toString());
        }
      }
      throw Exception('Gagal menjual emas digital: $e');
    }
  }

  Future<bool> withdrawCash(double amount) async {
    try {
      final response = await _apiClient.dio.post('/wallet/withdraw', data: {
        'amount': amount,
      });
      return response.data['success'] == true;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          throw Exception(data['message'] ?? data['error'] ?? data.toString());
        }
      }
      throw Exception('Gagal menarik dana: $e');
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _apiClient.dio.get('/transactions');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          throw Exception(data['message'] ?? data['error'] ?? data.toString());
        }
      }
      throw Exception('Gagal mengambil riwayat transaksi: $e');
    }
  }
}
