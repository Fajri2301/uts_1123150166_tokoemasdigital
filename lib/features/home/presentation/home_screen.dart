import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/services/firestore_service.dart';
import '../../common/widgets/custom_input_field.dart';
import '../../features/digital_gold/presentation/digital_gold_screen.dart';
import '../../features/physical_gold/presentation/physical_gold_screen.dart';
import '../../features/tracking/presentation/tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  
  double goldPrice = 0.0;
  double userGoldBalance = 0.0;
  String userName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUserById(user.uid);
      if (userData != null && mounted) {
        setState(() {
          userName = userData['name'] ?? 'User';
          userGoldBalance = (userData['gold_balance'] ?? 0.0).toDouble();
        });
      }

      final goldPrice = await _firestoreService.getCurrentGoldPrice();
      if (mounted) {
        setState(() {
          this.goldPrice = goldPrice;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadUserData();
  }

  Future<void> _handleLogout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFFFFD700),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.padding),
                  children: [
                    // A. Header
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.spacingLarge),

                    // B. Card Harga Emas (150 px)
                    _buildGoldPriceCard(),
                    const SizedBox(height: AppSpacing.spacingLarge),

                    // C. Quick Menu
                    _buildQuickMenu(),
                    const SizedBox(height: AppSpacing.spacingXLarge),

                    // D. Portfolio
                    _buildPortfolioCard(),
                    const SizedBox(height: AppSpacing.spacingXLarge),

                    // E. Catalog - Grid Produk
                    _buildCatalogSection(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Search Bar (50 px tinggi, radius 40 px)
        Expanded(
          child: Container(
            height: AppDimensions.searchBarHeight,
            child: CustomInputField(
              hintText: 'Cari produk emas...',
              controller: _searchController,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacingMedium),
        // Profile Icon (32 px)
        GestureDetector(
          onTap: _handleLogout,
          child: Container(
            width: AppDimensions.profileIconSize,
            height: AppDimensions.profileIconSize,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person,
              size: 20,
              color: Color(0xFF0D0D0D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoldPriceCard() {
    return Container(
      height: AppDimensions.mainCardHeight,
      padding: const EdgeInsets.all(AppSpacing.padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              Icon(
                Icons.show_chart,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Harga Emas Hari Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.formatRupiah(goldPrice),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'per gram',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildQuickMenuItem(
                icon: Icons.account_balance_wallet,
                label: 'Emas Digital',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DigitalGoldScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.spacingMedium),
            Expanded(
              child: _buildQuickMenuItem(
                icon: Icons.diamond,
                label: 'Emas Fisik',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PhysicalGoldScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spacingLarge),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCard() {
    double portfolioValue = userGoldBalance * goldPrice;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Emas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Emas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatGram(userGoldBalance),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Nilai Rupiah',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatRupiah(portfolioValue),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Produk Emas Fisik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PhysicalGoldScreen(),
                  ),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingMedium),
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getProductsByCategory('cincin'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Terjadi kesalahan', style: TextStyle(color: Colors.white)),
              );
            }

            if (!snapshot.hasData) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                ),
              );
            }

            final products = snapshot.data!.docs;

            if (products.isEmpty) {
              return Container(
                height: 200,
                alignment: Alignment.center,
                child: const Text(
                  'Belum ada produk',
                  style: TextStyle(color: Color(0xFFB0B0B0)),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppDimensions.gridColumns,
                crossAxisSpacing: AppSpacing.spacingMedium,
                mainAxisSpacing: AppSpacing.spacingMedium,
                childAspectRatio: AppDimensions.gridAspectRatio,
              ),
              itemCount: products.length > 4 ? 4 : products.length,
              itemBuilder: (context, index) {
                final product = products[index].data() as Map<String, dynamic>;
                return _buildProductCard(product);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail
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
              child: Text(
                product['name'] ?? 'Produk',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacingSmall,
              ),
              child: Text(
                CurrencyFormatter.formatRupiah((product['price'] ?? 0.0).toDouble()),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
