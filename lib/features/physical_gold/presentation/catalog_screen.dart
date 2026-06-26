import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/constants/app_dimensions.dart';
import 'package:toko_emas_digital/common/widgets/product_card.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:toko_emas_digital/features/digital_gold/services/catalog_service.dart';
import 'package:toko_emas_digital/features/physical_gold/models/product_model.dart';
import 'package:toko_emas_digital/features/physical_gold/presentation/product_detail_screen.dart';
import 'package:intl/intl.dart';

class CatalogScreen extends StatefulWidget {
  final String? categoryFilter;

  const CatalogScreen({super.key, this.categoryFilter});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CatalogService _catalogService = CatalogService();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: CustomAppBar(title: widget.categoryFilter != null ? 'Katalog ${widget.categoryFilter}' : 'Katalog Emas Fisik'),
      body: StreamBuilder<List<ProductModel>>(
        stream: _catalogService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat katalog: ${snapshot.error}', style: const TextStyle(color: AppColors.error)),
            );
          }

          var products = snapshot.data ?? [];
          
          if (widget.categoryFilter != null) {
            products = products.where((p) => p.category.toLowerCase().contains(widget.categoryFilter!.toLowerCase())).toList();
          }

          if (products.isEmpty) {
            return Center(
              child: Text(
                widget.categoryFilter != null 
                  ? 'Belum ada produk untuk kategori ${widget.categoryFilter}.'
                  : 'Belum ada produk emas fisik.', 
                style: const TextStyle(color: AppColors.textSecondary)
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  name: product.name,
                  price: currencyFormat.format(product.price),
                  description: product.description,
                  imageUrl: product.imageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: product.id,
                          product: {
                            'name': product.name,
                            'description': product.description,
                            'price': product.price,
                            'image_url': product.imageUrl,
                            'category': 'Emas Fisik',
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
