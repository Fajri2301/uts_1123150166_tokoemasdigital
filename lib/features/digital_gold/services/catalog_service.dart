import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class CatalogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of products for real-time updates
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection('products')
        .where('is_available', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    });
  }

  // Get products once (Future)
  Future<List<ProductModel>> getProductsOnce() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('is_available', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data katalog: $e');
    }
  }
}
