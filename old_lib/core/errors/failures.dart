import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CancellationFailure extends Failure {
  const CancellationFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class EmailNotVerifiedFailure extends Failure {
  final String email;
  
  const EmailNotVerifiedFailure(super.message, {required this.email});
  
  @override
  List<Object> get props => [message, email];
}
