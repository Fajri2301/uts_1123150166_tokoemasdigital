class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;
  final int stock;
  final bool isAvailable;
  final DateTime? createdAt;
  final double weight;
  final int karat;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.stock = 0,
    required this.isAvailable,
    this.createdAt,
    this.weight = 1.0,
    this.karat = 24,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Lainnya',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isAvailable: (json['stock'] != null && json['stock'] > 0),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      karat: (json['karat'] as num?)?.toInt() ?? 24,
    );
  }

  factory ProductModel.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Lainnya',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isAvailable: data['is_available'] ?? true,
      weight: (data['weight'] as num?)?.toDouble() ?? 1.0,
      karat: (data['karat'] as num?)?.toInt() ?? 24,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'stock': stock,
      'is_available': isAvailable,
      'weight': weight,
      'karat': karat,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
