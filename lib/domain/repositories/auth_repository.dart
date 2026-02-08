import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
    required UserRole role,
  });

  /// Register with email and password
  Future<Either<Failure, User>> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Register agent
  Future<Either<Failure, User>> registerAgent({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle(UserRole role);

  /// Sign in with Facebook
  Future<Either<Failure, User>> signInWithFacebook(UserRole role);

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Get current user
  User? get currentUser;

  /// Get current role
  UserRole? get currentRole;

  /// Restore authentication state from stored token
  Future<void> restoreAuthState();
}
