import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';

class GoldPriceChart extends StatefulWidget {
  const GoldPriceChart({super.key});

  @override
  State<GoldPriceChart> createState() => _GoldPriceChartState();
}

class _GoldPriceChartState extends State<GoldPriceChart> {
  String selectedFilter = '1M';
  final List<String> filters = ['1D', '1W', '1M', '1Y', 'ALL'];

  @override
  Widget build(BuildContext context) {
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
              children: const [
                Text(
                  'Rp 1.109.000 /gr',
                  style: TextStyle(
                    fontFamily: 'Roboto Mono', // or Poppins if Roboto Mono not available
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLightGold,
                  ),
                ),
                Text(
                  '+12.000 (+1,09%)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
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
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 3.5),
                    FlSpot(2, 4),
                    FlSpot(3, 3.8),
                    FlSpot(4, 5),
                    FlSpot(5, 4.8),
                    FlSpot(6, 6),
                    FlSpot(7, 5.5),
                    FlSpot(8, 7),
                  ],
                  isCurved: true,
                  color: AppColors.primaryGold,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
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
          ),
        ),
      ],
    );
  }
}
