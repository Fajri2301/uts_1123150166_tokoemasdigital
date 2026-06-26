import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import '../services/admin_service.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _allTransactions = [];
  bool _isLoading = true;
  late TabController _tabController;
  String _selectedFilter = 'all';

  final _filters = ['all', 'pending', 'success', 'dikirim', 'selesai', 'failed'];
  final _filterLabels = {
    'all': 'Semua',
    'pending': 'Pending',
    'success': 'Sukses',
    'dikirim': 'Dikirim',
    'selesai': 'Selesai',
    'failed': 'Gagal',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _adminService.getAllTransactions();
      if (mounted) {
        setState(() {
          _allTransactions = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'all') return _allTransactions;
    return _allTransactions.where((t) => t['status'] == _selectedFilter).toList();
  }

  int _countByStatus(String status) {
    if (status == 'all') return _allTransactions.length;
    return _allTransactions.where((t) => t['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            title: const Text('Kelola Transaksi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
                onPressed: _loadTransactions,
              ),
            ],
            bottom: _isLoading
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(90),
                    child: Column(
                      children: [
                        // Summary Row
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            children: [
                              _SummaryChip(
                                label: 'Total',
                                count: _allTransactions.length,
                                color: AppColors.primaryGold,
                              ),
                              const SizedBox(width: 8),
                              _SummaryChip(
                                label: 'Pending',
                                count: _countByStatus('pending'),
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              _SummaryChip(
                                label: 'Sukses',
                                count: _countByStatus('success'),
                                color: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                        // Filter Chips
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _filters.length,
                            itemBuilder: (_, i) {
                              final f = _filters[i];
                              final isSelected = _selectedFilter == f;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedFilter = f),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryGold
                                        : AppColors.bg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryGold
                                          : AppColors.darkGray,
                                    ),
                                  ),
                                  child: Text(
                                    _filterLabels[f]!,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _loadTransactions,
          color: AppColors.primaryGold,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB38922)))
              : _filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (_, i) => _TransactionCard(
                        transaction: _filteredTransactions[i],
                        adminService: _adminService,
                        onStatusChanged: _loadTransactions,
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'all'
                ? 'Belum ada transaksi'
                : 'Tidak ada transaksi dengan status "${_filterLabels[_selectedFilter]}"',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text('$count ', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final AdminService adminService;
  final VoidCallback onStatusChanged;

  const _TransactionCard({
    required this.transaction,
    required this.adminService,
    required this.onStatusChanged,
  });

  static const _typeLabels = {
    'buy_digital': 'Beli Emas Digital',
    'sell_digital': 'Jual Emas Digital',
    'physical_checkout': 'Beli Emas Fisik',
    'withdraw_cash': 'Tarik Dana',
    'convert': 'Konversi Emas',
  };

  static const _typeIcons = {
    'buy_digital': Icons.add_circle_rounded,
    'sell_digital': Icons.remove_circle_rounded,
    'physical_checkout': Icons.diamond_rounded,
    'withdraw_cash': Icons.account_balance_rounded,
    'convert': Icons.swap_horiz_rounded,
  };

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
      case 'selesai':
        return AppColors.success;
      case 'dikirim':
      case 'diproses':
        return AppColors.info;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'success':
        return 'Sukses';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String type = transaction['type'] ?? '';
    final String status = transaction['status'] ?? 'pending';
    final double grams = (transaction['grams'] ?? 0.0).toDouble();
    final double total = (transaction['total_price'] as num?)?.toDouble() ?? 0;
    final String? address = transaction['address'];
    final DateTime date = transaction['created_at'] != null
        ? DateTime.parse(transaction['created_at'])
        : DateTime.now();

    final Color statusColor = _statusColor(status);
    final IconData typeIcon = _typeIcons[type] ?? Icons.swap_horiz_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(typeIcon, color: AppColors.primaryGold, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabels[type] ?? type,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text('ID #${transaction['id']} • User ${transaction['user_id']}',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(status).toUpperCase(),
                        style: TextStyle(
                            color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details Row
                Row(
                  children: [
                    if (grams > 0) ...[
                      _DetailChip(
                        icon: Icons.scale_outlined,
                        label: CurrencyFormatter.formatGram(grams),
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _DetailChip(
                      icon: Icons.payments_rounded,
                      label: CurrencyFormatter.formatRupiah(total),
                      color: AppColors.info,
                    ),
                  ],
                ),

                if (address != null && address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(address,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(CurrencyFormatter.formatDate(date),
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.darkGray.withOpacity(0.4))),
            ),
            child: TextButton.icon(
              icon: Icon(Icons.edit_rounded, size: 16, color: AppColors.primaryGold),
              label: Text(
                'Ubah Status: ${_statusLabel(status)}',
                style: TextStyle(color: AppColors.primaryGold, fontSize: 13),
              ),
              onPressed: () => _showStatusDialog(context, transaction['id'].toString(), status),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, String trxId, String currentStatus) {
    final statuses = adminService.getTransactionStatuses();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.darkGray, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Pilih Status Baru',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Transaksi #$trxId', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            ...statuses.map((s) {
              final isSelected = s == currentStatus;
              final color = _statusColorStatic(s);
              return GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await adminService.updateTransactionStatus(trxId, s);
                    onStatusChanged();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Status berhasil diperbarui'),
                          backgroundColor: Color(0xFF22C55E),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color.withOpacity(0.5) : AppColors.darkGray,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _statusLabelStatic(s),
                        style: TextStyle(
                          color: isSelected ? color : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _statusColorStatic(String status) {
    switch (status) {
      case 'success':
      case 'selesai':
        return AppColors.success;
      case 'dikirim':
      case 'diproses':
        return AppColors.info;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabelStatic(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'success':
        return 'Sukses';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DetailChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
