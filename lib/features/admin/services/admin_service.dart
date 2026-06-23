import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  // Dashboard stats
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('/admin/dashboard');
      if (response.data['success']) {
        return Map<String, int>.from(response.data['data']);
      }
      return {'products': 0, 'transactions': 0, 'users': 0};
    } catch (e) {
      throw Exception('Gagal ambil statistik: $e');
    }
  }

  // CRUD Products
  Future<List<dynamic>> getAllProducts() async {
    try {
      final response = await _apiClient.dio.get('/products');
      if (response.data['success']) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw Exception('Gagal ambil produk: $e');
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _apiClient.dio.post('/admin/products', data: productData);
    } catch (e) {
      throw Exception('Gagal tambah produk: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await _apiClient.dio.put('/admin/products/$productId', data: productData);
    } catch (e) {
      throw Exception('Gagal update produk: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _apiClient.dio.delete('/admin/products/$productId');
    } catch (e) {
      throw Exception('Gagal hapus produk: $e');
    }
  }

  // Update gold price
  Future<void> updateGoldPrice(double pricePerGram) async {
    try {
      await _apiClient.dio.post('/admin/gold-price', data: {
        'price_per_gram': pricePerGram,
      });
    } catch (e) {
      throw Exception('Gagal update harga emas: $e');
    }
  }

  Future<double> getCurrentGoldPrice() async {
    try {
      final response = await _apiClient.dio.get('/admin/gold-price');
      if (response.data['success']) {
        return (response.data['data']['price_per_gram'] as num).toDouble();
      }
      return 1230000.0;
    } catch (e) {
      return 1230000.0;
    }
  }

  // Manage transactions
  Future<List<dynamic>> getAllTransactions() async {
    try {
      final response = await _apiClient.dio.get('/admin/transactions');
      if (response.data['success']) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw Exception('Gagal ambil transaksi: $e');
    }
  }

  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      await _apiClient.dio.put('/admin/transactions/$transactionId/status', data: {
        'status': status,
      });
    } catch (e) {
      throw Exception('Gagal update status transaksi: $e');
    }
  }

  // Manage Users
  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await _apiClient.dio.get('/admin/users');
      if (response.data['success']) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw Exception('Gagal ambil user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiClient.dio.delete('/admin/users/$userId');
    } catch (e) {
      throw Exception('Gagal hapus user: $e');
    }
  }

  // Manage Categories
  Future<List<dynamic>> getAllCategories() async {
    try {
      final response = await _apiClient.dio.get('/admin/categories');
      if (response.data['success']) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw Exception('Gagal ambil kategori: $e');
    }
  }

  Future<void> addCategory(String name) async {
    try {
      await _apiClient.dio.post('/admin/categories', data: {
        'name': name,
      });
    } catch (e) {
      throw Exception('Gagal tambah kategori: $e');
    }
  }

  Future<void> updateCategory(String id, String name) async {
    try {
      await _apiClient.dio.put('/admin/categories/$id', data: {
        'name': name,
      });
    } catch (e) {
      throw Exception('Gagal update kategori: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _apiClient.dio.delete('/admin/categories/$id');
    } catch (e) {
      throw Exception('Gagal hapus kategori: $e');
    }
  }

  List<String> getTransactionStatuses() {
    return ['pending', 'diproses', 'dikirim', 'selesai', 'failed'];
  }
}
