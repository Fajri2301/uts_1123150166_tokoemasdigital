import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../services/admin_service.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  final AdminService _adminService = AdminService();

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
          'Kelola Transaksi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAllTransactions(),
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
    String type = transaction['type'] ?? 'digital';
    String status = transaction['status'] ?? 'pending';
    double goldAmount = (transaction['gold_amount'] ?? 0.0).toDouble();
    double? totalPrice = transaction['total_price'];
    String? address = transaction['address'];
    DateTime createdAt = (transaction['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacingMedium),
      padding: const EdgeInsets.all(AppSpacing.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB0B0B0)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goldAmount > 0 ? '${goldAmount.toStringAsFixed(3)} gr' : '-',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              if (totalPrice != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB0B0B0)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatRupiah(totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (address != null && address.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Alamat:',
              style: TextStyle(fontSize: 12, color: Color(0xFFB0B0B0)),
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatDate(createdAt),
            style: const TextStyle(fontSize: 12, color: Color(0xFFB0B0B0)),
          ),
          const SizedBox(height: 12),

          // Status Update Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showStatusDialog(transactionId, status),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0D0D0D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                ),
              ),
              child: Text(
                'Ubah Status (Saat ini: ${_getStatusLabel(status)})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusDialog(String transactionId, String currentStatus) async {
    final statuses = _adminService.getTransactionStatuses();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Pilih Status',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return ListTile(
              title: Text(
                _getStatusLabel(status),
                style: TextStyle(
                  color: status == currentStatus ? const Color(0xFFFFD700) : Colors.white,
                  fontWeight: status == currentStatus ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: status == currentStatus
                  ? const Icon(Icons.check, color: Color(0xFFFFD700))
                  : null,
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _adminService.updateTransactionStatus(transactionId, status);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status berhasil diupdate'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal update status: $e'),
                        backgroundColor: const Color(0xFFF44336),
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }
}
