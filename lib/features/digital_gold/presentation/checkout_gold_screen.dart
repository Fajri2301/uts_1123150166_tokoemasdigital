import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/common/widgets/app_button.dart';
import 'package:toko_emas_digital/common/widgets/app_field.dart';
import 'package:toko_emas_digital/common/widgets/feature_icon.dart';
import '../services/digital_gold_service.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../physical_gold/presentation/map_selection_screen.dart';

class CheckoutGoldScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const CheckoutGoldScreen({super.key, required this.item});

  @override
  State<CheckoutGoldScreen> createState() => _CheckoutGoldScreenState();
}

class _CheckoutGoldScreenState extends State<CheckoutGoldScreen> {
  final _addressController = TextEditingController();
  final _digitalGoldService = DigitalGoldService();
  bool _isLoading = false;
  
  String _deliveryOption = 'Dikirim';
  double _distanceKm = 0.0;
  double _shippingFee = 0.0;
  String _shippingPaymentMethod = 'Saldo Uang Aplikasi';

  final List<String> _paymentMethods = [
    'Saldo Uang Aplikasi',
    'COD (Bayar di Tempat)',
  ];

  double get _finalShippingFee => _deliveryOption == 'Dikirim' ? _shippingFee : 0.0;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _handleCheckout() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman wajib diisi'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await _digitalGoldService.convertToPhysical(
        userId: FirebaseAuth.instance.currentUser!.uid,
        gramAmount: widget.item['weight'],
        address: _deliveryOption == 'Ambil di Toko' ? 'Ambil di Toko Fisik (Jl. Sudirman No. 45)' : _addressController.text.trim(),
      );

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3))),
            title: const Center(
              child: FeatureIcon(icon: Icons.check_circle_rounded, tone: 'green', size: 70, iconSize: 40),
            ),
            content: Text(
              'Penukaran fisik ${widget.item['name']} berhasil!\nBarang akan segera dikirim.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(1, 'Shipping', true),
        _buildLine(false),
        _buildStep(2, 'Payment', false),
        _buildLine(false),
        _buildStep(3, 'Confirm', false),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGold : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primaryGold : AppColors.darkGray, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            step.toString(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 24),
      color: isActive ? AppColors.primaryGold : AppColors.darkGray,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryGold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_rounded, color: AppColors.primaryGold),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 32),
            
            // Delivery Option Segment
            Container(
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
            ),
            const SizedBox(height: 32),
            
            if (_deliveryOption == 'Dikirim') ...[
            // Shipping Address Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping Address', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Change', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primaryGold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Alamat Baru', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('UTAMA', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                           foregroundColor: AppColors.primaryGold,
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                           backgroundColor: const Color(0xFF151311),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                             side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                           ),
                        ),
                        icon: const Icon(Icons.location_on_rounded, size: 16),
                        label: const Text('Buka Maps', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
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
                    ],
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
                  AppField(
                    label: '',
                    placeholder: 'Ketik alamat pengiriman lengkap di sini...',
                    controller: _addressController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Payment Method for Shipping Fee
            const Text('Metode Pembayaran Ongkos Kirim', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF262626).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _shippingPaymentMethod,
                  dropdownColor: const Color(0xFF151311),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGold),
                  style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem(value: method, child: Text(method));
                  }).toList(),
                  onChanged: (val) => setState(() => _shippingPaymentMethod = val!),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ],
            
            // Order Summary
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Order Summary', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ),
                  const Divider(color: AppColors.darkGray, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.darkGray),
                            image: DecorationImage(
                              image: NetworkImage(widget.item['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.item['name'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Purity: ${widget.item['purity']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Qty: 1', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                                  Text('${widget.item['weight']} gr', style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.darkGray, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal (Saldo Dipotong)', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),
                            Text('${widget.item['weight']} gr', style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 14, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Biaya Pengiriman', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),
                            Text(_finalShippingFee > 0 ? CurrencyFormatter.formatRupiah(_finalShippingFee) : 'Gratis', style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 14, color: AppColors.textPrimary)),
                          ],
                        ),
                        if (_deliveryOption == 'Dikirim') ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Pembayaran Ongkir via', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),
                              Text(_shippingPaymentMethod, style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 12, color: AppColors.primaryGold)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Asuransi Pengiriman', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),
                            Text('Termasuk', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 14, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.darkGray, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Biaya Kirim', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textPrimary)),
                        Text(CurrencyFormatter.formatRupiah(_finalShippingFee), style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryGold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
                    child: GestureDetector(
                      onTap: _handleCheckout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primaryGold, AppColors.primaryDark]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textPrimary, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Continue to Payment', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text('Secured by 256-bit AES Encryption', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1.5)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            // Trust Badges
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TrustBadge(icon: Icons.verified_user_rounded, label: 'CERTIFIED'),
                SizedBox(width: 32),
                _TrustBadge(icon: Icons.lock_rounded, label: 'INSURED'),
                SizedBox(width: 32),
                _TrustBadge(icon: Icons.local_shipping_rounded, label: 'DISCRETE'),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0)),
      ],
    );
  }
}
