import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../common/widgets/gold_button.dart';
import '../services/physical_gold_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final double price;

  const CheckoutScreen({
    Key? key,
    required this.productId,
    required this.productName,
    required this.price,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _physicalGoldService = PhysicalGoldService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedPaymentMethod = 'Transfer Bank';

  final List<String> _paymentMethods = [
    'Transfer Bank',
    'E-Wallet (OVO/Gopay)',
    'Saldo Emas Digital',
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
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            content: const Text(
              'Pesanan berhasil dibuat! Admin akan segera memproses pengiriman Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              Center(
                child: GoldButton(
                  text: 'Kembali ke Beranda',
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.padding),
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                  : GoldButton(
                      text: 'Konfirmasi & Bayar Sekarang',
                      onPressed: _handleCheckout,
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.diamond, color: Color(0xFFFFD700), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.productName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(CurrencyFormatter.formatRupiah(widget.price), style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInput() {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      validator: (value) => (value == null || value.isEmpty) ? 'Alamat wajib diisi' : null,
      decoration: InputDecoration(
        hintText: 'Masukkan alamat pengiriman lengkap...',
        hintStyle: const TextStyle(color: Color(0xFF666666)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPaymentMethod,
          dropdownColor: const Color(0xFF1A1A1A),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow('Harga Produk', CurrencyFormatter.formatRupiah(widget.price)),
          const SizedBox(height: 8),
          _summaryRow('Biaya Pengiriman', 'Gratis', isGold: true),
          const Divider(color: Colors.white12, height: 24),
          _summaryRow('Total Pembayaran', CurrencyFormatter.formatRupiah(widget.price), isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : const Color(0xFFB0B0B0), fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: isGold || isTotal ? const Color(0xFFFFD700) : Colors.white, fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)),
      child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
    );
  }
}
