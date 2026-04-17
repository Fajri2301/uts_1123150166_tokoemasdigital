import 'package:cloud_firestore/cloud_firestore.dart';

/// Product Model for Physical Gold
class ProductModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final String description;
  final String imageUrl;
  final int karat;
  final int weight;
  final bool isAvailable;
  final String sellerId;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.karat,
    required this.weight,
    required this.isAvailable,
    required this.sellerId,
    this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Lainnya',
      price: (data['price'] ?? 0).toInt(),
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      karat: (data['karat'] ?? 24).toInt(),
      weight: (data['weight'] ?? 0).toInt(),
      isAvailable: data['is_available'] ?? true,
      sellerId: data['seller_id'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'karat': karat,
      'weight': weight,
      'is_available': isAvailable,
      'seller_id': sellerId,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  ProductModel copyWith({
    String? name,
    String? category,
    int? price,
    String? description,
    String? imageUrl,
    int? karat,
    int? weight,
    bool? isAvailable,
    String? sellerId,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      karat: karat ?? this.karat,
      weight: weight ?? this.weight,
      isAvailable: isAvailable ?? this.isAvailable,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
