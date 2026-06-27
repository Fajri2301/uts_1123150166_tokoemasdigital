import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/common/widgets/app_button.dart';
import 'package:toko_emas_digital/common/widgets/app_field.dart';
import 'package:toko_emas_digital/common/widgets/feature_icon.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toko_emas_digital/core/network/api_client.dart';

class BuyGoldScreen extends StatefulWidget {
  const BuyGoldScreen({super.key});

  @override
  State<BuyGoldScreen> createState() => _BuyGoldScreenState();
}

class _BuyGoldScreenState extends State<BuyGoldScreen> {
  final _gramController = TextEditingController();
  final _transactionService = TransactionService();
  
  double _pricePerGram = 0.0;
  bool _isLoading = false;
  bool _isLoadingPrice = true;
  String _selectedPaymentMethod = 'Saldo Tunai Aplikasi';

  final List<String> _paymentMethods = [
    'Saldo Tunai Aplikasi',
    'Dompet Nusantara (E-Money)',
  ];

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isPendingPayment = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGoldPrice();
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
          _showSuccessDialog(double.tryParse(_gramController.text) ?? 0.0);
        } else {
          setState(() => _errorMessage = errorMsg);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage!), backgroundColor: AppColors.error));
        }
      }
    });
  }

  Future<void> _fetchGoldPrice() async {
    try {
      final response = await ApiClient().dio.get('/gold-price');
      if (response.data['success'] == true) {
        setState(() {
          _pricePerGram = double.parse(response.data['data']['price_per_gram'].toString());
          _isLoadingPrice = false;
        });
      }
    } catch (e) {
      // Fallback
      setState(() {
        _pricePerGram = 1230000.0;
        _isLoadingPrice = false;
      });
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _gramController.dispose();
    super.dispose();
  }

  void _handleBuy() async {
    final gramsText = _gramController.text.trim();
    if (gramsText.isEmpty) return;
    
    final grams = double.tryParse(gramsText);
    if (grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan jumlah gram yang valid')));
      return;
    }

    final totalPrice = grams * _pricePerGram;
    setState(() => _isLoading = true);

    try {
      final result = await _transactionService.buyDigitalGold(grams, _selectedPaymentMethod);
      
      if (result != null && mounted) {
        final transactionId = result['transaction_id'] as int;
        final exactTotalPrice = result['total_price'] as double;

        if (_selectedPaymentMethod == 'Dompet Nusantara (E-Money)') {
          setState(() => _isPendingPayment = true);
          _showPendingDialog();

          final uri = Uri(
            scheme: 'danantara',
            host: 'pay',
            queryParameters: {
              'merchant_id': 'TK-EMAS-01',
              'merchant_name': 'Toko Emas Digital',
              'amount': exactTotalPrice.toString(),
              'description': 'Pembelian $grams Gram Emas Digital',
              'reference': transactionId.toString(),
              'callbackUrl': 'tokoemas://payment_success',
            },
          );
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            setState(() => _isPendingPayment = false);
            Navigator.of(context).pop(); // Tutup pending dialog
            throw Exception('Gagal membuka Dompet Nusantara. Pastikan aplikasi E-Money sudah berjalan/di-install.');
          }
        } else {
          _showSuccessDialog(grams);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted && _selectedPaymentMethod != 'Dompet Nusantara (E-Money)') {
        setState(() => _isLoading = false);
      }
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
                setState(() => _isLoading = false);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.redAccent, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(double grams) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3))),
        title: Center(
          child: FeatureIcon(
            icon: Icons.check_circle_rounded, 
            tone: 'green', 
            size: 70, 
            iconSize: 40
          ),
        ),
        content: Text(
          'Pembelian ${grams.toStringAsFixed(3)} gr Emas Digital berhasil!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        actions: [
          AppButton(
            label: 'Selesai',
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              _gramController.clear(); // Reset input gram
              setState(() {}); // Refresh UI
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grams = double.tryParse(_gramController.text) ?? 0.0;
    final totalPrice = grams * _pricePerGram;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Beli Emas Digital', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkGray),
              ),
              child: Column(
                children: [
                  const Text('Harga Beli Saat Ini', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  _isLoadingPrice
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2))
                      : Text('${CurrencyFormatter.formatRupiah(_pricePerGram)} / gr', style: const TextStyle(fontFamily: 'Roboto Mono', color: AppColors.primaryLightGold, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Jumlah Beli (Gram)', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            AppField(
              label: '',
              placeholder: '0.0',
              controller: _gramController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkGray, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                  items: _paymentMethods.map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                  onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.darkGray, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar', style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryLightGold, fontWeight: FontWeight.w700)),
                  Text(CurrencyFormatter.formatRupiah(totalPrice), style: const TextStyle(fontFamily: 'Roboto Mono', color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Beli Sekarang',
              onPressed: totalPrice > 0 ? _handleBuy : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
