import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/constants/app_dimensions.dart';

// Extension to convert Hex String to Color
extension HexColor on String {
  Color toColor() {
    return Color(int.parse(replaceFirst('#', '0xff')));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildGoldBalanceCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildGoldPriceCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Katalog Produk'),
              const SizedBox(height: 16),
              _buildProductCatalog(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header Section
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Fajri!',
              style: TextStyle(
                color: AppColors.textPrimary.toColor(),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Investasi emas hari ini?',
              style: TextStyle(
                color: AppColors.textSecondary.toColor(),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.divider.toColor(),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: AppColors.goldAccent.toColor(),
          ),
        ),
      ],
    );
  }

  // 2. Gold Balance Card (E-Wallet Style)
  Widget _buildGoldBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.divider.toColor(),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.goldAccent.toColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.goldAccent.toColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Saldo Emas Digital',
                style: TextStyle(
                  color: AppColors.textPrimary.toColor(),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '1.245 gram',
            style: TextStyle(
              color: AppColors.goldAccent.toColor(),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '≈ Rp 1.543.000',
            style: TextStyle(
              color: AppColors.textSecondary.toColor(),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Quick Actions Grid
  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Beli Emas'},
      {'icon': Icons.sell_outlined, 'label': 'Jual Emas'},
      {'icon': Icons.swap_horiz_outlined, 'label': 'Konversi'},
      {'icon': Icons.history_outlined, 'label': 'Riwayat'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.divider.toColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                actions[index]['icon'] as IconData,
                color: AppColors.goldAccent.toColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              actions[index]['label'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary.toColor(),
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  // 4. Gold Price Card
  Widget _buildGoldPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harga Beli Emas',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp 1.230.000/gr',
                style: TextStyle(
                  color: AppColors.goldAccent.toColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.white24,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harga Jual Emas',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp 1.150.000/gr',
                style: TextStyle(
                  color: AppColors.textPrimary.toColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Product Catalog Grid
  Widget _buildProductCatalog() {
    // Mock data for catalog
    final products = [
      {'name': 'Cincin Emas 24K', 'price': 'Rp 2.500.000', 'weight': '2 gr'},
      {'name': 'Kalung Berlian', 'price': 'Rp 15.200.000', 'weight': '5 gr'},
      {'name': 'Gelang Rose Gold', 'price': 'Rp 5.400.000', 'weight': '3 gr'},
      {'name': 'Anting Minimalis', 'price': 'Rp 1.200.000', 'weight': '1 gr'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppDimensions.gridColumns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: AppDimensions.gridAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.divider.toColor(),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder image
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusCard),
                  ),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.goldAccent.toColor(),
                  size: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      products[index]['name']!,
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
                      products[index]['weight']!,
                      style: TextStyle(
                        color: AppColors.textSecondary.toColor(),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      products[index]['price']!,
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
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary.toColor(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Lihat Semua',
          style: TextStyle(
            color: AppColors.goldAccent.toColor(),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
