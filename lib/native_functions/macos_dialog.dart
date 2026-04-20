import 'package:flutter/services.dart';

class MacOSDialog {
  static const MethodChannel _channel = MethodChannel('midnight_player/macos_dialog');

  /// Muestra un diálogo nativo de macOS.
  ///
  /// Si [cancelText] se proporciona, el diálogo muestra un botón adicional de cancelación
  /// y devuelve `true` sólo si el usuario confirma.
  static Future<bool> show({
    required String title,
    required String message,
    String buttonText = 'OK',
    String? cancelText,
  }) async {
    final bool? result = await _channel.invokeMethod<bool>('showMacOSDialog', {
      'title': title,
      'message': message,
      'buttonText': buttonText,
      'cancelText': cancelText,
    });
    return result ?? false;
  }
}
