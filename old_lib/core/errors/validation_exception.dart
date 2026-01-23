class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic> details;

  ValidationException(this.message, this.details);

  @override
  String toString() => message;
}
