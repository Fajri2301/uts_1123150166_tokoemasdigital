import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/features/physical_gold/services/physical_gold_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'map_selection_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;

  const CheckoutScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
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
  String _deliveryOption = 'Dikirim';
  String _selectedPaymentMethod = 'Saldo Tunai Aplikasi';
  
  double _distanceKm = 0.0;
  double _shippingFee = 0.0;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isPendingPayment = false;
  
  double get _finalShippingFee => _deliveryOption == 'Dikirim' ? _shippingFee : 0.0;
  double get _finalTotal => widget.price + _finalShippingFee;

  final List<String> _paymentMethods = [
    'Saldo Tunai Aplikasi',
    'Saldo Emas Digital',
    'Dompet Nusantara (E-Money)',
    'COD (Bayar di Tempat)',
  ];

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  void _initAppLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (!mounted || !_isPendingPayment) return;
      if (uri.scheme == 'tokoemas' && uri.host == 'payment_success') {
        final status = uri.queryParameters['status'];
        final errorMsg = uri.queryParameters['error'] ?? 'Pembayaran gagal atau dibatalkan.';
        
        setState(() => _isPendingPayment = false);
        // Tutup dialog pending jika sedang terbuka
        Navigator.of(context).pop(); 

        if (status == 'success') {
          _showSuccessDialog();
        } else {
          setState(() => _errorMessage = errorMsg);
        }
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    if (_deliveryOption == 'Dikirim' && !_formKey.currentState!.validate()) return;

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
        price: _finalTotal,
        address: _deliveryOption == 'Ambil di Toko' ? 'Ambil di Toko Fisik (Jl. Sudirman No. 45)' : _addressController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      if (success && mounted) {
        setState(() => _isLoading = false);

        if (_selectedPaymentMethod == 'Dompet Nusantara (E-Money)') {
          setState(() => _isPendingPayment = true);
          _showPendingDialog();
          
          final Uri uri = Uri(
            scheme: 'danantara',
            host: 'pay',
            queryParameters: {
              'merchant_id': 'TE01',
              'merchant_name': 'Toko Emas Digital',
              'amount': _finalTotal.toString(),
              'callbackUrl': 'tokoemas://payment_success',
            },
          );
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            setState(() {
              _isPendingPayment = false;
              _errorMessage = 'Gagal membuka Dompet Nusantara. Pastikan aplikasi E-Money sudah terpasang. Error: $e';
            });
            Navigator.of(context).pop(); // Tutup pending dialog
          }
        } else {
          _showSuccessDialog();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primaryGold),
            const SizedBox(height: 24),
            const Text(
              'Menunggu Pembayaran',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Anda dialihkan ke aplikasi Dompet Nusantara (Danantara). Selesaikan pembayaran di sana untuk melanjutkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter', height: 1.5, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() => _isPendingPayment = false);
                Navigator.of(context).pop();
              },
              child: const Text('Batal', style: TextStyle(color: Colors.redAccent, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 56),
            ),
            const SizedBox(height: 16),
            const Text('Checkout Berhasil', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: const Text(
          'Pesanan emas fisik Anda berhasil dibuat.\nAdmin akan segera memproses pengiriman ke alamat Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter', height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Kembali ke Beranda', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF080808)),
      child: Stack(
        children: [
          // Cyber Blue / Gold Glow
          Positioned(
            top: -100,
            right: -50,
            height: 400,
            width: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: 0.15),
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
                'Checkout Pesanan',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryGold),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Produk Terpilih'),
                    _buildProductInfo(),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Opsi Pengiriman'),
                    _buildDeliveryOptions(),
                    const SizedBox(height: 32),

                    if (_deliveryOption == 'Dikirim') ...[
                      _buildSectionTitle('Alamat Pengiriman'),
                      _buildAddressInput(),
                      const SizedBox(height: 32),
                    ],

                    _buildSectionTitle('Metode Pembayaran'),
                    _buildPaymentSelector(),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Ringkasan Pembayaran'),
                    _buildOrderSummary(),
                    const SizedBox(height: 40),

                    if (_errorMessage != null) _buildErrorMessage(),

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
                        onPressed: _isLoading ? null : _handleCheckout,
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.ink, strokeWidth: 2))
                            : const Text('Konfirmasi & Bayar', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLightGold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: child,
    );
  }

  ImageProvider _getImageProvider(String url) {
    if (url.contains('base64,')) {
      try {
        final base64String = url.split(',').last;
        final Uint8List bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        // Fallback
      }
    }
    if (url.isNotEmpty && url != 'placeholder') {
      return NetworkImage(url);
    }
    return const AssetImage('assets/images/placeholder.png'); // Fallback
  }

  Widget _buildProductInfo() {
    return _buildGlassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: _getImageProvider(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.productName, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(CurrencyFormatter.formatRupiah(widget.price), style: const TextStyle(fontFamily: 'Roboto Mono', color: AppColors.primaryGold, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262626).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _deliveryOption = 'Dikirim'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _deliveryOption == 'Dikirim' ? AppColors.primaryGold.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: Center(
                  child: Text('Dikirim', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: _deliveryOption == 'Dikirim' ? AppColors.primaryGold : Colors.white)),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.primaryGold.withValues(alpha: 0.3)),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _deliveryOption = 'Ambil di Toko'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _deliveryOption == 'Ambil di Toko' ? AppColors.primaryGold.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                ),
                child: Center(
                  child: Text('Ambil di Toko', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: _deliveryOption == 'Ambil di Toko' ? AppColors.primaryGold : Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF151311),
            foregroundColor: AppColors.primaryGold,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.5)),
            ),
          ),
          icon: const Icon(Icons.location_on_rounded, size: 20),
          label: const Text('Gunakan Google Maps', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const MapSelectionScreen()));
            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                _addressController.text = result['address'];
                LatLng dest = result['latLng'];
                const LatLng storeLocation = LatLng(-6.1753924, 106.8271528); // Monas
                double distanceInMeters = Geolocator.distanceBetween(
                  storeLocation.latitude, storeLocation.longitude,
                  dest.latitude, dest.longitude
                );
                _distanceKm = distanceInMeters / 1000;
                _shippingFee = _distanceKm * 5000; // Rp 5.000 per km
              });
            }
          },
        ),
        const SizedBox(height: 12),
        if (_distanceKm > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.route_rounded, color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 8),
                Text('Jarak ke Toko: ${_distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontFamily: 'Inter', color: AppColors.primaryLightGold, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Detail alamat pengiriman...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.4)),
            filled: true,
            fillColor: const Color(0xFF262626).withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryGold),
            ),
          ),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Alamat wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildPaymentSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF262626).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPaymentMethod,
          dropdownColor: const Color(0xFF151311),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGold),
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          items: _paymentMethods.map((method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return _buildGlassCard(
      child: Column(
        children: [
          _summaryRow('Harga Produk', CurrencyFormatter.formatRupiah(widget.price)),
          const SizedBox(height: 12),
          _summaryRow('Biaya Pengiriman', _finalShippingFee > 0 ? CurrencyFormatter.formatRupiah(_finalShippingFee) : 'Gratis', isGold: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.primaryGold.withValues(alpha: 0.2)),
          ),
          _summaryRow('Total Pembayaran', CurrencyFormatter.formatRupiah(_finalTotal), isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontFamily: isTotal ? 'Poppins' : 'Inter', color: isTotal ? Colors.white : AppColors.textSecondary, fontSize: isTotal ? 14 : 12, fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500)),
        Text(value, style: TextStyle(fontFamily: 'Roboto Mono', color: isGold || isTotal ? AppColors.primaryGold : Colors.white, fontSize: isTotal ? 18 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(fontFamily: 'Inter', color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
