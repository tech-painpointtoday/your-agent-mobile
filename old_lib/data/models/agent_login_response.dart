import 'package:youragent/data/models/user_profile_model.dart';

/// Agent login response model
/// Matches responses like:
/// {
///   "success": true,
///   "data": {
///     "user": { ...agent fields... },
///     "token": "..."
///   },
///   "message": "Login successful"
/// }
class AgentLoginResponse {
  final bool success;
  final UserProfileModel user;
  final String token;
  final String? message;

  AgentLoginResponse({
    required this.success,
    required this.user,
    required this.token,
    this.message,
  });

  factory AgentLoginResponse.fromJson(Map<String, dynamic> json) {
    final bool success = json['success'] as bool? ?? true;
    final String? message = json['message'] as String?;

    // The backend wraps payload under "data"
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    // User payload can be under "user" or "agent" depending on endpoint
    final userJson = (data['user'] is Map<String, dynamic>)
        ? data['user'] as Map<String, dynamic>
        : (data['agent'] is Map<String, dynamic>)
            ? data['agent'] as Map<String, dynamic>
            : data;

    // Token can be under "token" or "access_token"
    final String token = (data['token'] ??
            data['access_token'] ??
            json['token'] ??
            json['access_token'] ??
            '') as String;

    return AgentLoginResponse(
      success: success,
      user: UserProfileModel.fromJson(userJson),
      token: token,
      message: message,
    );
  }
}







