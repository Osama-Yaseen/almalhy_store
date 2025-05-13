// lib/core/errors/failures.dart

/// A Failure is what you emit in your Cubit/Bloc instead of raw Exceptions.
class Failure {
  final String message;
  Failure(this.message);
}
