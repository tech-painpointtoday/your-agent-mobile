import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository repository;
  SignInWithEmail(this.repository);

  Future<Either<Failure, User>> call(SignInParams params) {
    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  final UserRole role;

  const SignInParams({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class RegisterAgent {
  final AuthRepository repository;
  RegisterAgent(this.repository);

  Future<Either<Failure, User>> call(RegisterAgentParams params) {
    return repository.registerAgent(
      name: params.name,
      email: params.email,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}

class RegisterAgentParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterAgentParams({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future<Either<Failure, void>> call() => repository.signOut();
}

