import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';

class AdminService {
  final FirestoreService _firestoreService = FirestoreService();

  // Dashboard stats
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final productsSnapshot = await _firestoreService.queryCollection('products');
      final transactionsSnapshot = await _firestoreService.queryCollection('transactions');
      final usersSnapshot = await _firestoreService.queryCollection('users');

      return {
        'products': productsSnapshot.docs.length,
        'transactions': transactionsSnapshot.docs.length,
        'users': usersSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Gagal ambil statistik: $e');
    }
  }

  // CRUD Products
  Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      return await _firestoreService.addDocument('products', productData);
    } catch (e) {
      throw Exception('Gagal tambah produk: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await _firestoreService.updateDocument('products', productId, productData);
    } catch (e) {
      throw Exception('Gagal update produk: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestoreService.deleteDocument('products', productId);
    } catch (e) {
      throw Exception('Gagal hapus produk: $e');
    }
  }

  Stream<QuerySnapshot> getAllProducts() {
    return _firestoreService.getCollectionStream('products');
  }

  // Update gold price
  Future<void> updateGoldPrice(double pricePerGram) async {
    try {
      await _firestoreService.addDocument('gold_prices', {
        'price_per_gram': pricePerGram,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal update harga emas: $e');
    }
  }

  Future<double> getCurrentGoldPrice() async {
    return await _firestoreService.getCurrentGoldPrice();
  }

  // Manage transactions
  Stream<QuerySnapshot> getAllTransactions() {
    return _firestoreService.getCollectionStream('transactions')
        .map((snapshot) => snapshot);
  }

  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      await _firestoreService.updateDocument('transactions', transactionId, {
        'status': status,
      });
    } catch (e) {
      throw Exception('Gagal update status transaksi: $e');
    }
  }

  List<String> getTransactionStatuses() {
    return ['pending', 'diproses', 'dikirim', 'selesai'];
  }
}
