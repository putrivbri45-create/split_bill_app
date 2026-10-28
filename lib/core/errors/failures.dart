import 'package:equatable/equatable.dart';

/// Domain-level failure surfaced to the UI. Never expose raw exceptions.
abstract class Failure extends Equatable implements Exception {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi bermasalah. Data disimpan offline.']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Gagal menyimpan data lokal.']);
}
