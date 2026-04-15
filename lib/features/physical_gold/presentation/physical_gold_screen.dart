import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../services/physical_gold_service.dart';
import 'product_detail_screen.dart';

class PhysicalGoldScreen extends StatefulWidget {
  const PhysicalGoldScreen({Key? key}) : super(key: key);

  @override
  State<PhysicalGoldScreen> createState() => _PhysicalGoldScreenState();
}

class _PhysicalGoldScreenState extends State<PhysicalGoldScreen> {
  final PhysicalGoldService _physicalGoldService = PhysicalGoldService();
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<String> get _categories => ['all', ..._physicalGoldService.getCategories()];

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'Semua';
      case 'cincin':
        return 'Cincin';
      case 'gelang':
        return 'Gelang';
      case 'kalung':
        return 'Kalung';
      case 'anting':
        return 'Anting';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emas Fisik',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.padding),
            child: Container(
              height: AppDimensions.searchBarHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSearchBar),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: const TextStyle(color: Color(0xFF666666)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.padding,
                    vertical: 12,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.spacingSmall),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: const Color(0xFF1A1A1A),
                    selectedColor: const Color(0xFFFFD700).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFB0B0B0),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.spacingMedium),

          // Product Grid
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    Stream<QuerySnapshot> productsStream;
    
    if (_selectedCategory == 'all') {
      productsStream = _physicalGoldService.getAllProducts();
    } else {
      productsStream = _physicalGoldService.getProductsByCategory(_selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Terjadi kesalahan',
              style: const TextStyle(color: Color(0xFFF44336)),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          );
        }

        var products = snapshot.data!.docs;

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          products = products.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toLowerCase();
            return name.contains(_searchQuery);
          }).toList();
        }

        if (products.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada produk ditemukan',
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.padding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppDimensions.gridColumns,
            crossAxisSpacing: AppSpacing.spacingMedium,
            mainAxisSpacing: AppSpacing.spacingMedium,
            childAspectRatio: AppDimensions.gridAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index].data() as Map<String, dynamic>;
            final productId = products[index].id;
            return _buildProductCard(product, productId);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, String productId) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              productId: productId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusCard),
                ),
                child: product['image_url'] != null && product['image_url'].isNotEmpty
                    ? Image.network(
                        product['image_url'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1A1A1A),
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Color(0xFF666666),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF1A1A1A),
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Color(0xFF666666),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spacingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Produk',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatRupiah((product['price'] ?? 0.0).toDouble()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w600,
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
}
