import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'qrcode_barcode_scanner_platform_interface.dart';

/// An implementation of [QrcodeBarcodeScannerPlatform] that uses method channels.
class MethodChannelQrcodeBarcodeScanner extends QrcodeBarcodeScannerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('qrcode_barcode_scanner');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
