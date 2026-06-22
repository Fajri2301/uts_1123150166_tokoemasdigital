import 'package:toko_emas_digital/core/network/api_client.dart';
import '../../physical_gold/models/product_model.dart';

class CatalogService {
  final ApiClient _apiClient = ApiClient();

  // Mempertahankan signature Stream agar tidak memecah UI yang sudah ada,
  // tapi sebenarnya memanggil REST API sekali.
  Stream<List<ProductModel>> getProducts() async* {
    yield await getProductsOnce();
  }

  // Get products via REST API
  Future<List<ProductModel>> getProductsOnce() async {
    try {
      final response = await _apiClient.dio.get('/products');
      
      if (response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data katalog: $e');
    }
  }
}
