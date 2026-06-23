import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/feature_icon.dart';
import '../../../common/widgets/app_field.dart';
import '../services/physical_gold_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final double price;

  const CheckoutScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.price,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _physicalGoldService = PhysicalGoldService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedPaymentMethod = 'Saldo Tunai Aplikasi';

  final List<String> _paymentMethods = [
    'Saldo Tunai Aplikasi',
    'Saldo Emas Digital',
    'Dompet Nusantara (E-Money)',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success = await _physicalGoldService.createTransaction(
        userId: user.uid,
        productId: widget.productId,
        price: widget.price,
        address: _addressController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      if (success && mounted) {
        if (_selectedPaymentMethod == 'Dompet Nusantara (E-Money)') {
          final Uri uri = Uri.parse(
              'dompetkampus://pay?merchant_id=TE01&merchant_name=Toko%20Emas%20Digital&amount=${widget.price}');
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            throw Exception('Gagal membuka Dompet Nusantara. Pastikan aplikasi E-Money sudah berjalan/di-install. Error: $e');
          }
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Center(
              child: FeatureIcon(
                icon: Icons.check_rounded,
                tone: 'green',
                size: 70,
                iconSize: 40,
              ),
            ),
            content: const Text(
              'Pesanan berhasil dibuat!\nAdmin akan segera memproses pengiriman Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            actions: [
              AppButton(
                label: 'Kembali ke Beranda',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout Pesanan',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Card
              _buildSectionTitle('Produk Terpilih'),
              _buildProductInfo(),
              const SizedBox(height: 24),

              // Address Input
              _buildSectionTitle('Alamat Pengiriman'),
              _buildAddressInput(),
              const SizedBox(height: 24),

              // Payment Method
              _buildSectionTitle('Metode Pembayaran'),
              _buildPaymentSelector(),
              const SizedBox(height: 24),

              // Summary
              _buildSectionTitle('Ringkasan Pembayaran'),
              _buildOrderSummary(),
              const SizedBox(height: 32),

              // Error Message
              if (_errorMessage != null) _buildErrorMessage(),

              // Action Button
              AppButton(
                label: 'Konfirmasi & Bayar',
                onPressed: _handleCheckout,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.slate600),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowSoft,
        border: Border.all(color: AppColors.line2),
      ),
      child: Row(
        children: [
          const FeatureIcon(icon: Icons.diamond_outlined, tone: 'gold', size: 48, iconSize: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.productName, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(CurrencyFormatter.formatRupiah(widget.price), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInput() {
    return AppField(
      label: '',
      placeholder: 'Masukkan alamat pengiriman lengkap...',
      controller: _addressController,
      maxLines: 3,
      validator: (value) => (value == null || value.isEmpty) ? 'Alamat wajib diisi' : null,
    );
  }

  Widget _buildPaymentSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPaymentMethod,
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.slate400),
          style: const TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w600),
          items: _paymentMethods.map((method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowSoft,
        border: Border.all(color: AppColors.line2),
      ),
      child: Column(
        children: [
          _summaryRow('Harga Produk', CurrencyFormatter.formatRupiah(widget.price)),
          const SizedBox(height: 12),
          _summaryRow('Biaya Pengiriman', 'Gratis', isGold: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.line),
          ),
          _summaryRow('Total Pembayaran', CurrencyFormatter.formatRupiah(widget.price), isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? AppColors.ink : AppColors.slate500, fontSize: isTotal ? 14 : 13, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500)),
        Text(value, style: TextStyle(color: isGold || isTotal ? AppColors.primary : AppColors.ink, fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700)),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Text(_errorMessage!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
    );
  }
}
