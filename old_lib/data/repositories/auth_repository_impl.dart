import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:youragent/core/errors/failures.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/domain/repositories/auth_repository.dart';
import 'package:youragent/services/auth_api_service.dart';
import 'package:youragent/services/api_client.dart';
import 'package:youragent/services/session_service.dart';
import 'package:youragent/services/user_profile_storage_service.dart';
import 'package:youragent/data/models/agent_login_response.dart';
import 'package:youragent/data/models/user_profile_model.dart';

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final AuthApiService _authApiService;
  UserRole? _pendingRole; // Store role for next sign-in

  User? _currentUser;

  AuthRepositoryImpl({AuthApiService? authApiService})
    : _authApiService = authApiService ?? AuthApiService(ApiClient());

  GoogleSignIn get googleSignIn => _googleSignIn;

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  UserRole? get currentRole => _currentUser?.role;

  /// Restore authentication state from stored token
  /// This should be called on app startup to restore user session
  @override
  Future<void> restoreAuthState() async {
    // If user is already set, no need to restore
    if (_currentUser != null) {
      debugPrint('✅ User already authenticated, skipping restore');
      return;
    }

    try {
      // Check if token exists by trying to read it
      // We'll use a simple check - if getCurrentUser succeeds, we have a valid token
      debugPrint('🔍 Attempting to restore user state from token...');

      // Try to fetch current user from API (this will fail if token is invalid)
      final userData = await _authApiService.getCurrentUser();
      final userProfile = UserProfileModel.fromJson(userData);

      // Determine role from user data or default to agent
      // Check if user is agency based on API response
      UserRole role = UserRole.agent; // Default

      // Try to get role from API response
      if (userData['role'] != null) {
        final roleStr = userData['role'].toString().toLowerCase();
        if (roleStr == 'agency') {
          role = UserRole.agency;
        }
      }

      // Also check if user has agency_id (indicates agency role)
      if (userData['agency_id'] != null && userData['agency_id'] != 'null') {
        // User is associated with an agency, but might still be an agent
        // Keep default agent role unless explicitly set above
      }

      // Restore user from profile
      final user = User(
        id: userProfile.id.toString(),
        email: userProfile.email,
        displayName: userProfile.name,
        photoUrl: userProfile.profilePhoto,
        role: role,
        provider: 'email',
      );

      _currentUser = user;

      // Save profile to storage
      await UserProfileStorageService().saveProfile(userProfile);

      debugPrint(
        '✅ User state restored: ${user.email}, Role: ${user.role.name}',
      );

      // Notify listeners so router can update
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Failed to restore auth state (token may be invalid): $e');
      // If restore fails, token is likely invalid - clear it
      try {
        final apiClient = ApiClient();
        await apiClient.clearAuthToken();
        await SessionService().clearSession();
        _currentUser = null;
        notifyListeners();
      } catch (clearError) {
        debugPrint('⚠️ Error clearing invalid token: $clearError');
      }
    }
  }

  /// Initialize Google Sign-In following the official example pattern
  /// https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/example/lib/main.dart
  Future<void> initializeGoogleSignIn({
    String? clientId,
    String? serverClientId,
  }) async {
    try {
      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );

      // Listen to authentication events following the official example pattern
      _googleSignIn.authenticationEvents
          .listen(_handleAuthenticationEvent)
          .onError(_handleAuthenticationError);

      // Attempt lightweight authentication
      _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
    }
  }

  /// Handle authentication events from the stream (following example pattern)
  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user != null && _pendingRole != null) {
      // User signed in - create User entity
      try {
        // Get authorization (following example pattern, even if not used immediately)
        await user.authorizationClient.authorizationForScopes([]);

        final authenticatedUser = User(
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
          role: _pendingRole!,
          provider: 'google',
        );

        _currentUser = authenticatedUser;
        _pendingRole = null;
        notifyListeners();
        debugPrint('User signed in via stream: ${user.email}');
      } catch (e) {
        debugPrint('Error handling authentication event: $e');
      }
    } else {
      // User signed out
      _currentUser = null;
      _pendingRole = null;
      notifyListeners();
      debugPrint('User signed out via stream');
    }
  }

  /// Handle authentication errors from the stream
  Future<void> _handleAuthenticationError(Object error) async {
    debugPrint('Google Auth Error: $error');

    // IMPORTANT: Don't clear authentication state on cancellation
    // Cancellation is a user action, not an authentication failure
    // Only clear state on actual authentication errors (network, token, etc.)
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        debugPrint(
          '⚠️ Google Sign-In cancelled - preserving existing auth state',
        );
        _pendingRole = null;
        // Don't clear _currentUser or notifyListeners() - user is still authenticated
        return;
      }
    }

    // For non-cancellation errors, only clear if we don't have a valid session
    // This prevents clearing auth state when user is already logged in via email/password
    final hasValidSession = await SessionService().isSessionValid();
    if (!hasValidSession) {
      debugPrint(
        '⚠️ Clearing auth state due to authentication error (no valid session)',
      );
      _currentUser = null;
      _pendingRole = null;
      notifyListeners();
    } else {
      debugPrint(
        '⚠️ Authentication error occurred but user has valid session - preserving auth state',
      );
      _pendingRole = null;
      // Don't clear _currentUser - user is still authenticated via other means
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      Map<String, dynamic> rawResponse;
      switch (role) {
        case UserRole.agent:
          rawResponse = await _authApiService.agentLogin(
            email: email,
            password: password,
          );
          break;
        case UserRole.agency:
          rawResponse = await _authApiService.agentLogin(
            email: email,
            password: password,
          );
          break;
      }

      // Check for EMAIL_NOT_VERIFIED error before parsing response
      if (rawResponse['success'] == false && rawResponse['error'] != null) {
        final error = rawResponse['error'] as Map<String, dynamic>;
        final errorCode = error['code'] as String?;
        
        if (errorCode == 'EMAIL_NOT_VERIFIED') {
          final errorMessage = error['message'] as String? ?? 
              'Email verification is required. Please verify your email before logging in.';
          debugPrint('⚠️ Email not verified for: $email');
          return Left(EmailNotVerifiedFailure(errorMessage, email: email));
        }
      }

      // Strongly typed parsing of agent login response
      final login = AgentLoginResponse.fromJson(rawResponse);
      final profile = login.user;

      final user = User(
        id: profile.id.toString(),
        email: profile.email,
        displayName: profile.name,
        photoUrl: profile.profilePhoto,
        role: role,
        provider: 'email',
      );

      _currentUser = user;

      // Initialize session on successful login
      // Wait for session initialization to complete before notifying
      await SessionService().initializeSession();

      // Fetch and save current user profile after login
      try {
        final userData = await _authApiService.getCurrentUser();
        final userProfile = UserProfileModel.fromJson(userData);
        await UserProfileStorageService().saveProfile(userProfile);
        debugPrint('✅ User profile fetched and saved after login');
      } catch (e) {
        debugPrint('⚠️ Failed to fetch user profile after login: $e');
        // Don't fail login if profile fetch fails
      }

      // CRITICAL: Ensure _currentUser is set before notifying
      // This must be done synchronously to prevent race conditions
      if (_currentUser == null) {
        debugPrint(
          '❌ ERROR: _currentUser is null after login! This should never happen.',
        );
        return Left(ServerFailure('Login failed: User not set'));
      }

      debugPrint(
        '✅ Login successful, notifying listeners. User: ${_currentUser!.email}, Role: ${_currentUser!.role.name}',
      );

      // Notify listeners immediately - router will handle redirect automatically
      // The router's redirect logic checks isAuthenticated which reads _currentUser,
      // so we must notify after _currentUser is set (which we just verified above)
      notifyListeners();

      return Right(user);
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      
      // Check if this is a DioException with EMAIL_NOT_VERIFIED error
      if (e is DioException && e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          // Check for EMAIL_NOT_VERIFIED error in response
          if (responseData['success'] == false && responseData['error'] != null) {
            final error = responseData['error'] as Map<String, dynamic>;
            final errorCode = error['code'] as String?;
            
            if (errorCode == 'EMAIL_NOT_VERIFIED') {
              final errorMessage = error['message'] as String? ?? 
                  'Email verification is required. Please verify your email before logging in.';
              debugPrint('⚠️ Email not verified (from DioException): $email');
              return Left(EmailNotVerifiedFailure(errorMessage, email: email));
            }
          }
        }
      }
      
      return Left(ServerFailure(e.toString()));
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
      Map<String, dynamic> response;
      switch (role) {
        case UserRole.agent:
          response = await _authApiService.agentRegister(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: password,
          );
          break;
        default:
          return Left(ServerFailure('Unsupported role for registration'));
      }

      // Parse user data from response
      final userData = response['user'] ?? response;
      final user = User(
        id: userData['id']?.toString(),
        email: userData['email'] ?? email,
        displayName: userData['name'] ?? name,
        photoUrl: userData['photo_url'] ?? userData['photoUrl'],
        role: role,
        provider: 'email',
      );

      _currentUser = user;

      // Initialize session on successful login
      await SessionService().initializeSession();

      notifyListeners();

      return Right(user);
    } catch (e) {
      debugPrint('Error registering with email: $e');
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

      // Parse user data from response
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final userData = data['user'] as Map<String, dynamic>? ?? data;

      final user = User(
        id: userData['id']?.toString(),
        email: userData['email'] ?? email,
        displayName: userData['name'] ?? name,
        photoUrl: userData['profile_photo'] ?? userData['profilePhoto'],
        role: UserRole.agent,
        provider: 'email',
      );

      _currentUser = user;

      // Initialize session on successful registration
      await SessionService().initializeSession();
      await Future.delayed(const Duration(milliseconds: 200));

      if (_currentUser != null) {
        debugPrint(
          '✅ Registration successful, notifying listeners. User: ${_currentUser!.email}',
        );
        notifyListeners();
      }

      return Right(user);
    } catch (e) {
      debugPrint('Error registering agent: $e');
      return Left(ServerFailure('Failed to register agent: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle(UserRole role) async {
    try {
      // Store role for stream-based authentication (web) or immediate use (mobile)
      _pendingRole = role;

      // Following example pattern: call authenticate() directly
      // For web, this will trigger authenticationEvents stream
      // For mobile, this returns the account directly
      final account = await _googleSignIn.authenticate();
      // Get authorization (following example pattern, even if not used immediately)
      await account.authorizationClient.authorizationForScopes([]);

      final user = User(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        role: role,
        provider: 'google',
      );

      _currentUser = user;
      _pendingRole = null;

      // Initialize session on successful login
      await SessionService().initializeSession();

      notifyListeners();

      return Right(user);
    } on GoogleSignInException catch (e) {
      _pendingRole = null;
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return Left(CancellationFailure('Sign in cancelled by user'));
      }
      debugPrint('Error signing in with Google: $e');
      return Left(
        ServerFailure('Failed to sign in with Google: ${e.toString()}'),
      );
    } catch (e) {
      _pendingRole = null;
      debugPrint('Error signing in with Google: $e');
      return Left(
        ServerFailure('Failed to sign in with Google: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook(UserRole role) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Access token available but not used immediately
        final _ = result.accessToken!;
        final userData = await FacebookAuth.instance.getUserData();

        final user = User(
          id: userData['id'] as String?,
          email: userData['email'] as String? ?? '',
          displayName: userData['name'] as String?,
          photoUrl: (userData['picture'] as Map?)?['data']?['url'] as String?,
          role: role,
          provider: 'facebook',
        );

        _currentUser = user;

        // Initialize session on successful login
        await SessionService().initializeSession();

        notifyListeners();

        return Right(user);
      } else if (result.status == LoginStatus.cancelled) {
        return Left(CancellationFailure('Sign in cancelled by user'));
      } else {
        return Left(ServerFailure('Facebook login failed: ${result.message}'));
      }
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      return Left(
        ServerFailure('Failed to sign in with Facebook: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Call API logout
      try {
        await _authApiService.logout();
      } catch (e) {
        // Continue with local logout even if API call fails
        debugPrint('API logout failed, continuing with local logout: $e');
      }

      // Sign out from social providers
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();

      // Clear session data
      await SessionService().clearSession();

      // Clear user profile data from SharedPreferences
      await UserProfileStorageService().clearProfile();

      _currentUser = null;
      notifyListeners();

      return const Right(null);
    } catch (e) {
      debugPrint('Error signing out: $e');
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }
}
