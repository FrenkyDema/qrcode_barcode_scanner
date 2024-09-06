import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'qrcode_barcode_scanner_method_channel.dart';

/// The interface that platform-specific implementations of QR code and barcode scanners must implement.
///
/// This class defines the contract that all platform implementations of the QR/Barcode scanner must follow.
/// It ensures that the platform-specific implementations can be dynamically loaded and replaced as needed.
abstract class QrcodeBarcodeScannerPlatform extends PlatformInterface {
  /// Constructs a QrcodeBarcodeScannerPlatform.
  ///
  /// The constructor ensures that the platform-specific implementations are validated using the provided token.
  QrcodeBarcodeScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static QrcodeBarcodeScannerPlatform _instance =
      MethodChannelQrcodeBarcodeScanner();

  /// The default instance of [QrcodeBarcodeScannerPlatform] to use.
  ///
  /// This defaults to the [MethodChannelQrcodeBarcodeScanner] implementation, which uses method channels
  /// to communicate with the native platform (iOS/Android).
  static QrcodeBarcodeScannerPlatform get instance => _instance;

  /// Allows platform-specific implementations to set their own instance.
  ///
  /// Platform-specific implementations should call this method to register their own implementation
  /// when they initialize.
  static set instance(QrcodeBarcodeScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Retrieves the platform version.
  ///
  /// This method must be overridden by the platform-specific implementation.
  /// If it's not implemented, an [UnimplementedError] will be thrown.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }
}
