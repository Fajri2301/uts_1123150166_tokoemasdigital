import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/network/api_client.dart';

class GoldPriceChart extends StatefulWidget {
  const GoldPriceChart({super.key});

  @override
  State<GoldPriceChart> createState() => _GoldPriceChartState();
}

class _GoldPriceChartState extends State<GoldPriceChart> {
  String selectedFilter = '1M';
  final List<String> filters = ['1D', '1W', '1M', '1Y', 'ALL'];

  List<FlSpot> _spots = [];
  double _currentPrice = 0.0;
  double _previousPrice = 0.0;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchHistory();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await ApiClient().dio.get('/gold-price/history');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        if (data.isNotEmpty) {
          final reversedData = data.reversed.toList();
          List<FlSpot> spots = [];
          for (int i = 0; i < reversedData.length; i++) {
            spots.add(FlSpot(i.toDouble(), (reversedData[i]['price_per_gram'] as num).toDouble()));
          }
          
          setState(() {
            _spots = spots;
            _currentPrice = (data.first['price_per_gram'] as num).toDouble();
            if (data.length > 1) {
              _previousPrice = (data[1]['price_per_gram'] as num).toDouble();
            } else {
              _previousPrice = _currentPrice;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Failed to fetch history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
    }

    double diff = _currentPrice - _previousPrice;
    double percent = _previousPrice > 0 ? (diff / _previousPrice) * 100 : 0.0;
    bool isUp = diff >= 0;
    String sign = isUp ? '+' : '';
    Color statusColor = isUp ? AppColors.success : AppColors.error;

    double minY = _spots.isEmpty ? 0 : _spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = _spots.isEmpty ? 1 : _spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double padding = (maxY - minY) * 0.1;
    if (padding == 0) padding = _currentPrice * 0.01;
    minY -= padding;
    maxY += padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Current Price
        const Text(
          'Harga Emas Hari Ini',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.monetization_on, color: AppColors.primaryGold, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${CurrencyFormatter.formatRupiah(_currentPrice)} /gr',
                  style: const TextStyle(
                    fontFamily: 'Roboto Mono',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLightGold,
                  ),
                ),
                Text(
                  '$sign${CurrencyFormatter.formatRupiah(diff.abs())} ($sign${percent.abs().toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Filters
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: filters.map((f) {
            bool isActive = f == selectedFilter;
            return GestureDetector(
              onTap: () => setState(() => selectedFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.darkGray : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Chart
        SizedBox(
          height: 180,
          child: LineChart(
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
                drawVerticalLine: false,
                horizontalInterval: padding > 0 ? padding * 2 : 10000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.darkGray.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: false,
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: _spots.isEmpty ? 1 : _spots.last.x,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: _spots.isEmpty ? [const FlSpot(0, 0)] : _spots,
                  isCurved: true,
                  color: statusColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.3),
                        statusColor.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
