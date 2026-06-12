class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class StreamException implements Exception {
  const StreamException(this.message);

  final String message;

  @override
  String toString() => message;
}