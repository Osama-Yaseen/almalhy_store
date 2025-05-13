// lib/data/services/city_service.dart

import 'package:almalhy_store/constants/api_constants.dart';
import 'package:almalhy_store/errors/exception.dart';
import 'package:almalhy_store/models/city_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class CityService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: baseUrl, validateStatus: (s) => s != null && s < 400),
  );

  CityService() {
    // assume you already set baseUrl on _dio
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Authorization'] =
        'Bearer 8|BGhLTfhosRB6BQYumD5VFD6zqvse8vgZivdhlQKAe7b09a64';
  }

  /// Fetches the list of cities for the given [lang] ('en' or 'ar').
  Future<List<CityModel>> getCities({required String lang}) async {
    try {
      final resp = await _dio.get('/$lang/cities');
      final data = resp.data as List<dynamic>;
      return data
          .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('connection_timed_out'.tr());
      }
      if (e.response != null) {
        throw ServerException(
          'server_returned_status'.tr(
            namedArgs: {'code': e.response!.statusCode.toString()},
          ),
        );
      }
      throw NetworkException('network_error'.tr());
    }
  }
}
