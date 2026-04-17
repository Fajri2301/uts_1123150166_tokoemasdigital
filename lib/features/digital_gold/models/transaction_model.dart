import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction Model for Digital Gold
class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'digital' or 'fisik'
  final double goldAmount;
  final double pricePerGram;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.goldAmount,
    required this.pricePerGram,
    required this.totalPrice,
    required this.status,
    this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      type: data['type'] ?? 'digital',
      goldAmount: (data['gold_amount'] ?? 0.0).toDouble(),
      pricePerGram: (data['price_per_gram'] ?? 0.0).toDouble(),
      totalPrice: (data['total_price'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'type': type,
      'gold_amount': goldAmount,
      'price_per_gram': pricePerGram,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
