class DatabaseException implements Exception {
  final String message;
  final dynamic error;

  const DatabaseException(this.message, {this.error});

  @override
  String toString() => 'DatabaseException: $message';
}
