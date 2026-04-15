class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'digital' or 'fisik'
  final double goldAmount;
  final String? productId;
  final String status; // 'pending', 'diproses', 'dikirim', 'selesai'
  final String? address;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.goldAmount,
    this.productId,
    this.status = 'pending',
    this.address,
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      userId: data['user_id'] ?? '',
      type: data['type'] ?? 'digital',
      goldAmount: (data['gold_amount'] ?? 0.0).toDouble(),
      productId: data['product_id'],
      status: data['status'] ?? 'pending',
      address: data['address'],
      createdAt: (data['created_at'] as DateTime? ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'type': type,
      'gold_amount': goldAmount,
      'product_id': productId,
      'status': status,
      'address': address,
      'created_at': createdAt,
    };
  }
}
