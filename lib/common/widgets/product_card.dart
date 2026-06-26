import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String description; // Might be unused in this UI, but kept for compatibility
  final String imageUrl;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.onTap,
  });

  ImageProvider _getImageProvider(String url) {
    if (url.contains('base64,')) {
      try {
        final base64String = url.split(',').last;
        final Uint8List bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        // Fallback handled below or will throw
      }
    }
    if (url.isNotEmpty && url != 'placeholder') {
      return NetworkImage(url);
    }
    return const NetworkImage('https://via.placeholder.com/150');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGray.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: _getImageProvider(imageUrl), fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      '99.9%', 
                      style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name, 
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            const Text(
              '24 Karat', 
              style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              price, 
              style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 14, color: AppColors.primaryGold),
            ),
          ],
        ),
      ),
    );
  }
}
