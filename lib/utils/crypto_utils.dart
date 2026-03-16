import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilities for cryptographic operations.
class CryptoUtils {
  /// Generates a deterministic password based on a social ID.
  ///
  /// The password format is: "YourHome99#" + first 10 characters of SHA256(socialId).
  /// This ensures it meets the backend's strict policy:
  /// - Min 8 characters
  /// - At least 1 Uppercase
  /// - At least 1 Number
  /// - At least 1 Special Character
  static String generateDeterministicPassword(String socialId) {
    // Generate SHA256 hash of the socialId
    final bytes = utf8.encode(socialId);
    final digest = sha256.convert(bytes);
    final hashString = digest.toString();

    // Combine prefix with first 10 characters of hash
    // "YourHome99#" satisfies Uppercase, Number, and Special Char.
    return 'YourHome99#${hashString.substring(0, 10)}';
  }
}
