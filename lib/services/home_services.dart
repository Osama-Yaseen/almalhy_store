import 'package:almalhy_store/models/brand_model.dart';
import 'package:almalhy_store/models/category_model.dart';
import 'package:almalhy_store/services/network_service.dart';
import 'package:dio/dio.dart';

class HomeService {
  final Dio _dio = NetworkService.dio;

  Future<List<CategoryModel>> getMainCategories() async {
    final response = await _dio.get('/ar/categories/main');
    final List<dynamic> data = response.data;
    return data
        .map((json) => CategoryModel.fromJson(json))
        .where((item) => item.nameAr.isNotEmpty)
        .toList();
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final response = await _dio.get('/ar/categories/main');
    final List<dynamic> data = response.data;
    return data
        .map((json) => CategoryModel.fromJson(json))
        .where((item) => item.nameAr.isNotEmpty)
        .toList();
  }

  Future<List<BrandModel>> getBrands() async {
    final response = await _dio.get('/ar/brands');
    final List<dynamic> data = response.data['data'];

    return data.map((json) => BrandModel.fromJson(json)).toList();
  }

  Future<List<String>> getBanners(String? lang) async {
    final resp = await _dio.get('/$lang/widgets/home_sliders');
    final data = resp.data as Map<String, dynamic>;
    final content = data['content'] as Map<String, dynamic>;
    return List<String>.from(content['images'] as List<dynamic>);
  }

  Future<List<CategoryModel>> getSubCategories(
    int parentId,
    String lang,
  ) async {
    final res = await _dio.get('/$lang/categories/$parentId/subcategories');
    return (res.data as List).map((j) => CategoryModel.fromJson(j)).toList();
  }
}
