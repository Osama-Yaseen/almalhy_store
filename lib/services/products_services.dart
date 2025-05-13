import 'package:almalhy_store/models/product_model.dart';
import 'package:almalhy_store/services/network_service.dart';
import 'package:dio/dio.dart';

class ProductService {
  final Dio _dio = NetworkService.dio;

  Future<List<ProductModel>> getProductsByCategory(
    int categoryId,
    String lang,
  ) async {
    final response = await _dio.get('/$lang/categories/$categoryId/products');
    final List data = response.data as List;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}
