import 'package:toko_emas_digital/core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../models/product_model.dart';

class PhysicalGoldService {
  final ApiClient _apiClient = ApiClient();

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _apiClient.dio.get('/products');
      if (response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data produk fisik: $e');
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await _apiClient.dio.get('/products?category=$category');
      if (response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data produk per kategori: $e');
    }
  }

  // Create transaction for physical product with atomic safety
  Future<bool> createTransaction({
    required String userId,
    required String productId,
    required double price,
    required String address,
    String paymentMethod = 'Transfer Bank',
  }) async {
    try {
      final response = await _apiClient.dio.post('/checkout/physical', data: {
        'product_id': int.parse(productId), // asumsikan ID dari backend adalah int (terformat string sebelumnya)
        'price': price,
        'address': address,
        'payment_method': paymentMethod,
      });

      return response.data['success'] == true;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          final message = data['message'] ?? data['error'] ?? data.toString();
          throw Exception('Gagal membuat pesanan: $message');
        } else {
          throw Exception('Gagal membuat pesanan: ${e.response?.data}');
        }
      }
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  // Get categories
  List<String> getCategories() {
    return ['cincin', 'gelang', 'kalung', 'anting'];
  }
}
