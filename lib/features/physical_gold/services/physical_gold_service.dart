import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';

class PhysicalGoldService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Create transaction for physical product with atomic safety
  Future<bool> createTransaction({
    required String userId,
    required String productId,
    required double price,
    required String address,
    String paymentMethod = 'Transfer Bank',
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. Get Product Data to get Gram Amount (optional but good for tracking)
        DocumentReference productRef = _firestore.collection('products').doc(productId);
        DocumentSnapshot productSnapshot = await transaction.get(productRef);
        
        double goldAmount = 0.0;
        String productName = 'Produk';
        
        if (productSnapshot.exists) {
          final pData = productSnapshot.data() as Map<String, dynamic>;
          goldAmount = (pData['weight'] ?? 0.0).toDouble();
          productName = pData['name'] ?? 'Produk';
        }

        // 2. Create Transaction Record
        DocumentReference transRef = _firestore.collection('transactions').doc();
        transaction.set(transRef, {
          'user_id': userId,
          'type': 'fisik',
          'product_id': productId,
          'product_name': productName,
          'gold_amount': goldAmount,
          'total_price': price,
          'status': 'pending', // Awalnya pending sampai dibayar/dikonfirmasi
          'address': address,
          'payment_method': paymentMethod,
          'created_at': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  // Get categories
  List<String> getCategories() {
    return ['cincin', 'gelang', 'kalung', 'anting'];
  }
}
