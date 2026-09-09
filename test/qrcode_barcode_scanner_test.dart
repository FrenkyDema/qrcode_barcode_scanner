import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';

import 'us_keystrokes.dart';

/// The payload of the QR code that used to be read as `...In0ì` on a device
/// configured with an Italian keyboard layout.
const String kPayload =
    'eyJlbmRwb2ludCI6Imh0dHBzOlwvXC91bmliei5tYXJrYXMuaW5mb1wvIiwiaWQiOiIxMCIsInNlY3JldCI6IjM4NTgzNDI4M2YzMzliYThhMTA2NmZhYTc5YTdiNTVmMGE3ZjNlY2I3YWIyZDQyMDU3YmNhNmYxMzJlYzE3MjZkMjhlMWI3NTY2NGY3ZGQ1MDdlMjM5NDBmYTBmMmUzMjZlYWYxMGUxNzE0ZjZiNjg3MmQwNDViZWY0YWM5OWNlIn0=';

/// Replays [text] the way an HID scanner does on an Italian layout device:
/// US layout key codes, but characters remapped by the operating system.
Future<void> scanOnItalianLayout(String text) async {
  for (final String char in text.split('')) {
    final UsKeystroke keystroke = keystrokeFor(char);
    final String osCharacter = italianCharacterFor(keystroke, char);

    if (keystroke.shift) {
      await simulateKeyDownEvent(
        LogicalKeyboardKey.shiftLeft,
        physicalKey: PhysicalKeyboardKey.shiftLeft,
      );
    }
    await simulateKeyDownEvent(
      keystroke.logical,
      physicalKey: keystroke.physical,
      character: osCharacter,
    );
    await simulateKeyUpEvent(
      keystroke.logical,
      physicalKey: keystroke.physical,
    );
    if (keystroke.shift) {
      await simulateKeyUpEvent(
        LogicalKeyboardKey.shiftLeft,
        physicalKey: PhysicalKeyboardKey.shiftLeft,
      );
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buffering', () {
    late QrcodeBarcodeScanner scanner;
    String? scannedResult;

    setUp(() {
      scannedResult = null;
      scanner = QrcodeBarcodeScanner(
        onScannedCallback: (String code) => scannedResult = code,
      );
    });

    tearDown(() => scanner.dispose());

    testWidgets('onScannedCallback is called with the buffered value', (
      WidgetTester tester,
    ) async {
      scanner.onKeyEvent('1');
      scanner.onKeyEvent('2');
      scanner.onKeyEvent('3');

      // Nothing is delivered until the scanner has been idle for scanDelay.
      expect(scannedResult, isNull);

      await tester.pump(const Duration(milliseconds: 150));
      expect(scannedResult, '123');
    });

    testWidgets('cancelled scan does not call the callback', (
      WidgetTester tester,
    ) async {
      scanner.onKeyEvent('A');
      scanner.cancelScan();

      await tester.pump(const Duration(milliseconds: 150));
      expect(scannedResult, isNull);
    });

    testWidgets('flush delivers the scan immediately', (
      WidgetTester tester,
    ) async {
      scanner.onKeyEvent('A');
      scanner.onKeyEvent('B');
      scanner.flush();

      expect(scannedResult, 'AB');
    });

    testWidgets('consecutive scans do not leak into each other', (
      WidgetTester tester,
    ) async {
      scanner.onKeyEvent('1');
      await tester.pump(const Duration(milliseconds: 150));
      expect(scannedResult, '1');

      scanner.onKeyEvent('2');
      await tester.pump(const Duration(milliseconds: 150));
      expect(scannedResult, '2');
    });
  });

  group('keyboard layout decoding', () {
    testWidgets('reads a base64 payload correctly on an Italian layout', (
      WidgetTester tester,
    ) async {
      String? scannedResult;
      final QrcodeBarcodeScanner scanner = QrcodeBarcodeScanner(
        onScannedCallback: (String code) => scannedResult = code,
      );
      addTearDown(scanner.dispose);

      await scanOnItalianLayout(kPayload);
      await tester.pump(const Duration(milliseconds: 150));

      expect(scannedResult, kPayload);
      expect(scannedResult, endsWith('In0='));
    });

    testWidgets('ScannerKeyMapping.platformCharacter keeps the OS character', (
      WidgetTester tester,
    ) async {
      String? scannedResult;
      final QrcodeBarcodeScanner scanner = QrcodeBarcodeScanner(
        keyMapping: ScannerKeyMapping.platformCharacter,
        onScannedCallback: (String code) => scannedResult = code,
      );
      addTearDown(scanner.dispose);

      await scanOnItalianLayout('In0=');
      await tester.pump(const Duration(milliseconds: 150));

      // This is the pre-4.0.0 behaviour, kept as an opt-in for scanners that
      // are programmed with the same layout as the device.
      expect(scannedResult, 'In0ì');
    });
  });

  group('terminator keys', () {
    testWidgets('Enter delivers the scan without waiting for scanDelay', (
      WidgetTester tester,
    ) async {
      String? scannedResult;
      final QrcodeBarcodeScanner scanner = QrcodeBarcodeScanner(
        onScannedCallback: (String code) => scannedResult = code,
      );
      addTearDown(scanner.dispose);

      await scanOnItalianLayout('42');
      expect(scannedResult, isNull);

      await simulateKeyDownEvent(
        LogicalKeyboardKey.enter,
        physicalKey: PhysicalKeyboardKey.enter,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.enter,
        physicalKey: PhysicalKeyboardKey.enter,
      );

      // Delivered synchronously, before the idle timer would have fired.
      expect(scannedResult, '42');
    });

    testWidgets('the terminator is not appended to the scanned value', (
      WidgetTester tester,
    ) async {
      String? scannedResult;
      final QrcodeBarcodeScanner scanner = QrcodeBarcodeScanner(
        onScannedCallback: (String code) => scannedResult = code,
      );
      addTearDown(scanner.dispose);

      await scanOnItalianLayout('ab');
      await simulateKeyDownEvent(
        LogicalKeyboardKey.tab,
        physicalKey: PhysicalKeyboardKey.tab,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.tab,
        physicalKey: PhysicalKeyboardKey.tab,
      );
      await tester.pump(const Duration(milliseconds: 150));

      expect(scannedResult, 'ab');
    });
  });

  testWidgets('dispose stops delivering scans', (WidgetTester tester) async {
    String? scannedResult;
    final QrcodeBarcodeScanner scanner = QrcodeBarcodeScanner(
      onScannedCallback: (String code) => scannedResult = code,
    );

    scanner.onKeyEvent('X');
    scanner.dispose();

    await tester.pump(const Duration(milliseconds: 150));
    expect(scannedResult, isNull);

    // Disposing twice must be safe.
    scanner.dispose();
  });
}
