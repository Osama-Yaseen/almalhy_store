// lib/core/errors/exceptions.dart

import 'package:easy_localization/easy_localization.dart';

abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

/// When the server returns an unexpected status code
class ServerException extends AppException {
  ServerException([String? msg]) : super(msg ?? 'server_error'.tr());
}

/// When validation on the client fails
class ValidationException extends AppException {
  ValidationException([String? msg]) : super(msg ?? 'invalid_input'.tr());
}

/// When there’s no network connection
class NetworkException extends AppException {
  NetworkException([String? msg]) : super(msg ?? 'no_internet_connection'.tr());
}
