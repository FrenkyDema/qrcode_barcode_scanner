import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner_method_channel.dart';

void main() {
  MethodChannelQrcodeBarcodeScanner platform =
      MethodChannelQrcodeBarcodeScanner();
  const MethodChannel channel = MethodChannel('qrcode_barcode_scanner');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mocking the method channel to return specific values for the test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getPlatformVersion') {
        return '42';
      }
      return null;
    });
  });

  tearDown(() {
    // Clean up the mock handler after each test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion returns correct value', () async {
    final version = await platform.getPlatformVersion();
    expect(version, '42');
  });

  test('getPlatformVersion returns null for unknown method', () async {
    // Simulating an unknown method call that should return null
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });

    final version = await platform.getPlatformVersion();
    expect(version, isNull);
  });
}
