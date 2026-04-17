import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/firestore_service.dart';

class GoldPriceApiService {
  final FirestoreService _firestoreService = FirestoreService();

  // API endpoints (simulasi - karena API harga emas Indonesia biasanya berbayar)
  // Gunakan API gratis atau simulasi untuk development
  static const String _apiUrl = 'https://api.hargaemas.com/v1/latest';
  
  // API alternatif (simulasi)
  static const String _fallbackApiUrl = 'https://api.gold-api.com/api/price/XAU';

  // Ambil harga emas dari API
  Future<Map<String, dynamic>> fetchGoldPrice() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'price_per_gram': _extractPriceFromResponse(data),
          'updated_at': DateTime.now(),
          'source': 'api',
        };
      } else {
        throw Exception('API response error: ${response.statusCode}');
      }
    } catch (e) {
      // Jika API gagal, gunakan fallback/simulasi
      return getSimulatedGoldPrice();
    }
  }

  // Fallback API
  Future<Map<String, dynamic>> fetchFromFallbackApi() async {
    try {
      final response = await http.get(Uri.parse(_fallbackApiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'price_per_gram': _extractPriceFromFallback(data),
          'updated_at': DateTime.now(),
          'source': 'fallback_api',
        };
      } else {
        throw Exception('Fallback API response error: ${response.statusCode}');
      }
    } catch (e) {
      return getSimulatedGoldPrice();
    }
  }

  // Simulasi harga emas (untuk development)
  // Harga emas Indonesia saat ini sekitar 1.000.000 - 1.200.000 per gram
  Map<String, dynamic> getSimulatedGoldPrice() {
    // Simulasi dengan variasi kecil
    final basePrice = 1100000.0;
    final variation = (basePrice * 0.02); // ±2%
    final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000.0;
    final price = basePrice + (variation * (random * 2 - 1));

    return {
      'price_per_gram': price,
      'updated_at': DateTime.now(),
      'source': 'simulated',
    };
  }

  // Ekstrak harga dari response API (sesuaikan dengan struktur API)
  double _extractPriceFromResponse(Map<String, dynamic> data) {
    // Sesuaikan dengan struktur API yang digunakan
    // Contoh: data['data']['price'] atau data['price'] dll
    try {
      if (data.containsKey('data')) {
        return (data['data']['price'] ?? 0.0).toDouble();
      }
      return (data['price'] ?? 0.0).toDouble();
    } catch (e) {
      return 1100000.0; // fallback
    }
  }

  // Ekstrak harga dari fallback API
  double _extractPriceFromFallback(Map<String, dynamic> data) {
    try {
      if (data.containsKey('price')) {
        return (data['price'] ?? 0.0).toDouble();
      }
      return (data['rate'] ?? 0.0).toDouble();
    } catch (e) {
      return 1100000.0; // fallback
    }
  }

  // Simpan harga ke Firestore
  Future<void> saveGoldPriceToFirestore(Map<String, dynamic> priceData) async {
    try {
      await _firestoreService.addDocument('gold_prices', {
        'price_per_gram': priceData['price_per_gram'],
        'updated_at': priceData['updated_at'],
        'source': priceData['source'],
      });
    } catch (e) {
      throw Exception('Gagal simpan harga ke Firestore: $e');
    }
  }

  // Update harga emas (fetch dari API + simpan ke Firestore)
  Future<double> updateGoldPrice() async {
    try {
      // Fetch dari API
      final priceData = await fetchGoldPrice();
      
      // Simpan ke Firestore
      await saveGoldPriceToFirestore(priceData);

      return priceData['price_per_gram'];
    } catch (e) {
      throw Exception('Gagal update harga emas: $e');
    }
  }

  // Auto update saat app dibuka
  Future<void> autoUpdateGoldPrice() async {
    try {
      final priceData = await fetchGoldPrice();
      await saveGoldPriceToFirestore(priceData);
    } catch (e) {
      // Silent fail untuk auto update
      print('Auto update gold price failed: $e');
    }
  }

  // Dapatkan sumber harga
  String getSourceLabel(String source) {
    switch (source) {
      case 'api':
        return 'Live API';
      case 'fallback_api':
        return 'Fallback API';
      case 'simulated':
        return 'Simulasi';
      default:
        return source;
    }
  }
}
