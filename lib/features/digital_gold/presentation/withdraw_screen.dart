import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:intl/intl.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TransactionService _transactionService = TransactionService();
  final TextEditingController _amountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  bool _isLoading = false;
  double _rupiahBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    final balances = await _transactionService.getWalletBalance();
    if (mounted) {
      setState(() {
        _rupiahBalance = balances['rupiah'] ?? 0.0;
      });
    }
  }

  void _setAmount(double amount) {
    setState(() {
      if (amount == -1) {
        _amountController.text = _rupiahBalance.toInt().toString();
      } else {
        _amountController.text = amount.toInt().toString();
      }
    });
  }

  Future<void> _processWithdraw() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (amountText.isEmpty) {
      _showError('Masukkan nominal yang ingin dicairkan.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Nominal tidak valid.');
      return;
    }

    if (amount > _rupiahBalance) {
      _showError('Saldo tidak mencukupi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _transactionService.withdrawCash(amount);
      if (success) {
        _showSuccess(amount);
      } else {
        _showError('Gagal melakukan penarikan dana.');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Inter', color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Withdraw Berhasil', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Dana sebesar ${currencyFormat.format(amount)} akan segera ditransfer ke rekening Anda.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // pop dialog
                Navigator.of(context).pop(); // pop screen
              },
              child: const Text('Selesai', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF080808),
      ),
      child: Stack(
        children: [
          // Radial Glow Background
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGold.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
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
                'Tarik Dana',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryGold),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.05), blurRadius: 20),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('SALDO RUPIAH TERSEDIA', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.primaryLightGold, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          currencyFormat.format(_rupiahBalance),
                          style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('Nominal Penarikan', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 16),
                  
                  // Amount Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('Rp', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.primaryGold)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildQuickBtn(50000, '50 rb'),
                      _buildQuickBtn(100000, '100 rb'),
                      _buildQuickBtn(500000, '500 rb'),
                      _buildQuickBtn(1000000, '1 jt'),
                      _buildQuickBtn(-1, 'Tarik Semua'),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Penarikan akan diproses ke rekening bank utama Anda yang terdaftar di preferensi akun. Proses memakan waktu maksimal 1x24 jam kerja.',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: AppColors.primaryGold.withValues(alpha: 0.5),
                      ),
                      onPressed: _isLoading ? null : _processWithdraw,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.ink, strokeWidth: 2))
                          : const Text('Proses Penarikan', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBtn(double amount, String label) {
    return GestureDetector(
      onTap: () => _setAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGold),
        ),
      ),
    );
  }
}
