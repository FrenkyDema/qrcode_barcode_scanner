import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner_method_channel.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner_platform_interface.dart';

class MockQrcodeBarcodeScannerPlatform
    with MockPlatformInterfaceMixin
    implements QrcodeBarcodeScannerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final QrcodeBarcodeScannerPlatform initialPlatform =
      QrcodeBarcodeScannerPlatform.instance;

  test('$MethodChannelQrcodeBarcodeScanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelQrcodeBarcodeScanner>());
  });

  test('getPlatformVersion', () async {
    QrcodeBarcodeScanner testProjectPlugin =
        QrcodeBarcodeScanner(onScannedCallback: (String scannedCode) {});
    MockQrcodeBarcodeScannerPlatform fakePlatform =
        MockQrcodeBarcodeScannerPlatform();
    QrcodeBarcodeScannerPlatform.instance = fakePlatform;

    expect(await testProjectPlugin.getPlatformVersion(), '42');
  });
}
