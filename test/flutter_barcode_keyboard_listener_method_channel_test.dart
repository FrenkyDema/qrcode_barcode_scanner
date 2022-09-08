import 'package:flutter/services.dart';
import 'package:flutter_barcode_keyboard_listener/flutter_barcode_keyboard_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FlutterBarcodeKeyboardListener platform = FlutterBarcodeKeyboardListener();
  const MethodChannel channel = MethodChannel('flutter_barcode_keyboard_listener');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
