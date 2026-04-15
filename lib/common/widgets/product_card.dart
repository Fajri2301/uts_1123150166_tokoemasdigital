import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/constants/app_dimensions.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String description;
  final String imageUrl;
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.divider.toColor(),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (Handles Network and Base64)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusCard),
                  ),
                ),
                child: _buildImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.textPrimary.toColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary.toColor(),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: TextStyle(
                      color: AppColors.goldAccent.toColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isEmpty || imageUrl == 'placeholder') {
      return Icon(Icons.image_outlined, color: AppColors.goldAccent.toColor(), size: 40);
    }

    // Handle Base64
    if (imageUrl.contains('base64,')) {
      try {
        final base64String = imageUrl.split(',').last;
        final Uint8List bytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusCard)),
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      } catch (e) {
        return Icon(Icons.error_outline, color: AppColors.error.toColor());
      }
    }

    // Handle Network Image
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusCard)),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image_outlined, color: AppColors.goldAccent.toColor(), size: 40),
      ),
    );
  }
}
