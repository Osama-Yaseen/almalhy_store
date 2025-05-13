import 'package:almalhy_store/models/auth_response.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final AuthResponse user;
  AuthLoginSuccess(this.user);
}

class AuthRegisterSuccess extends AuthState {
  final AuthResponse user;
  AuthRegisterSuccess(this.user);
}

class AuthRegisterFailure extends AuthState {
  final String error;

  AuthRegisterFailure(this.error);
}

class AuthLoginFailure extends AuthState {
  final String error;

  AuthLoginFailure(this.error);
}
