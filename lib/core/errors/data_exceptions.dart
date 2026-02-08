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
  const ServerException(super.message, [super.originalError]);
}

/// Excepción para errores de conexión con la base de datos
class DatabaseException extends DataException {
  const DatabaseException(super.message, [super.originalError]);
}

/// Excepción para cuando no se encuentra un recurso
class NotFoundException extends DataException {
  const NotFoundException(super.message, [super.originalError]);
}

/// Excepción para cuando hay un error de autenticación
class AuthException extends DataException {
  const AuthException(super.message, [super.originalError]);
}

/// Excepción para cuando hay un error en datos locales
class LocalDataException extends DataException {
  const LocalDataException(super.message, [super.originalError]);
}

/// Excepción para errores desconocidos
class UnknownDataException extends DataException {
  const UnknownDataException([dynamic originalError])
      : super('Unknown data error occurred', originalError);
}
