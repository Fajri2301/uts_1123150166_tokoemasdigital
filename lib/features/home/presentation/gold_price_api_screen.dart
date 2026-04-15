import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../services/gold_price_api_service.dart';
import '../services/firestore_service.dart';

class GoldPriceApiScreen extends StatefulWidget {
  const GoldPriceApiScreen({Key? key}) : super(key: key);

  @override
  State<GoldPriceApiScreen> createState() => _GoldPriceApiScreenState();
}

class _GoldPriceApiScreenState extends State<GoldPriceApiScreen> {
  final GoldPriceApiService _goldPriceApiService = GoldPriceApiService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _isInitialLoading = true;
  double _currentPrice = 0.0;
  String _source = '';
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _loadCurrentPrice();
  }

  Future<void> _loadCurrentPrice() async {
    try {
      final price = await _firestoreService.getCurrentGoldPrice();
      if (mounted) {
        setState(() {
          _currentPrice = price;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPrice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final price = await _goldPriceApiService.updateGoldPrice();
      if (mounted) {
        setState(() {
          _currentPrice = price;
          _source = 'Live API';
          _updatedAt = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harga emas berhasil diupdate dari API'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update dari API: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSimulatedPrice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final priceData = _goldPriceApiService.getSimulatedGoldPrice();
      await _goldPriceApiService.saveGoldPriceToFirestore(priceData);
      
      if (mounted) {
        setState(() {
          _currentPrice = priceData['price_per_gram'];
          _source = 'Simulasi';
          _updatedAt = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harga simulasi berhasil dimuat'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal muat harga: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          'Harga Emas Live',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshPrice,
              color: const Color(0xFFFFD700),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.padding),
                children: [
                  // Current Price Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.padding),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Harga Emas Saat Ini',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB0B0B0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.formatRupiah(_currentPrice),
                          style: const TextStyle(
                            fontSize: 36,
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
                        if (_source.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Sumber: $_source',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ),
                        ],
                        if (_updatedAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Update: ${CurrencyFormatter.formatDate(_updatedAt!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB0B0B0),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spacingMedium),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi API',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Aplikasi akan fetch harga dari Live API saat dibuka\n'
                          '• Jika API gagal, gunakan harga simulasi\n'
                          '• Harga disimpan di Firestore untuk performa\n'
                          '• Pull-to-refresh untuk update manual',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB0B0B0),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  SizedBox(
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _refreshPrice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF0D0D0D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D0D0D)),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update dari Live API',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loadSimulatedPrice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFFFFD700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                        side: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      child: const Text(
                        'Gunakan Harga Simulasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
