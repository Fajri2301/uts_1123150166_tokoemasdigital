import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/features/physical_gold/models/product_model.dart';
import '../services/admin_service.dart';
import 'add_edit_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final AdminService _adminService = AdminService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _adminService.getAllProducts();
      if (mounted) {
        setState(() {
          _products = data.map((item) {
            final m = item as Map<String, dynamic>;
            return ProductModel(
              id: m['id'].toString(),
              name: m['name'] ?? '',
              description: m['description'] ?? '',
              price: (m['price'] ?? 0).toDouble(),
              imageUrl: m['image_url'] ?? '',
              weight: (m['weight'] ?? 1.0).toDouble(),
              category: m['category'] ?? '',
              stock: m['stock'] ?? 0,
              isAvailable: m['is_available'] ?? true,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            title: const Text('Kelola Produk',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(Icons.add_circle_rounded, color: AppColors.primaryGold, size: 28),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddEditProductScreen()));
                  _loadProducts();
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari produk atau kategori...',
                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _loadProducts,
          color: AppColors.primaryGold,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB38922)))
              : _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              Text('${_filteredProducts.length} Produk',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Total stok: ${_products.fold<int>(0, (s, p) => s + p.stock)}',
                                  style: TextStyle(color: AppColors.primaryGold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (_, i) => _ProductCard(
                              product: _filteredProducts[i],
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditProductScreen(product: _filteredProducts[i]),
                                  ),
                                );
                                _loadProducts();
                              },
                              onDelete: () => _confirmDelete(_filteredProducts[i]),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(_searchQuery.isEmpty ? 'Belum ada produk' : 'Produk tidak ditemukan',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Produk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddEditProductScreen()));
                _loadProducts();
              },
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            const Text('Hapus Produk', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          'Yakin hapus "${product.name}"?\nTindakan ini tidak bisa dibatalkan.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.deleteProduct(product.id);
                _loadProducts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk berhasil dihapus'),
                      backgroundColor: Color(0xFF22C55E),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ── Product Card Widget ──
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit, onDelete;
  const _ProductCard({required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bool isPhysical = product.category == 'physical';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Gambar Produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: AppColors.darkGray,
                    child: _buildProductImage(),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPhysical
                                  ? AppColors.warning.withOpacity(0.15)
                                  : AppColors.info.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPhysical ? 'Fisik' : 'Digital',
                              style: TextStyle(
                                color: isPhysical ? AppColors.warning : AppColors.info,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatRupiah(product.price),
                        style: TextStyle(color: AppColors.primaryGold, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.scale_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${product.weight}g', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(width: 12),
                          Icon(Icons.inventory_outlined, size: 12,
                              color: product.stock > 0 ? AppColors.success : AppColors.error),
                          const SizedBox(width: 4),
                          Text('Stok: ${product.stock}',
                              style: TextStyle(
                                color: product.stock > 0 ? AppColors.success : AppColors.error,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.darkGray.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.edit_rounded, size: 16, color: AppColors.primaryGold),
                    label: Text('Edit', style: TextStyle(color: AppColors.primaryGold, fontSize: 13)),
                    onPressed: onEdit,
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.darkGray.withOpacity(0.5)),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_rounded, size: 16, color: Colors.redAccent),
                    label: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.imageUrl.isEmpty) {
      return Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: 32);
    }
    if (product.imageUrl.startsWith('data:image')) {
      try {
        return Image.memory(
          base64Decode(product.imageUrl.split(',').last),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
        );
      } catch (_) {
        return Icon(Icons.broken_image_outlined, color: AppColors.textSecondary);
      }
    }
    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
    );
  }
}
