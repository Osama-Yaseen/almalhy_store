import 'user_model.dart';

/// Represents the response from the server on auth endpoints
class AuthResponse {
  /// A human‐readable message (success or error details)
  final String message;

  /// The authenticated user payload
  final UserModel user;

  /// OTP code (only present on sign-up & verification flows)
  final int? otp;

  /// Bearer token for future requests
  final String token;

  AuthResponse({
    required this.message,
    required this.user,
    this.otp,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      // only parse otp if present
      otp: json.containsKey('otp') ? (json['otp'] as num).toInt() : null,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'user': user.toJson(),
    if (otp != null) 'otp': otp,
    'token': token,
  };
}
