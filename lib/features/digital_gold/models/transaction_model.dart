class TransactionModel {
  final int id;
  final int userId;
  final int? productId;
  final String type; // 'buy_digital', 'sell_digital', 'physical_checkout'
  final double grams;
  final double totalPrice;
  final String status; // 'pending', 'success', 'failed'
  final String paymentMethod;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    this.productId,
    required this.type,
    required this.grams,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      productId: json['product_id'],
      type: json['type'] ?? '',
      grams: (json['grams'] ?? 0.0).toDouble(),
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      address: json['address'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
