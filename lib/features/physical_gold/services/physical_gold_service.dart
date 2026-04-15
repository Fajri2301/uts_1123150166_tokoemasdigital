import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';

class PhysicalGoldService {
  final FirestoreService _firestoreService = FirestoreService();

  // Get all products
  Stream<QuerySnapshot> getAllProducts() {
    return _firestoreService.getAllProducts();
  }

  // Get products by category
  Stream<QuerySnapshot> getProductsByCategory(String category) {
    return _firestoreService.getProductsByCategory(category);
  }

  // Get product by ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final doc = await _firestoreService.getDocument('products', productId);
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // Create transaction for physical product
  Future<bool> createTransaction({
    required String userId,
    required String productId,
    required double price,
    required String address,
  }) async {
    try {
      await _firestoreService.addDocument('transactions', {
        'user_id': userId,
        'type': 'fisik',
        'product_id': productId,
        'gold_amount': 0.0,
        'total_price': price,
        'status': 'diproses',
        'address': address,
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Get categories
  List<String> getCategories() {
    return ['cincin', 'gelang', 'kalung', 'anting'];
  }
}
