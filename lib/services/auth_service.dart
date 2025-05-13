import 'package:almalhy_store/models/auth_response.dart';
import 'package:almalhy_store/services/network_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = NetworkService.dio;

  /// 1. Sign up (returns message + user + otp + token)
  Future<AuthResponse> signUp({
    required String name,
    required String phone,
    String? email,
    required String password,
    required String invitedByCode,
    required String role,
    String? address,
    required int cityId,
    double? lat,
    double? lng,
    String? profilePicturePath,
    String? lang, // e.g. 'ar' or 'en'
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'phone': phone,
      'email': email ?? '',
      'password': password,
      'invited_by_code': invitedByCode,
      'role': role,
      'address': address ?? '',
      'city_id': cityId,
      'lat': lat?.toString() ?? '',
      'lng': lng?.toString() ?? '',
      if (profilePicturePath != null)
        'profile_picture': await MultipartFile.fromFile(profilePicturePath),
    });

    final resp = await _dio.post(
      '/${lang ?? 'en'}/sign-up',
      data: form,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 2. Verify sign-up OTP
  Future<String> verifySignUpOtp({
    required String phone,
    required String otp,
    String? lang,
  }) async {
    final resp = await _dio.post(
      '/${lang ?? 'en'}/signup-verify-otp',
      data: {'phone': phone, 'otp': otp},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    return resp.data['message'];
  }

  /// 3. Sign in (login)
  Future<AuthResponse> signIn({
    required String phone,
    required String password,
    String? lang,
  }) async {
    try {
      final resp = await _dio.post(
        '/${lang ?? 'en'}/sign-in',
        data: {'phone': phone, 'password': password},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final body = e.response!.data as Map<String, dynamic>;
        throw Exception(body['message']?.toString() ?? 'login_failed');
      }
      rethrow;
    }
  }

  /// 4. Sign out
  Future<void> signOut({required String token, String? lang}) async {
    await _dio.post(
      '/${lang ?? 'en'}/sign-out',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  /// 5. Forgot password (send code to phone)
  Future<Map<String, dynamic>> forgotPasswordPhone({
    required String phone,
    String? lang,
  }) async {
    final resp = await _dio.post(
      '/${lang ?? 'en'}/forgot-password-phone',
      data: {'phone': phone},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    return resp.data;
  }

  /// 6. Verify forgot-password OTP
  Future<AuthResponse> verifyForgotPasswordOtp({
    required String phone,
    required String otp,
    String? lang,
  }) async {
    final resp = await _dio.post(
      '/${lang ?? 'en'}/verify-otp',
      data: {'phone': phone, 'otp': otp},
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 7. Reset password
  Future<void> resetPassword({
    required String phone,
    required String password,
    String? lang,
  }) async {
    try {
      final resp = await _dio.post(
        '/${lang ?? 'en'}/reset-password-phone',
        data: {'phone': phone, 'password': password},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer 8|BGhLTfhosRB6BQYumD5VFD6zqvse8vgZivdhlQKAe7b09a64',
          },
        ),
      );
      //  return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      print(e);
    }
  }
}
