import 'user_profile_model.dart';

class SellerLoginResponse {
  final bool success;
  final UserProfileModel user;
  final String token;
  final String? message;

  SellerLoginResponse({
    required this.success,
    required this.user,
    required this.token,
    this.message,
  });

  factory SellerLoginResponse.fromJson(Map<String, dynamic> json) {
    final bool success = json['success'] as bool? ?? true;
    final String? message = json['message'] as String?;

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final userJson = (data['user'] is Map<String, dynamic>)
        ? data['user'] as Map<String, dynamic>
        : (data['seller'] is Map<String, dynamic>)
        ? data['seller'] as Map<String, dynamic>
        : data;

    final String token =
        (data['token'] ??
                data['access_token'] ??
                json['token'] ??
                json['access_token'] ??
                '')
            as String;

    return SellerLoginResponse(
      success: success,
      user: UserProfileModel.fromJson(userJson),
      token: token,
      message: message,
    );
  }
}
