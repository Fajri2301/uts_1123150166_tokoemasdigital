import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/app_field.dart';
import '../services/digital_gold_service.dart';
import '../../../core/utils/currency_formatter.dart';
import 'checkout_gold_screen.dart';

class ConvertGoldScreen extends StatefulWidget {
  const ConvertGoldScreen({super.key});

  @override
  State<ConvertGoldScreen> createState() => _ConvertGoldScreenState();
}

class _ConvertGoldScreenState extends State<ConvertGoldScreen> {
  final _digitalGoldService = DigitalGoldService();
  bool _isLoading = false;
  double _userBalance = 0.0;

  final List<Map<String, dynamic>> _catalogItems = [
    {
      'name': '1g Gold Bar',
      'purity': '999.9 Purity',
      'weight': 1.0,
      'image': 'https://images.unsplash.com/photo-1610375461246-83df859d849d?auto=format&fit=crop&q=80&w=600',
      'tag': 'IN STOCK'
    },
    {
      'name': '5g Gold Bar',
      'purity': 'Certified LBMA',
      'weight': 5.0,
      'image': 'https://images.unsplash.com/photo-1610375279624-b13180b5fa86?auto=format&fit=crop&q=80&w=600',
      'tag': 'POPULAR'
    },
    {
      'name': 'Gold Ring Elegant',
      'purity': '22K Solid',
      'weight': 8.4,
      'image': 'https://images.unsplash.com/photo-1605100804763-247f66156ce4?auto=format&fit=crop&q=80&w=600',
      'tag': ''
    },
    {
      'name': 'Gold Bracelet',
      'purity': '24K Artisan',
      'weight': 15.2,
      'image': 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?auto=format&fit=crop&q=80&w=600',
      'tag': ''
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await _digitalGoldService.getBalance();
    if (mounted) {
      setState(() => _userBalance = balance);
    }
  }

  void _showCheckoutSheet(Map<String, dynamic> item) {
    if (_userBalance < item['weight']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo emas digital Anda tidak cukup untuk menukar item ini.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutGoldScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Gold Store', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1611591437281-460bfbe1220a?auto=format&fit=crop&q=80&w=600'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(AppColors.surface.withValues(alpha: 0.8), BlendMode.darken),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EXCLUSIVE ASSET COLLECTION',
                      style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLightGold, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tukar Saldo Anda dengan Emas Murni',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saldo saat ini: ${_userBalance.toStringAsFixed(3)} gr',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.primaryGold, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Catalog Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Curated Inventory',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),

            // Product Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: _catalogItems.length,
              itemBuilder: (context, index) {
                final item = _catalogItems[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(item['image'], fit: BoxFit.cover),
                            ),
                            if (item['tag'] != '')
                              Positioned(
                                top: 8, left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.bg.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    item['tag'],
                                    style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 9, color: AppColors.primaryLightGold, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Details
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['purity'],
                              style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 10, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${item['weight']} gr',
                              style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryLightGold),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Tukar',
                              size: AppButtonSize.sm,
                              onPressed: () => _showCheckoutSheet(item),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
