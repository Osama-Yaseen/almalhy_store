import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class NetworkService {
  NetworkService._(); // private constructor

  static final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
        validateStatus: (status) => status != null && status < 400,
      ),
    )
    // you can add interceptors here (e.g. logging, auth token, error handling)
    ..interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      // AuthInterceptor(),  // if you want to inject bearer tokens automatically
    ]);
}
