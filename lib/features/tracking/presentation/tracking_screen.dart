import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../services/tracking_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TrackingService _trackingService = TrackingService();
  String? _selectedTransactionId;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tracking Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Silakan login terlebih dahulu',
                style: TextStyle(color: Color(0xFFB0B0B0)),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _trackingService.getUserTransactions(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan',
                      style: const TextStyle(color: Color(0xFFF44336)),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  );
                }

                final transactions = snapshot.data!.docs;

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: Color(0xFFB0B0B0)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.padding),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index].data() as Map<String, dynamic>;
                    final transactionId = transactions[index].id;
                    return _buildTransactionCard(transaction, transactionId);
                  },
                );
              },
            ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, String transactionId) {
    String status = transaction['status'] ?? 'pending';
    String type = transaction['type'] ?? 'digital';
    double amount = (transaction['gold_amount'] ?? 0.0).toDouble();
    double? totalPrice = transaction['total_price'];
    DateTime createdAt = (transaction['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TrackingDetailScreen(
              transaction: transaction,
              transactionId: transactionId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.spacingMedium),
        padding: const EdgeInsets.all(AppSpacing.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    type == 'digital' ? Icons.account_balance_wallet : Icons.diamond,
                    size: 20,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type == 'digital' ? 'Emas Digital' : 'Emas Fisik',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _trackingService.getStatusLabel(status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (totalPrice != null)
              Text(
                CurrencyFormatter.formatRupiah(totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Dibuat: ${CurrencyFormatter.formatDate(createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFB0B0B0),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap untuk lihat detail tracking →',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFFFD700),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return const Color(0xFF4CAF50);
      case 'diproses':
        return const Color(0xFFFFD700);
      case 'dikirim':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFB0B0B0);
    }
  }
}

class TrackingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String transactionId;

  const TrackingDetailScreen({
    Key? key,
    required this.transaction,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trackingService = TrackingService();
    String currentStatus = transaction['status'] ?? 'pending';
    String type = transaction['type'] ?? 'digital';
    double? totalPrice = transaction['total_price'];
    String? address = transaction['address'];
    DateTime createdAt = (transaction['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

    List<String> statuses = trackingService.getNextStatuses(currentStatus);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tracking',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Transaksi
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Info Transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Tipe', type == 'digital' ? 'Emas Digital' : 'Emas Fisik'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Status',
                    trackingService.getStatusLabel(currentStatus),
                    valueColor: _getStatusColor(currentStatus),
                  ),
                  const SizedBox(height: 8),
                  if (totalPrice != null)
                    _buildInfoRow('Total', CurrencyFormatter.formatRupiah(totalPrice)),
                  const SizedBox(height: 8),
                  _buildInfoRow('Tanggal', CurrencyFormatter.formatDate(createdAt)),
                  if (address != null && address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Alamat', address),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXLarge),

            // Vertical Stepper (Spacing 16 px)
            const Text(
              'Status Pengiriman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingLarge),
            _buildVerticalStepper(statuses, currentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalStepper(List<String> statuses, String currentStatus) {
    List<Map<String, dynamic>> allSteps = [
      {'status': 'diproses', 'label': 'Pesanan Diproses', 'icon': Icons.construction},
      {'status': 'dikirim', 'label': 'Pesanan Dikirim', 'icon': Icons.local_shipping},
      {'status': 'selesai', 'label': 'Pesanan Selesai', 'icon': Icons.check_circle},
    ];

    int currentIndex = allSteps.indexWhere((s) => s['status'] == currentStatus);
    if (currentIndex == -1) currentIndex = 0;

    return Column(
      children: List.generate(
        allSteps.length,
        (index) {
          final step = allSteps[index];
          bool isActive = index <= currentIndex;
          bool isLast = index == allSteps.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          step['icon'],
                          color: isActive ? const Color(0xFF0D0D0D) : const Color(0xFF666666),
                          size: 20,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 16, // Spacing 16 px
                          color: isActive
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF1A1A1A),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.spacingMedium),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        step['label'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return const Color(0xFF4CAF50);
      case 'diproses':
        return const Color(0xFFFFD700);
      case 'dikirim':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFB0B0B0);
    }
  }
}
