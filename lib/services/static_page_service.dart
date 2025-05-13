import 'package:dio/dio.dart';

class StaticPageService {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> fetchPage(String endpoint) async {
    final response = await dio.get(endpoint);
    return response.data;
  }
}
