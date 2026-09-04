class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  ServerException();

  static const String message = 'Internal Server Error';
  static const int statusCode = 500;

  @override
  String toString() => message;
}

class StreamException implements Exception {
  const StreamException(this.message);

  final String message;

  @override
  String toString() => message;
}