import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

enum UserRole { agent, agency }

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  UserRole? _currentRole;
  bool _isAuthenticated = false;
  String? _accessToken;
  Map<String, dynamic>? _userInfo;

  UserRole? get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  Map<String, dynamic>? get userInfo => _userInfo;

  // Set the role for the next sign-in
  void setRoleForNextSignIn(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  final _authStreamController = StreamController<GoogleSignInAccount?>.broadcast();
  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _authStreamController.stream;

  // Initialize Google Sign-In
  Future<void> initializeGoogleSignIn({String? clientId, String? serverClientId}) async {
    try {
      await _googleSignIn.initialize(clientId: clientId, serverClientId: serverClientId);

      // Listen to authentication events following the official example pattern
      _googleSignIn.authenticationEvents.listen(_handleAuthenticationEvent).onError(_handleAuthenticationError);

      // Attempt lightweight authentication
      _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
    }
  }

  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user != null) {
      // User signed in - get authorization
      try {
        final authorization = await user.authorizationClient.authorizationForScopes([]);
        final accessToken = authorization?.accessToken;

        _isAuthenticated = true;
        _accessToken = accessToken;
        _userInfo = {
          'id': user.id,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
          'role': _currentRole?.name,
          'provider': 'google',
        };

        _authStreamController.add(user);
        notifyListeners();
        debugPrint('User signed in: ${user.email}');
      } catch (e) {
        debugPrint('Error getting authorization: $e');
      }
    } else {
      // User signed out
      _isAuthenticated = false;
      _accessToken = null;
      _userInfo = null;
      _authStreamController.add(null);
      notifyListeners();
      debugPrint('User signed out');
    }
  }

  Future<void> _handleAuthenticationError(Object error) async {
    debugPrint('Google Auth Error: $error');
    _isAuthenticated = false;
    _accessToken = null;
    _userInfo = null;
    _authStreamController.add(null);
    notifyListeners();
  }

  // Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle(UserRole role) async {
    try {
      // We directly call authenticate() as it is the standard way in v7+
      // and supportsAuthenticate() check might be misleading in some envs
      final account = await _googleSignIn.authenticate();

      // Get authorization for scopes
      final authorization = await account.authorizationClient.authorizationForScopes([]);
      final accessToken = authorization?.accessToken;

      _currentRole = role;
      _isAuthenticated = true;
      _accessToken = accessToken;
      _userInfo = {
        'id': account.id,
        'email': account.email,
        'displayName': account.displayName,
        'photoUrl': account.photoUrl,
        'role': role.name,
        'provider': 'google',
      };

      _authStreamController.add(account);
      notifyListeners();
      return _userInfo;
    } catch (e) {
      if (e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Facebook
  Future<Map<String, dynamic>?> signInWithFacebook(UserRole role) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        // Get user profile
        final userData = await FacebookAuth.instance.getUserData();

        _currentRole = role;
        _isAuthenticated = true;
        _accessToken = accessToken.tokenString;
        _userInfo = {
          'id': userData['id'],
          'email': userData['email'],
          'displayName': userData['name'],
          'photoUrl': userData['picture']['data']['url'],
          'role': role.name,
          'provider': 'facebook',
        };

        notifyListeners();
        return _userInfo;
      } else if (result.status == LoginStatus.cancelled) {
        return null; // User cancelled
      } else {
        throw Exception('Facebook login failed: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmail(String email, String password, UserRole role) async {
    try {
      // TODO: Implement email/password authentication with your backend
      // This is a placeholder implementation

      _currentRole = role;
      _isAuthenticated = true;
      _accessToken = 'email_token_placeholder';
      _userInfo = {'email': email, 'role': role.name, 'provider': 'email'};

      notifyListeners();
      return _userInfo;
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  // Register with email and password (standard users)
  Future<Map<String, dynamic>?> registerWithEmail(String name, String email, String password, UserRole role) async {
    try {
      // TODO: Implement registration with your backend
      // This is a placeholder implementation

      _currentRole = role;
      _isAuthenticated = true;
      _accessToken = 'email_token_placeholder';
      _userInfo = {'name': name, 'email': email, 'role': role.name, 'provider': 'email'};

      notifyListeners();
      return _userInfo;
    } catch (e) {
      debugPrint('Error registering with email: $e');
      rethrow;
    }
  }

  // Register agent with additional business information
  Future<Map<String, dynamic>?> registerAgentWithEmail(
    String name,
    String email,
    String password,
    String licenseNumber,
    String businessType,
    String companyName,
  ) async {
    try {
      // TODO: Implement agent registration with your backend
      // This is a placeholder implementation

      _currentRole = UserRole.agent;
      _isAuthenticated = true;
      _accessToken = 'email_token_placeholder';
      _userInfo = {
        'name': name,
        'email': email,
        'role': UserRole.agent.name,
        'provider': 'email',
        'licenseNumber': licenseNumber,
        'businessType': businessType,
        'companyName': companyName,
      };

      notifyListeners();
      return _userInfo;
    } catch (e) {
      debugPrint('Error registering agent: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Google Sign-In v7 uses signOut() directly on the instance
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();

      _currentRole = null;
      _isAuthenticated = false;
      _accessToken = null;
      _userInfo = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is already signed in
  Future<bool> isSignedIn() async {
    try {
      // Check if we have stored user info (set during sign-in)
      final facebookToken = await FacebookAuth.instance.accessToken;

      return _isAuthenticated || facebookToken != null;
    } catch (e) {
      debugPrint('Error checking sign-in status: $e');
      return false;
    }
  }
}
