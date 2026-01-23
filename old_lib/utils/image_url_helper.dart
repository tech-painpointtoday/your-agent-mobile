import 'package:youragent/flavors.dart';

/// Helper class to construct image URLs from API responses
class ImageUrlHelper {
  /// Get the base URL for images (API base URL without /api)
  static String get imageBaseUrl {
    final apiBaseUrl = F.baseUrl;
    // Remove /api from the end if present
    if (apiBaseUrl.endsWith('/api')) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
    }
    return apiBaseUrl;
  }

  /// Construct full URL for profile photo
  /// profilePhoto can be:
  /// - Full URL (starts with http:// or https://)
  /// - Relative path (e.g., "buyer-profiles/1/image.png")
  static String? getProfilePhotoUrl(String? profilePhoto) {
    if (profilePhoto == null || profilePhoto.isEmpty) {
      return null;
    }

    // If it's already a full URL, return as is
    if (profilePhoto.startsWith('http://') || profilePhoto.startsWith('https://')) {
      return profilePhoto;
    }

    // Construct full URL from relative path
    // Typically Laravel storage URLs are: {baseUrl}/storage/{path}
    final baseUrl = imageBaseUrl;
    // Remove trailing slash from baseUrl if present
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    // Remove leading slash from profilePhoto if present
    final cleanPath = profilePhoto.startsWith('/') ? profilePhoto.substring(1) : profilePhoto;
    
    // Try storage path first (common Laravel pattern)
    return '$cleanBaseUrl/storage/$cleanPath';
  }
}

