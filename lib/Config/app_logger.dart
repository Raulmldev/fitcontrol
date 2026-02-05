import 'package:flutter/foundation.dart';

/// Logger condicional que solo imprime en modo debug
/// 
/// Uso: AppLogger.log('Mensaje');
/// En release mode, no hace nada (performance optimizado)
class AppLogger {
  AppLogger._(); // Constructor privado

  static bool get _isDebug => kDebugMode;

  /// Log de información
  static void log(String message, {String? tag}) {
    if (_isDebug) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Log de error
  static void error(String message, {Object? error, String? tag}) {
    if (_isDebug) {
      final prefix = tag != null ? '[ERROR][$tag] ' : '[ERROR] ';
      debugPrint('$prefix$message');
      if (error != null) {
        debugPrint('${prefix}Details: $error');
      }
    }
  }

  /// Log de warning
  static void warning(String message, {String? tag}) {
    if (_isDebug) {
      final prefix = tag != null ? '[WARN][$tag] ' : '[WARN] ';
      debugPrint('$prefix$message');
    }
  }

  /// Log de servicios de comida
  static void food(String message) => log(message, tag: 'FOOD');
  
  /// Log de servicios de API
  static void api(String message) => log(message, tag: 'API');
  
  /// Log de base de datos
  static void database(String message) => log(message, tag: 'DB');
  
  /// Log de IA
  static void ai(String message) => log(message, tag: 'AI');
}
