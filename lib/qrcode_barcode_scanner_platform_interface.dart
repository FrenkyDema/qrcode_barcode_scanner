import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'qrcode_barcode_scanner_method_channel.dart';

abstract class QrcodeBarcodeScannerPlatform extends PlatformInterface {
  /// Constructs a QrcodeBarcodeScannerPlatform.
  QrcodeBarcodeScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static QrcodeBarcodeScannerPlatform _instance =
      MethodChannelQrcodeBarcodeScanner();

  /// The default instance of [QrcodeBarcodeScannerPlatform] to use.
  ///
  /// Defaults to [MethodChannelQrcodeBarcodeScanner].
  static QrcodeBarcodeScannerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [QrcodeBarcodeScannerPlatform] when
  /// they register themselves.
  static set instance(QrcodeBarcodeScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
