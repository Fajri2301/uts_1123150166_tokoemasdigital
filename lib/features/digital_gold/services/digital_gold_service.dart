import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';

class DigitalGoldService {
  final FirestoreService _firestoreService = FirestoreService();

  // Buy digital gold
  Future<bool> buyGold({
    required String userId,
    required double gramAmount,
    required double pricePerGram,
  }) async {
    try {
      // Get current balance
      final userData = await _firestoreService.getUserById(userId);
      if (userData == null) return false;

      double currentBalance = (userData['gold_balance'] ?? 0.0).toDouble();
      double newBalance = currentBalance + gramAmount;
      double totalPrice = gramAmount * pricePerGram;

      // Update balance
      await _firestoreService.updateUserGoldBalance(userId, newBalance);

      // Create transaction record
      await _firestoreService.addTransaction({
        'user_id': userId,
        'type': 'digital',
        'gold_amount': gramAmount,
        'price_per_gram': pricePerGram,
        'total_price': totalPrice,
        'status': 'selesai',
        'created_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to buy gold: $e');
    }
  }

  // Convert digital gold to physical (batangan)
  Future<bool> convertToPhysical({
    required String userId,
    required double gramAmount,
    required String address,
  }) async {
    try {
      // Get current balance
      final userData = await _firestoreService.getUserById(userId);
      if (userData == null) return false;

      double currentBalance = (userData['gold_balance'] ?? 0.0).toDouble();
      
      if (currentBalance < gramAmount) {
        throw Exception('Saldo emas tidak mencukupi');
      }

      double newBalance = currentBalance - gramAmount;

      // Update balance
      await _firestoreService.updateUserGoldBalance(userId, newBalance);

      // Create physical transaction
      await _firestoreService.addDocument('transactions', {
        'user_id': userId,
        'type': 'fisik',
        'gold_amount': gramAmount,
        'product_id': 'batangan',
        'status': 'diproses',
        'address': address,
        'created_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to convert gold: $e');
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
