import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../services/auth_api_service.dart';
import '../../services/session_service.dart';
import '../models/agent_login_response.dart';
import '../models/user_profile_model.dart';
import '../../services/user_profile_storage_service.dart';
import '../../utils/crypto_utils.dart';
import '../../services/api_client.dart';

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  final AuthApiService _authApiService;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

      // Save profile to cache
      await UserProfileStorageService().saveProfile(profile);

      // If no cached FCM token, fetch and save it (e.g. after app update or first launch)
      final deviceService = DependencyInjection.deviceService;
      var cachedToken = await deviceService.getCachedFcmToken();
      if (cachedToken == null || cachedToken.isEmpty) {
        cachedToken = await deviceService.ensureFcmToken();
        debugPrint('fcmToken=${cachedToken.isEmpty ? "(empty)" : cachedToken}');
      }
      debugPrint('fcmToken=${cachedToken.isEmpty ? "(empty)" : cachedToken}');

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

      // Save profile to cache
      await UserProfileStorageService().saveProfile(profile);

      await SessionService().initializeSession();
      notifyListeners();

      return Right(_currentUser!);
    } catch (e) {
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
  Future<Either<Failure, User>> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _authApiService.agentRegister(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: password,
      );

      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;
      final userData = (data['user'] is Map<String, dynamic>)
          ? data['user'] as Map<String, dynamic>
          : data;

      final user = User(
        id: userData['id']?.toString(),
        email: userData['email']?.toString() ?? email,
        displayName: userData['name']?.toString() ?? name,
        photoUrl: userData['profile_photo']?.toString(),
        role: role,
        provider: 'email',
      );

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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

      final user = User(
        id: userData['id']?.toString(),
        email: userData['email']?.toString() ?? email,
        displayName: userData['name']?.toString() ?? name,
        photoUrl: userData['profile_photo']?.toString(),
        role: UserRole.agent,
        provider: 'email',
      );

      // Do NOT set _currentUser or initialize session here.
      // Registration success != Authenticated state if email verification is pending.
      // We return the user object so the BLoC can emit a success state with user info.

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle(UserRole role) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(CancellationFailure('User cancelled Google Sign-In'));
      }

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? 'Google User';
      final String socialId = googleUser.id;

      final password = CryptoUtils.generateDeterministicPassword(socialId);

      // Try login first
      final loginResult = await signInWithEmail(
        email: email,
        password: password,
        role: role,
      );

      return loginResult.fold((failure) async {
        // If login fails, try to register (legacy backend requirement)
        // Simple heuristic: if it's a server failure or unauthorized, try register.
        // In a real app, you'd check for a specific "USER_NOT_FOUND" error code.
        return registerWithEmail(
          name: name,
          email: email,
          password: password,
          role: role,
        );
      }, (user) => Right(user));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook(UserRole role) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        final String? email = userData['email'] as String?;
        final String name = userData['name'] as String? ?? 'Facebook User';
        final String? socialId = userData['id'] as String?;

        if (email == null || socialId == null) {
          return Left(ServerFailure('Failed to get email or ID from Facebook'));
        }

        final password = CryptoUtils.generateDeterministicPassword(socialId);

        // Try login first
        final loginResult = await signInWithEmail(
          email: email,
          password: password,
          role: role,
        );

        return loginResult.fold((failure) async {
          // If login fails, try to register
          return registerWithEmail(
            name: name,
            email: email,
            password: password,
            role: role,
          );
        }, (user) => Right(user));
      } else if (result.status == LoginStatus.cancelled) {
        return Left(CancellationFailure('User cancelled Facebook Sign-In'));
      } else {
        return Left(ServerFailure(result.message ?? 'Facebook Sign-In failed'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // 1. Unregister device token (best effort, while still authenticated)
      try {
        final deviceService = DependencyInjection.deviceService;
        final info = await deviceService.getDeviceInfo();
        if (info.token.isNotEmpty) {
          await _authApiService.unregisterDeviceToken(info);
        }
      } catch (_) {}

      // 2. Backend Logout (Best Effort)
      try {
        await _authApiService.logout();
      } catch (_) {
        // Ignore backend errors
      }

      // 3. Third Party Logout (Best Effort)
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {}

      // 4. Critical Local Cleanup
      await SessionService().clearSession();
      await UserProfileStorageService().clearProfile();
      await ApiClient().clearAuthToken();

      _currentUser = null;
      notifyListeners();

      return const Right(null);
    } catch (e) {
      // Fallback: Ensure local state is cleared even if something unexpected occurs
      _currentUser = null;
      notifyListeners();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String password,
    required String reason,
  }) async {
    try {
      await _authApiService.deleteAccount(password: password, reason: reason);

      // Perform same cleanup as signOut
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await SessionService().clearSession();
      await UserProfileStorageService().clearProfile();
      await ApiClient().clearAuthToken();
      _currentUser = null;
      notifyListeners();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
