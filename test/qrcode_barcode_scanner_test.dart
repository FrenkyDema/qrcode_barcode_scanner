import 'package:flutter_test/flutter_test.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized

  late QrcodeBarcodeScanner scanner;
  String? scannedResult;

  setUp(() {
    scannedResult = null;
    scanner = QrcodeBarcodeScanner(onScannedCallback: (code) {
      scannedResult = code;
    });
  });

  tearDown(() {
    // Dispose the scanner after each test to free resources
    scanner.dispose();
  });

  test('onScannedCallback is called with correct value', () {
    // Simulate keyboard events
    scanner.onKeyEvent('1');
    scanner.onKeyEvent('2');
    scanner.onKeyEvent('3');

    // No result should be available immediately
    expect(scannedResult, isNull);

    // Simulate a delay and check if the callback is triggered with the correct value
    Future.delayed(const Duration(milliseconds: 150), () {
      expect(scannedResult, '123');
    });
  });

  test('cancelled scan does not call callback', () {
    // Simulate a key event but cancel the delayed action
    scanner.onKeyEvent('A');
    scanner.cancelScan(); // Use the new cancelScan method
    expect(scannedResult,
        isNull); // No result expected since the scan is cancelled
  });
}
