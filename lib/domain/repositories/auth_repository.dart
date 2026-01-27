import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<Either<Failure, User>> registerAgent({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, User>> signInWithSocial({
    required String provider,
    required String token,
    required UserRole role,
  });

  Future<Either<Failure, void>> signOut();

  bool get isAuthenticated;
  User? get currentUser;
  UserRole? get currentRole;

  Future<void> restoreAuthState();
}
