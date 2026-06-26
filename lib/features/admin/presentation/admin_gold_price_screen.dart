import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import '../services/admin_service.dart';

class AdminGoldPriceScreen extends StatefulWidget {
  const AdminGoldPriceScreen({Key? key}) : super(key: key);

  @override
  State<AdminGoldPriceScreen> createState() => _AdminGoldPriceScreenState();
}

class _AdminGoldPriceScreenState extends State<AdminGoldPriceScreen> {
  final AdminService _adminService = AdminService();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  bool _isFetching = true;
  double _currentPrice = 0.0;


  final List<double> _presets = [2500000, 2600000, 2650000, 2700000, 2750000, 2800000];

  @override
  void initState() {
    super.initState();
    _loadCurrentPrice();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentPrice() async {
    setState(() => _isFetching = true);
    final price = await _adminService.getCurrentGoldPrice();
    if (mounted) {
      setState(() {
        _currentPrice = price;
        _priceController.text = price > 0 ? price.toInt().toString() : '';
        _isFetching = false;
      });
    }
  }

  Future<void> _handleUpdate() async {
    final text = _priceController.text.trim();
    if (text.isEmpty) {
      _showSnack('Harga tidak boleh kosong', isError: true);
      return;
    }
    final price = double.tryParse(text);
    if (price == null || price <= 0) {
      _showSnack('Masukkan angka yang valid', isError: true);
      return;
    }
    if (price < 1000000 || price > 10000000) {
      _showSnack('Harga emas tidak wajar. Pastikan antara Rp 1jt - 10jt/gram', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _adminService.updateGoldPrice(price);
      _showSnack('Harga emas berhasil diperbarui!');
      _loadCurrentPrice();
    } catch (e) {
      _showSnack('Gagal update: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Update Harga Emas',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: AppColors.primaryGold),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            onPressed: _loadCurrentPrice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Price Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGold.withOpacity(0.2),
                    AppColors.primaryGold.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.trending_up_rounded, color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 8),
                      Text('Harga Emas Saat Ini',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isFetching
                      ? const CircularProgressIndicator(color: Color(0xFFB38922))
                      : Text(
                          _currentPrice > 0
                              ? CurrencyFormatter.formatRupiah(_currentPrice)
                              : 'Belum diatur',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 6),
                  Text('per gram', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Input Baru
            _SectionLabel(title: 'Atur Harga Baru', icon: Icons.price_change_rounded),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Contoh: 2650000',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text('Rp', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                prefixIconConstraints: const BoxConstraints(),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.darkGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.darkGray),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixText: '/gram',
                suffixStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // Preset Harga
            _SectionLabel(title: 'Pilih Preset Harga', icon: Icons.flash_on_rounded, color: AppColors.warning),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presets.map((p) {
                final isSelected = _priceController.text == p.toInt().toString();
                return GestureDetector(
                  onTap: () => setState(() => _priceController.text = p.toInt().toString()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGold : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGold : AppColors.darkGray,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      CurrencyFormatter.formatRupiah(p),
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perubahan harga akan langsung terlihat oleh semua pengguna aplikasi. Sistem simulator otomatis akan terus memperbarui harga setiap 30 detik.',
                      style: TextStyle(color: AppColors.info.withOpacity(0.85), fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFB38922)))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded, size: 20),
                      label: const Text('Simpan Harga Baru',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _handleUpdate,
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  const _SectionLabel({required this.title, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryGold;
    return Row(
      children: [
        Icon(icon, color: c, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
