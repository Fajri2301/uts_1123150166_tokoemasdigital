import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';

class DigitalGoldService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Buy digital gold with Transaction for safety
  Future<bool> buyGold({
    required String userId,
    required double gramAmount,
    required double pricePerGram,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('User tidak ditemukan');
        }

        double currentBalance = (userSnapshot.get('gold_balance') ?? 0.0).toDouble();
        double newBalance = currentBalance + gramAmount;
        double totalPrice = gramAmount * pricePerGram;

        // 1. Update User Balance
        transaction.update(userRef, {'gold_balance': newBalance});

        // 2. Create Transaction Record
        DocumentReference transRef = _firestore.collection('transactions').doc();
        transaction.set(transRef, {
          'user_id': userId,
          'type': 'digital',
          'gold_amount': gramAmount,
          'price_per_gram': pricePerGram,
          'total_price': totalPrice,
          'status': 'selesai',
          'created_at': FieldValue.serverTimestamp(),
        });

        return true;
      });
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
      return await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) throw Exception('User tidak ditemukan');

        double currentBalance = (userSnapshot.get('gold_balance') ?? 0.0).toDouble();
        
        if (currentBalance < gramAmount) {
          throw Exception('Saldo emas tidak mencukupi. Saldo Anda: $currentBalance gr');
        }

        double newBalance = currentBalance - gramAmount;

        // 1. Update Balance
        transaction.update(userRef, {'gold_balance': newBalance});

        // 2. Create physical transaction
        DocumentReference transRef = _firestore.collection('transactions').doc();
        transaction.set(transRef, {
          'user_id': userId,
          'type': 'fisik',
          'gold_amount': gramAmount,
          'product_id': 'batangan',
          'status': 'diproses',
          'address': address,
          'created_at': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      throw Exception('Gagal konversi emas: $e');
    }
  }

  // Get transaction history
  Stream<QuerySnapshot> getUserTransactions(String userId) {
    return _firestoreService.getUserTransactions(userId);
  }

  // Get current gold price
  Future<double> getCurrentGoldPrice() async {
    return await _firestoreService.getCurrentGoldPrice();
  }
}
