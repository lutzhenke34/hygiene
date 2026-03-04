class AppException implements Exception {
  final String message;
  final Object? original;

  AppException(this.message, [this.original]);

  @override
  String toString() => message;
}