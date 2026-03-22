import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Servicio que comprueba si el parche de seguridad del firmware está
/// dentro del umbral configurado (ej. últimos 3 meses).
///
/// Retorna:
/// - true: el parche de seguridad está dentro del umbral
/// - false: el parche está fuera del umbral
/// - null: no se pudo determinar (ej. no Android, datos ausentes)
class UpdatedCheckService {
  UpdatedCheckService._privateConstructor();

  static final UpdatedCheckService instance = UpdatedCheckService._privateConstructor();

  /// Antigüedad máxima del parche de seguridad (aprox. 3 meses) para
  /// considerar el dispositivo como "actualizado".
  static const int securityPatchThresholdDays = 90;

  /// Comprueba si el firmware (parche de seguridad) está actualizado.
  ///
  /// Usa Build.VERSION.SECURITY_PATCH (Android) vía device_info_plus.
  /// Solo funciona en Android; en otras plataformas retorna null.
  Future<bool?> isFirmwareUpdated() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (!Platform.isAndroid) {
        return null;
      }

      final androidInfo = await deviceInfo.androidInfo;
      final securityPatch = androidInfo.version.securityPatch;

      if (securityPatch == null || securityPatch.isEmpty) {
        return null;
      }

      final patchDate = DateTime.tryParse(securityPatch);
      if (patchDate == null) {
        return null;
      }

      final now = DateTime.now();
      final cutoff = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: securityPatchThresholdDays));

      return !patchDate.isBefore(cutoff);
    } catch (_) {
      return null;
    }
  }
}
