import 'package:toko_emas_digital/core/network/api_client.dart';

class DigitalGoldService {
  final ApiClient _apiClient = ApiClient();

  // Buy digital gold with Transaction for safety
  Future<bool> buyGold({
    required String userId,
    required double gramAmount,
    required double pricePerGram,
  }) async {
    try {
      final response = await _apiClient.dio.post('/gold/buy', data: {
        'gram_amount': gramAmount,
        'price_per_gram': pricePerGram,
      });

      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Gagal membeli emas: $e');
    }
  }

  // Convert digital gold to physical (batangan)
  Future<bool> convertToPhysical({
    required String userId,
    required double gramAmount,
    required String address,
  }) async {
    try {
      // Sama seperti checkout physical gold, tetapi menggunakan metode pembayaran potong saldo
      final response = await _apiClient.dio.post('/checkout/physical', data: {
        'product_id': 0, // asumsikan 0 = custom konversi batangan
        'price': 0, // harga 0 karena potong saldo
        'address': address,
        'payment_method': 'Saldo Emas Digital',
      });

      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Gagal konversi emas: $e');
    }
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final response = await _apiClient.dio.get('/transactions');
      if (response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil riwayat transaksi: $e');
    }
  }

  // Get current gold price
  Future<double> getCurrentGoldPrice() async {
    // Pada arsitektur nyata, ini biasanya memanggil API pihak ketiga
    // Untuk simulasi ini kita asumsikan harga statis atau bisa dipanggil dari API Golang
    return 1230000.0;
  }
}
