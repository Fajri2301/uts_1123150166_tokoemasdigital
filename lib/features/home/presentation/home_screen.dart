import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/constants/app_dimensions.dart';
import 'package:toko_emas_digital/common/widgets/product_card.dart';
import 'package:toko_emas_digital/common/widgets/feature_icon.dart';
import 'package:toko_emas_digital/common/widgets/app_avatar.dart';
import 'package:toko_emas_digital/features/digital_gold/services/catalog_service.dart';
import 'package:toko_emas_digital/features/physical_gold/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:toko_emas_digital/features/physical_gold/presentation/product_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/buy_gold_screen.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/sell_gold_screen.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/convert_gold_screen.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/withdraw_screen.dart';
import 'package:toko_emas_digital/features/transactions/presentation/transactions_screen.dart';
import 'package:toko_emas_digital/common/widgets/gold_price_chart.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/features/notifications/presentation/notifications_screen.dart';
import 'package:toko_emas_digital/features/physical_gold/presentation/catalog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Future<Map<String, double>> _walletFuture;
  late Stream<List<ProductModel>> _productsStream;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_pulseController);
    _walletFuture = TransactionService().getWalletBalance();
    _productsStream = CatalogService().getProducts().asBroadcastStream();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _walletFuture = TransactionService().getWalletBalance();
      _productsStream = CatalogService().getProducts().asBroadcastStream();
    });
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF1A150A), Colors.black],
          center: Alignment(0, -0.4),
          radius: 0.8,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24).copyWith(bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDualBalanceCard(context),
                    const SizedBox(height: 32),
                    _buildMarketChartSection(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Emas Fisik', onSeeAll: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                    }),
                    const SizedBox(height: 16),
                    _buildProductCatalog(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      elevation: 0,
      expandedHeight: 80,
      collapsedHeight: 70,
      toolbarHeight: 70,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: const AppAvatar(name: 'Invest', size: 40, bg: Colors.transparent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selamat datang,', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName ?? 'Investor Danantara',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface.withValues(alpha: 0.5),
                          ),
                          child: const Icon(Icons.notifications_rounded, color: AppColors.primaryGold, size: 24),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDualBalanceCard(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _walletFuture,
      builder: (context, snapshot) {
        final balances = snapshot.data ?? {'grams': 0.0, 'rupiah': 0.0};
        final grams = balances['grams']!;
        final rupiah = balances['rupiah']!;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Stack(
            children: [
              // Abstract gold mesh background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: RadialGradient(
                        colors: [AppColors.primaryGold, Colors.transparent],
                        center: const Alignment(0.8, -0.8),
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SALDO EMAS', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.primaryLightGold, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(grams >= 1000 ? (grams / 1000).toStringAsFixed(3) : grams.toStringAsFixed(3), style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                                  const SizedBox(width: 4),
                                  Text(grams >= 1000 ? 'kg' : 'gr', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 12, color: AppColors.primaryGold.withValues(alpha: 0.6))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppColors.primaryGold.withValues(alpha: 0.1)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('SALDO RUPIAH', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.primaryLightGold, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 12, color: AppColors.primaryGold.withValues(alpha: 0.6))),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(CurrencyFormatter.formatRupiah(rupiah).replaceAll('Rp ', ''), style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(height: 1, color: Colors.white10),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionBtn(Icons.add_shopping_cart_rounded, 'Beli', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyGoldScreen()))),
                        _buildActionBtn(Icons.sell_rounded, 'Jual', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellGoldScreen()))),
                        _buildActionBtn(Icons.sync_alt_rounded, 'Tukar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConvertGoldScreen()))),
                        _buildActionBtn(Icons.account_balance_wallet_rounded, 'Withdraw', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen()))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.4),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildMarketChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.primaryGold, AppColors.primaryDark]).createShader(bounds),
              child: const Text('Harga Pasar', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Row(
              children: [
                const Text('Live', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.primaryGold)),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              const GoldPriceChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final categories = [
      {'name': 'Cincin', 'icon': Icons.radio_button_unchecked_rounded},
      {'name': 'Kalung', 'icon': Icons.stream_rounded},
      {'name': 'Gelang', 'icon': Icons.toll_rounded},
      {'name': 'Anting', 'icon': Icons.headphones_outlined},
      {'name': 'Batangan', 'icon': Icons.view_agenda_rounded},
      {'name': 'Liontin', 'icon': Icons.diamond_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: _buildSmallActionBtn(cat['icon'] as IconData, cat['name'] as String),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSmallActionBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen(categoryFilter: label)));
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.4),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textPrimary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.primaryGold, AppColors.primaryDark]).createShader(bounds),
          child: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.primaryGold),
            ),
          )
        else
          const Text(
            'Lihat Semua',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.primaryGold),
          ),
      ],
    );
  }

  Widget _buildProductCatalog() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return StreamBuilder<List<ProductModel>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
        }

        final products = (snapshot.data ?? []).take(6).toList();
        if (products.isEmpty) {
          return const Center(child: Text('Katalog kosong.', style: TextStyle(color: AppColors.textSecondary)));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppDimensions.gridColumns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7, // Matching CatalogScreen ratio for consistency
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
