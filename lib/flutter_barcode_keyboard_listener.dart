import 'dart:async';

import 'package:flutter/services.dart';

/// Plugin that wraps Sunmi Android SDK for integrated barcode scanner
class FlutterBarcodeKeyboardListener {
  static const MethodChannel _channel = MethodChannel('flutter_barcode_keyboard_listener');

  Future<String?> getPlatformVersion() async {
    return (await _channel.invokeMethod('getPlatformVersion'));
  }
}
