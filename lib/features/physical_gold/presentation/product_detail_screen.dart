import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../common/widgets/gold_button.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final String productId;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = product['name'] ?? 'Produk';
    final String description = product['description'] ?? 'Tidak ada deskripsi';
    final double price = (product['price'] ?? 0.0).toDouble();
    final String imageUrl = product['image_url'] ?? '';
    final String category = product['category'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (200 px)
            Container(
              height: AppDimensions.productImageHeight,
              width: double.infinity,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1A1A1A),
                          child: const Icon(
                            Icons.image,
                            size: 80,
                            color: Color(0xFF666666),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Icon(
                        Icons.image,
                        size: 80,
                        color: Color(0xFF666666),
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.spacingXLarge),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  if (category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  if (category.isNotEmpty) const SizedBox(height: 12),

                  // Nama (font 18-20)
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Harga
                  Text(
                    CurrencyFormatter.formatRupiah(price),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B0B0),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buy Button
                  GoldButton(
                    text: 'Beli Sekarang',
                    onPressed: () {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan login terlebih dahulu'),
                            backgroundColor: Color(0xFFF44336),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            productId: productId,
                            productName: name,
                            price: price,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
