/// Excepción base para errores relacionados con la capa de datos
class DataException implements Exception {
  final String message;
  final dynamic originalError;

  const DataException(this.message, [this.originalError]);

  @override
  String toString() =>
      'DataException: $message${originalError != null ? ' (Original error: $originalError)' : ''}';
}

/// Excepción para errores de servidor (por ejemplo, servidor no disponible)
class ServerException extends DataException {
  const ServerException(String message, [dynamic originalError])
      : super(message, originalError);
}

/// Excepción para errores de conexión con la base de datos
class DatabaseException extends DataException {
  const DatabaseException(String message, [dynamic originalError])
      : super(message, originalError);
}

/// Excepción para cuando no se encuentra un recurso
class NotFoundException extends DataException {
  const NotFoundException(String message, [dynamic originalError])
      : super(message, originalError);
}

/// Excepción para cuando hay un error de autenticación
class AuthException extends DataException {
  const AuthException(String message, [dynamic originalError])
      : super(message, originalError);
}

/// Excepción para cuando hay un error en datos locales
class LocalDataException extends DataException {
  const LocalDataException(String message, [dynamic originalError])
      : super(message, originalError);
}

/// Excepción para errores desconocidos
class UnknownDataException extends DataException {
  const UnknownDataException([dynamic originalError])
      : super('Unknown data error occurred', originalError);
}
