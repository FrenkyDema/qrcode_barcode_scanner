import 'dart:async';

import 'package:flutter/services.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner_platform_interface.dart';

import 'delayed_action_handler.dart';

/// A callback function type to handle scanned barcodes.
///
/// [scannedCode] is the string representing the scanned barcode.
typedef ScannedCallback = void Function(String scannedCode);

/// Duration of 100 milliseconds.
const Duration hundredMs = Duration(milliseconds: 100);

/// A class that handles scanning of QR codes and barcodes.
///
/// The [QrcodeBarcodeScanner] class listens to keyboard events to scan QR codes
/// and barcodes. It uses a [StreamController] to listen to keyboard events and
/// a [DelayedActionHandler] to handle delayed events.
class QrcodeBarcodeScanner {
  /// The callback function to handle scanned barcodes.
  final ScannedCallback onScannedCallback;

  /// A list of pressed keys.
  final List<String> _pressedKeys = [];

  /// A stream controller to listen to keyboard events.
  final StreamController<String?> _controller = StreamController<String?>();

  /// A delayed action handler to handle delayed events.
  final DelayedActionHandler _actionHandler;

  Future<String?> getPlatformVersion() {
    return QrcodeBarcodeScannerPlatform.instance.getPlatformVersion();
  }

  /// Creates a new instance of [QrcodeBarcodeScanner].
  ///
  /// The [onScannedCallback] parameter is a required callback function
  /// that handles scanned barcodes.
  QrcodeBarcodeScanner({required this.onScannedCallback})
      : _actionHandler = DelayedActionHandler(hundredMs) {
    HardwareKeyboard.instance.addHandler(_keyBoardCallback);
    _controller.stream.where((char) => char != null).listen(onKeyEvent);
  }

  /// Handles a keyboard event by adding the read character to the [_pressedKeys] list.
  ///
  /// [readChar] is the character read from the keyboard. If [readChar] is not null, it is added to the
  /// [_pressedKeys] list. If [_pressedKeys] is not empty, it is joined together to form a string [scannedCode].
  /// The [scannedCode] is passed to the [onScannedCallback] function and the [_pressedKeys] list is cleared.
  void onKeyEvent(String? readChar) {
    if (readChar != null) {
      _pressedKeys.add(readChar);
      _actionHandler.executeDelayed(() {
        final String scannedCode =
            _pressedKeys.isNotEmpty ? _pressedKeys.join() : "";
        onScannedCallback(scannedCode.trim());
        _pressedKeys.clear();
      });
    }
  }

  /// The callback function that is called when a keyboard event occurs.
  ///
  /// [event] is the raw keyboard event that occurred.
  bool _keyBoardCallback(KeyEvent event) {
    if (event.character != "" &&
        event.character != null &&
        (List.of(event.character?.codeUnits ?? [])
              ..removeWhere((element) => element == 0))
            .isNotEmpty) {
      _controller.add(event.character ?? "");
      return true;
    }
    return false;
  }

  /// Disposes the resources used by the `QrcodeBarcodeScanner`.
  ///
  /// Call this method when the `QrcodeBarcodeScanner` is no longer needed to release
  /// any resources (such as keyboard listeners) it may have acquired.
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyBoardCallback);
    _controller.close();
  }
}
