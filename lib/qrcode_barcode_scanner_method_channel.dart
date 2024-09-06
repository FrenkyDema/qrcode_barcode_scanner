import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'qrcode_barcode_scanner_platform_interface.dart';

/// An implementation of [QrcodeBarcodeScannerPlatform] that uses method channels
/// to communicate with the native platform.
class MethodChannelQrcodeBarcodeScanner extends QrcodeBarcodeScannerPlatform {
  /// The method channel used to interact with the native platform.
  ///
  /// This channel is responsible for sending messages to and receiving messages from
  /// the native Android or iOS layer.
  @visibleForTesting
  final methodChannel = const MethodChannel('qrcode_barcode_scanner');

  /// Gets the platform version from the native platform.
  ///
  /// This method invokes the `getPlatformVersion` method on the native side and
  /// returns the result as a [String]. If the method call fails, it catches the error
  /// and returns `null`.
  @override
  Future<String?> getPlatformVersion() async {
    try {
      final version =
          await methodChannel.invokeMethod<String>('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      // Handle potential exceptions that may occur when invoking the method
      debugPrint('Failed to get platform version: ${e.message}');
      return null;
    }
  }
}
