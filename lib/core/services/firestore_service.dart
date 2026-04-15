import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic Get Document
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Generic Get Collection
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Generic Add Document
  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    DocumentReference docRef = await _firestore.collection(collection).add(data);
    return docRef.id;
  }

  // Generic Update Document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Generic Delete Document
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Generic Query
  Future<QuerySnapshot> queryCollection(
    String collection, {
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _firestore.collection(collection);

    if (filters != null) {
      for (final filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Update user gold balance
  Future<void> updateUserGoldBalance(String userId, double newBalance) async {
    await _firestore.collection('users').doc(userId).update({
      'gold_balance': newBalance,
    });
  }

  // Get current gold price
  Future<double> getCurrentGoldPrice() async {
    QuerySnapshot snapshot = await _firestore
        .collection('gold_prices')
        .orderBy('updated_at', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return (data['price_per_gram'] ?? 0.0).toDouble();
    }
    return 0.0; // Default if no price found
  }

  // Add transaction
  Future<String> addTransaction(Map<String, dynamic> transactionData) async {
    return await addDocument('transactions', transactionData);
  }

  // Get user transactions
  Stream<QuerySnapshot> getUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Get all products
  Stream<QuerySnapshot> getAllProducts() {
    return _firestore.collection('products').snapshots();
  }

  // Get products by category
  Stream<QuerySnapshot> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots();
  }
}

class QueryFilter {
  final String field;
  final dynamic value;

  QueryFilter(this.field, this.value);
}
