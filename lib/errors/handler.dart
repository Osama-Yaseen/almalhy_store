// lib/core/errors/handler.dart

import 'package:almalhy_store/errors/exception.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'failures.dart';

/// Map any thrown exception into a Failure.
Failure handleException(Exception e) {
  if (e is AppException) {
    return Failure(e.message);
  } else if (e is DioException) {
    // Customize based on status or type
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Failure("connection_timed_out".tr());
    }
    if (e.response != null) {
      return Failure(
        'server_returned_status'.tr(
          namedArgs: {'code': e.response!.statusCode.toString()},
        ),
      );
    }
    return Failure('network_error'.tr());
  } else {
    return Failure('unexpected_error'.tr());
  }
}
