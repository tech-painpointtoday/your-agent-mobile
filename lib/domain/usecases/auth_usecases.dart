import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Sign in with email use case
class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmail(
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

/// Register with email use case
class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.registerWithEmail(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final UserRole role;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, password, role];
}

/// Register agent use case
class RegisterAgent {
  final AuthRepository repository;

  RegisterAgent(this.repository);

  Future<Either<Failure, User>> call(RegisterAgentParams params) async {
    return await repository.registerAgent(
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

/// Sign in with Google use case
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, User>> call(UserRole role) async {
    return await repository.signInWithGoogle(role);
  }
}

/// Sign in with Facebook use case
class SignInWithFacebook {
  final AuthRepository repository;

  SignInWithFacebook(this.repository);

  Future<Either<Failure, User>> call(UserRole role) async {
    return await repository.signInWithFacebook(role);
  }
}

/// Sign out use case
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}

/// Restore auth state use case
class RestoreAuthState {
  final AuthRepository repository;

  RestoreAuthState(this.repository);

  Future<void> call() async {
    await repository.restoreAuthState();
  }
}
