import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/common/widgets/gold_button.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/buy_gold_screen.dart';
import 'package:toko_emas_digital/features/digital_gold/presentation/sell_gold_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  double _grams = 0.0;
  double _rupiahBalance = 0.0;
  double _currentPrice = 0.0;
  double _currentAssetValue = 0.0;
  double _roiPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
  }

  Future<void> _fetchPortfolio() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiClient().dio.get('/user/portfolio');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _grams = (data['grams'] as num).toDouble();
          _rupiahBalance = (data['rupiah_balance'] as num).toDouble();
          _currentPrice = (data['current_price'] as num).toDouble();
          _currentAssetValue = (data['current_asset_value'] as num).toDouble();
          _roiPercentage = (data['roi_percentage'] as num).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data portofolio. Pastikan server berjalan.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchPortfolio,
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100), // Spacing for bottom nav
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portofolio Aset',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pantau perkembangan investasi emas Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: AppColors.primaryGold),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildMainCard(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                        const SizedBox(height: 32),
                        _buildChartSection(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    final isProfit = _roiPercentage >= 0;
    final roiColor = isProfit ? Colors.greenAccent : Colors.redAccent;
    final roiIcon = isProfit ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Nilai Aset',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roiColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(roiIcon, size: 12, color: roiColor),
                    const SizedBox(width: 4),
                    Text(
                      '${_roiPercentage.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: roiColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatRupiah(_currentAssetValue),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSubInfo(
                  'Saldo Emas',
                  CurrencyFormatter.formatGram(_grams),
                  Icons.monitor_weight_outlined,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.darkGray,
              ),
              Expanded(
                child: _buildSubInfo(
                  'Harga Saat Ini',
                  CurrencyFormatter.formatRupiah(_currentPrice),
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubInfo(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GoldButton(
            text: 'Beli',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyGoldScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GoldButton(
            text: 'Jual',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellGoldScreen()),
              );
            },
            isSecondary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Grafik Harga (Simulasi)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_graph_rounded, color: Colors.blueAccent, size: 14),
                  SizedBox(width: 4),
                  Text('AI Prediksi: Naik 85%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 220,
          padding: const EdgeInsets.only(right: 16, left: 16, top: 24, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.darkGray.withValues(alpha: 0.3)),
          ),
          child: _buildFlChart(),
        ),
      ],
    );
  }

  Widget _buildFlChart() {
    // Simulator data for beautiful chart presentation
    final List<FlSpot> spots = [
      FlSpot(0, _currentPrice * 0.93),
      FlSpot(1, _currentPrice * 0.96),
      FlSpot(2, _currentPrice * 0.94),
      FlSpot(3, _currentPrice * 0.98),
      FlSpot(4, _currentPrice * 0.95),
      FlSpot(5, _currentPrice * 0.99),
      FlSpot(6, _currentPrice),
    ];

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot touchedSpot) => AppColors.surface,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  CurrencyFormatter.formatRupiah(spot.y),
                  const TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: _currentPrice * 0.02,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.darkGray.withValues(alpha: 0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.darkGray.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.darkGray.withValues(alpha: 0.5), width: 1),
            left: const BorderSide(color: Colors.transparent),
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        minX: -0.2,
        maxX: 6.2,
        minY: _currentPrice * 0.92,
        maxY: _currentPrice * 1.02,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryGold,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryGold,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.3),
                  AppColors.primaryGold.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
