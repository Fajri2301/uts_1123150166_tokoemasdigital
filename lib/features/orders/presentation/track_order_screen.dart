import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/digital_gold/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TrackOrderScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TrackOrderScreen({super.key, required this.transaction});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF080808),
      ),
      child: Stack(
        children: [
          // Radial Glow
          Positioned(
            top: -150,
            left: 0,
            right: 0,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: 0.1),
                    AppColors.primaryGold.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryGold),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text(
                'Lacak Pesanan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.05), blurRadius: 15),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('No. Resi / Order ID', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                              ),
                              child: const Text('JNE-EXPRESS', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 0.5)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('ORD-${widget.transaction.id}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No. Resi disalin!')));
                              },
                              child: const Icon(Icons.copy_rounded, color: AppColors.primaryGold, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(height: 1, color: AppColors.primaryGold.withValues(alpha: 0.15)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tanggal Order', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(widget.transaction.createdAt),
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormat.format(widget.transaction.totalPrice),
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryGold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Text('Status Pengiriman', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 24),

                  // Tracking Timeline
                  _buildTimelineItem(
                    title: 'Pesanan Dibuat',
                    description: 'Pesanan Anda telah diterima oleh sistem kami.',
                    time: DateFormat('HH:mm').format(widget.transaction.createdAt),
                    date: DateFormat('dd MMM').format(widget.transaction.createdAt),
                    isCompleted: true,
                    isFirst: true,
                  ),
                  _buildTimelineItem(
                    title: 'Verifikasi Pembayaran',
                    description: 'Pembayaran telah berhasil diverifikasi.',
                    time: DateFormat('HH:mm').format(widget.transaction.createdAt.add(const Duration(minutes: 5))),
                    date: DateFormat('dd MMM').format(widget.transaction.createdAt),
                    isCompleted: true,
                  ),
                  _buildTimelineItem(
                    title: 'Sedang Diproses',
                    description: 'Pesanan sedang disiapkan untuk pengiriman (Pencetakan Emas Fisik).',
                    time: DateFormat('HH:mm').format(DateTime.now()),
                    date: DateFormat('dd MMM').format(DateTime.now()),
                    isActive: true,
                  ),
                  _buildTimelineItem(
                    title: 'Dalam Perjalanan',
                    description: 'Pesanan telah diserahkan ke pihak kurir.',
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Pesanan Selesai',
                    description: 'Pesanan telah sampai di alamat tujuan.',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    String? time,
    String? date,
    bool isCompleted = false,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final color = isActive ? Colors.blueAccent : (isCompleted ? AppColors.primaryGold : AppColors.textSecondary.withValues(alpha: 0.3));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Time
        SizedBox(
          width: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (time != null) Text(time, style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.blueAccent : AppColors.textSecondary)),
              if (date != null) Text(date, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Middle: Timeline Line & Dot
        Column(
          children: [
            Container(
              width: 2,
              height: isFirst ? 0 : 20,
              color: isCompleted || isActive ? AppColors.primaryGold : AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 4),
            if (isActive)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.5 * _pulseAnimation.value), blurRadius: 10 * _pulseAnimation.value),
                      ],
                    ),
                    child: Center(
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent)),
                    ),
                  );
                },
              )
            else
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primaryGold : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: isCompleted ? const Icon(Icons.check_rounded, size: 10, color: AppColors.ink) : null,
              ),
            const SizedBox(height: 4),
            Container(
              width: 2,
              height: isLast ? 0 : 60,
              color: isCompleted ? AppColors.primaryGold : AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Right Side: Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 0 : 4, bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.w500, color: isActive ? Colors.white : (isCompleted ? AppColors.primaryLightGold : AppColors.textSecondary))),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary.withValues(alpha: isActive ? 1.0 : 0.7), height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
