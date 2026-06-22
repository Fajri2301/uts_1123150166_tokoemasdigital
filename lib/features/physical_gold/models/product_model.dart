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
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
