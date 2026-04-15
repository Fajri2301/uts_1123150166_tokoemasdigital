class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final double goldBalance;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.goldBalance = 0.0,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      goldBalance: (data['gold_balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'gold_balance': goldBalance,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    double? goldBalance,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      goldBalance: goldBalance ?? this.goldBalance,
    );
  }
}
