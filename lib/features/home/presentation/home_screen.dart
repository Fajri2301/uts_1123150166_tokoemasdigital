import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/constants/app_dimensions.dart';
import 'package:toko_emas_digital/common/widgets/product_card.dart';
import 'package:toko_emas_digital/common/widgets/feature_icon.dart';
import 'package:toko_emas_digital/common/widgets/app_avatar.dart';
import 'package:toko_emas_digital/common/widgets/app_logo.dart';
import 'package:toko_emas_digital/features/digital_gold/services/catalog_service.dart';
import 'package:toko_emas_digital/features/physical_gold/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:toko_emas_digital/features/physical_gold/presentation/product_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/buy_gold_screen.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/sell_gold_screen.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/withdraw_screen.dart';
import 'package:toko_emas_digital/features/transactions/presentation/transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _handleRefresh() async {
    // Delay to let the refresh animation play
    await Future.delayed(const Duration(milliseconds: 800));
    // Trigger rebuild to re-fetch FutureBuilder data
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 12, 20, 94),
              child: Row(
                children: [
                  AppAvatar(
                      name: 'Fajri',
                      size: 44,
                      bg: Colors.white.withValues(alpha: 0.25)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat datang,',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            )),
                        Text(FirebaseAuth.instance.currentUser?.displayName ?? 'Pengguna',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            )),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            size: 21, color: Colors.white),
                      ),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Balance Card (overlaps the header's bottom edge)
            Transform.translate(
              offset: const Offset(0, -46),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGoldBalanceCard(context),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildGoldPriceRow(),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildQuickActions(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle('Katalog Produk'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildProductCatalog(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildGoldBalanceCard(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': 'Beli',
        'tone': 'gold',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyGoldScreen()))
      },
      {
        'icon': Icons.sell_outlined,
        'label': 'Jual',
        'tone': 'red',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellGoldScreen()))
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'label': 'Tukar',
        'tone': 'violet',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih emas fisik di bawah lalu bayar dengan Saldo Emas Digital'))
          );
        }
      },
      {
        'icon': Icons.history_rounded,
        'label': 'Riwayat',
        'tone': 'slate',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()))
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.shadowCard,
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  const AppLogo(size: 26, light: false),
                  const SizedBox(width: 7),
                  const Text('Saldo Emas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate500,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, double>>(
            future: TransactionService().getWalletBalance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final balances = snapshot.data ?? {'grams': 0.0, 'rupiah': 0.0};
              final grams = balances['grams']!;
              final rupiah = balances['rupiah']!;
              final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
              
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${grams.toStringAsFixed(3)} gr',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Total Gram', style: TextStyle(color: AppColors.slate500, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.line2, margin: const EdgeInsets.symmetric(horizontal: 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyFormat.format(rupiah),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saldo Tunai', style: TextStyle(color: AppColors.slate500, fontSize: 11, fontWeight: FontWeight.w600)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
                              child: const Text('Tarik', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line2)),
            ),
            child: Row(
              children: actions.map((a) {
                return Expanded(
                  child: GestureDetector(
                    onTap: a['onTap'] as VoidCallback,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          FeatureIcon(
                            icon: a['icon'] as IconData,
                            tone: a['tone'] as String,
                            size: 46,
                            iconSize: 22,
                          ),
                          const SizedBox(height: 7),
                          Text(a['label'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate600,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldPriceRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.shadowSoft,
            ),
            child: Row(
              children: [
                const FeatureIcon(
                    icon: Icons.trending_up_rounded, tone: 'green', size: 38, iconSize: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Harga Beli',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w600)),
                      Text('Rp 1.230.000',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.shadowSoft,
            ),
            child: Row(
              children: [
                const FeatureIcon(
                    icon: Icons.trending_down_rounded, tone: 'red', size: 36, iconSize: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Harga Jual',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w600)),
                      Text('Rp 1.150.000',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final features = [
      {'icon': Icons.storefront_outlined, 'label': 'Fisik', 'tone': 'gold'},
      {'icon': Icons.diamond_outlined, 'label': 'Perhiasan', 'tone': 'violet'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Tracking', 'tone': 'blue'},
      {'icon': Icons.admin_panel_settings_outlined, 'label': 'Admin', 'tone': 'red'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowSoft,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: features.map((f) {
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureIcon(
                    icon: f['icon'] as IconData, tone: f['tone'] as String, size: 50, iconSize: 24),
                const SizedBox(height: 8),
                Text(f['label'] as String,
                    style: const TextStyle(
                      fontSize: 11.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate600,
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Lihat Semua',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCatalog() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return StreamBuilder<List<ProductModel>>(
      stream: CatalogService().getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: AppColors.slate600)),
          );
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(
            child: Text('Katalog produk masih kosong.',
                style: TextStyle(color: AppColors.slate500)),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppDimensions.gridColumns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: AppDimensions.gridAspectRatio,
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
        );
      },
    );
  }
}
