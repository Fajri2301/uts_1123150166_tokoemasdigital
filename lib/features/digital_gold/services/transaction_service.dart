import 'package:dio/dio.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';
import 'package:toko_emas_digital/features/digital_gold/models/transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient = ApiClient();

  Future<double> getDigitalGoldBalance() async {
    try {
      final response = await _apiClient.dio.get('/gold/balance');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return (data['grams'] ?? 0.0).toDouble();
      }
      return 0.0;
    } catch (e) {
      // Return 0.0 if balance not found or error
      return 0.0;
    }
  }

  Future<bool> buyDigitalGold(double grams, double pricePerGram) async {
    try {
      final response = await _apiClient.dio.post('/gold/buy', data: {
        'gram_amount': grams,
        'price_per_gram': pricePerGram,
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

  Future<bool> sellDigitalGold(double grams, double pricePerGram) async {
    try {
      final response = await _apiClient.dio.post('/gold/sell', data: {
        'gram_amount': grams,
        'price_per_gram': pricePerGram,
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
