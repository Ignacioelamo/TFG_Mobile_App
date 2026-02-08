////////////////////////////////////////////////
///
/// Archivo de secretos y credenciales de la aplicación
///
/// IMPORTANTE: Este archivo DEBE ser añadido a .gitignore y NO debe subirse a Git
///
/// IMPORTANTE2: Renombrar secrets_example.dart a secrets.dart
///
////////////////////////////////////////////////

class Secrets {
  Secrets._privateConstructor();

  // TODO: Reemplaza estos valores con tus credenciales reales de Supabase
  /// URL de tu proyecto Supabase
  static const supabaseUrl = 'TU_URL_DE_SUPABASE_AQUI';

  /// Clave anónima (anon/public key) de Supabase
  static const supabaseAnonKey = 'TU_CLAVE_ANONIMA_DE_SUPABASE_AQUI';
}
