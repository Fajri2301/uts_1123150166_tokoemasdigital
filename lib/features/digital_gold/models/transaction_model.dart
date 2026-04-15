import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final String category;
  final int karat;
  final int weight;
  final bool isAvailable;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.karat,
    required this.weight,
    required this.isAvailable,
    this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toInt(),
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? 'Lainnya',
      karat: (data['karat'] ?? 24).toInt(),
      weight: (data['weight'] ?? 0).toInt(),
      isAvailable: data['is_available'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final int goldBalance;
  final String phoneNumber;
  final String address;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.goldBalance,
    required this.phoneNumber,
    required this.address,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      goldBalance: (data['gold_balance'] ?? 0).toInt(),
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
    );
  }
}
