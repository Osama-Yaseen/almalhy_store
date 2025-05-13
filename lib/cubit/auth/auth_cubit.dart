import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthInitial());

  Future<void> loginUser({
    required String phone,
    required String password,
    required String language,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authService.signIn(
        phone: phone,
        password: password,
        lang: language,
      );
      await LocalStorageService.saveAuthResponse(user);
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthLoginFailure(e.toString()));
    }
  }

  Future<void> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required int cityId,
    String? invitedByCode,
    String? address,
    double? lat,
    double? lng,
    String? profilePicturePath,
  }) async {
    emit(AuthLoading());
    try {
      final authResp = await authService.signUp(
        name: name,
        phone: phone,
        email: email,
        password: password,
        invitedByCode: invitedByCode ?? '',
        role: 'user',
        address: address,
        cityId: cityId,
        lat: lat,
        lng: lng,
        profilePicturePath: profilePicturePath,
      );
      await LocalStorageService.saveAuthResponse(authResp);
      emit(AuthRegisterSuccess(authResp));
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final errors = (data['errors'] as Map<String, dynamic>?) ?? {};

        // Look for phone errors first
        final phoneErrs = errors['phone'] as List<dynamic>?;
        if (phoneErrs != null && phoneErrs.isNotEmpty) {
          emit(AuthRegisterFailure('phone_taken'.tr()));
          return;
        }

        // Then look for email errors
        final emailErrs = errors['email'] as List<dynamic>?;
        if (emailErrs != null && emailErrs.isNotEmpty) {
          emit(AuthRegisterFailure('email_taken'.tr()));
          return;
        }

        // // Fallback to the general server message
        // final serverMessage = data['message'] as String? ?? 'Unknown error';
        // emit(AuthFailure(serverMessage));
      } else {
        emit(AuthRegisterFailure('network_error'.tr()));
      }
    } catch (e) {
      emit(AuthRegisterFailure('unexpected_error'.tr()));
    }
  }

  Future<void> logout() async {
    await LocalStorageService.clearAllData();
    emit(AuthInitial());
  }
}
