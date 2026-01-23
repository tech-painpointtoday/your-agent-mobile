import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../services/auth_api_service.dart';
import '../../services/session_service.dart';
import '../models/agent_login_response.dart';
import '../models/user_profile_model.dart';

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  final AuthApiService _authApiService;

  User? _currentUser;
  UserRole _role = UserRole.agent;

  AuthRepositoryImpl({required AuthApiService authApiService})
    : _authApiService = authApiService;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  User? get currentUser => _currentUser;

  @override
  UserRole? get currentRole => _currentUser?.role ?? _role;

  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }

  @override
  Future<void> restoreAuthState() async {
    if (_currentUser != null) return;
    try {
      final userData = await _authApiService.getCurrentUser();
      final profile = UserProfileModel.fromJson(userData);

      // Role inference (default agent)
      var role = UserRole.agent;
      final rawRole = userData['role']?.toString().toLowerCase();
      if (rawRole == 'agency') role = UserRole.agency;

      _currentUser = User(
        id: profile.id.toString(),
        email: profile.email,
        displayName: profile.name,
        photoUrl: profile.profilePhoto,
        role: role,
        provider: 'email',
      );

      notifyListeners();
    } catch (_) {
      // token invalid; treat as logged out
      _currentUser = null;
      notifyListeners();
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final raw = switch (role) {
        UserRole.agent => await _authApiService.agentLogin(
          email: email,
          password: password,
        ),
        UserRole.agency => await _authApiService.agencyLogin(
          email: email,
          password: password,
        ),
      };

      // EMAIL_NOT_VERIFIED sometimes comes back as success:false + error payload
      if (raw['success'] == false && raw['error'] is Map<String, dynamic>) {
        final err = raw['error'] as Map<String, dynamic>;
        if (err['code'] == 'EMAIL_NOT_VERIFIED') {
          return Left(
            EmailNotVerifiedFailure(
              (err['message']?.toString() ??
                  'Email verification is required. Please verify your email before logging in.'),
              email: email,
            ),
          );
        }
      }

      final login = AgentLoginResponse.fromJson(raw);
      final profile = login.user;

      _currentUser = User(
        id: profile.id.toString(),
        email: profile.email,
        displayName: profile.name,
        photoUrl: profile.profilePhoto,
        role: role,
        provider: 'email',
      );

      await SessionService().initializeSession();
      notifyListeners();

      return Right(_currentUser!);
    } catch (e) {
      // EMAIL_NOT_VERIFIED can be thrown as DioException with structured data
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData['success'] == false &&
            responseData['error'] is Map<String, dynamic>) {
          final err = responseData['error'] as Map<String, dynamic>;
          if (err['code'] == 'EMAIL_NOT_VERIFIED') {
            return Left(
              EmailNotVerifiedFailure(
                (err['message']?.toString() ??
                    'Email verification is required. Please verify your email before logging in.'),
                email: email,
              ),
            );
          }
        }
      }
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, User>> registerAgent({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _authApiService.agentRegister(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;
      final userData = (data['user'] is Map<String, dynamic>)
          ? data['user'] as Map<String, dynamic>
          : data;

      _currentUser = User(
        id: userData['id']?.toString(),
        email: userData['email']?.toString() ?? email,
        displayName: userData['name']?.toString() ?? name,
        photoUrl: userData['profile_photo']?.toString(),
        role: UserRole.agent,
        provider: 'email',
      );

      await SessionService().initializeSession();
      notifyListeners();

      return Right(_currentUser!);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      try {
        await _authApiService.logout();
      } catch (_) {
        // continue with local logout
      }
      await SessionService().clearSession();
      _currentUser = null;
      notifyListeners();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
