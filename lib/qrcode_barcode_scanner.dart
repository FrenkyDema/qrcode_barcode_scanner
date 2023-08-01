import 'dart:async';

import 'package:flutter/services.dart';

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

  /// A map that maps key labels to their corresponding normal and shift values.
  final Map<String, Map<String, String?>> _keyMappings = {
    "a": {"normal": "a", "shift": "A"},
    "b": {"normal": "b", "shift": "B"},
    "c": {"normal": "c", "shift": "C"},
    "d": {"normal": "d", "shift": "D"},
    "e": {"normal": "e", "shift": "E"},
    "f": {"normal": "f", "shift": "F"},
    "g": {"normal": "g", "shift": "G"},
    "h": {"normal": "h", "shift": "H"},
    "i": {"normal": "i", "shift": "I"},
    "j": {"normal": "j", "shift": "J"},
    "k": {"normal": "k", "shift": "K"},
    "l": {"normal": "l", "shift": "L"},
    "m": {"normal": "m", "shift": "M"},
    "n": {"normal": "n", "shift": "N"},
    "o": {"normal": "o", "shift": "O"},
    "p": {"normal": "p", "shift": "P"},
    "q": {"normal": "q", "shift": "Q"},
    "r": {"normal": "r", "shift": "R"},
    "s": {"normal": "s", "shift": "S"},
    "t": {"normal": "t", "shift": "T"},
    "u": {"normal": "u", "shift": "U"},
    "v": {"normal": "v", "shift": "V"},
    "w": {"normal": "w", "shift": "W"},
    "x": {"normal": "x", "shift": "X"},
    "y": {"normal": "y", "shift": "Y"},
    "z": {"normal": "z", "shift": "Z"},
    "1": {"normal": "1", "shift": "!"},
    "2": {"normal": "2", "shift": "@"},
    "3": {"normal": "3", "shift": "#"},
    "4": {"normal": "4", "shift": "\$"},
    "5": {"normal": "5", "shift": "%"},
    "6": {"normal": "6", "shift": "^"},
    "7": {"normal": "7", "shift": "&"},
    "8": {"normal": "8", "shift": "*"},
    "9": {"normal": "9", "shift": "("},
    "0": {"normal": "0", "shift": ")"},
    "`": {"normal": "`", "shift": "~"},
    "-": {"normal": "-", "shift": "_"},
    "=": {"normal": "=", "shift": "+"},
    "[": {"normal": "[", "shift": "{"},
    "]": {"normal": "]", "shift": "}"},
    "\\": {"normal": "\\", "shift": "|"},
    ";": {"normal": ";", "shift": ":"},
    "'": {"normal": "'", "shift": "\""},
    ",": {"normal": ",", "shift": "<"},
    ".": {"normal": ".", "shift": ">"},
    "/": {"normal": "/", "shift": "?"},
    "Tab": {"normal": "\t", "shift": null},
    "Enter": {"normal": "\n", "shift": null},
    " ": {"normal": " ", "shift": " "},
  };

  /// Returns `true` if the [LogicalKeyboardKey] is the shift key.
  ///
  /// [key] is the logical keyboard key to check.
  bool isShift(LogicalKeyboardKey key) => key.synonyms.isNotEmpty
      ? key.synonyms.first == LogicalKeyboardKey.shift
      : false;

  /// Returns `true` if the [RawKeyEvent] is a key down event.
  ///
  /// [event] is the raw keyboard event to check.
  bool isKeyDown(RawKeyEvent event) => event is RawKeyDownEvent;

  /// The current modifier for the shift key.
  String _modifier = "normal";

  /// Creates a new instance of [QrcodeBarcodeScanner].
  ///
  /// The [onScannedCallback] parameter is a required callback function
  /// that handles scanned barcodes.
  QrcodeBarcodeScanner({required this.onScannedCallback})
      : _actionHandler = DelayedActionHandler(hundredMs) {
    RawKeyboard.instance.addListener(_keyBoardCallback);
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
        onScannedCallback(scannedCode);
        _pressedKeys.clear();
      });
    }
  }

  /// The callback function that is called when a keyboard event occurs.
  ///
  /// If [event] is a key down event, the corresponding key label is retrieved and added to the stream controller
  /// using [_getKeyForLogicalKey]. If the key is a shift key, [_modifier] is set to "shift" for the next key event.
  ///
  /// If [event] is a key up event, and the key is a shift key, [_modifier] is set to "normal".
  ///
  /// [event] is the raw keyboard event that occurred.
  void _keyBoardCallback(RawKeyEvent event) {
    final LogicalKeyboardKey logicalKey = event.logicalKey;
    if (!isKeyDown(event)) {
      if (isShift(logicalKey)) {
        _modifier = "shift";
      } else {
        final String? key = _getKeyForLogicalKey(logicalKey);
        _controller.add(key);
        _modifier = "normal";
      }
    }
  }

  /// Returns the mapped key based on the given logical keyboard key [key].
  ///
  /// The mapped key is obtained from the [_keyMappings] map. The key mappings map
  /// maps each key label to a map that maps each modifier (e.g. "normal",
  /// "shift") to a corresponding value. If the key label is not found in the
  /// map, null is returned.
  ///
  /// [key] is the logical keyboard key.
  String? _getKeyForLogicalKey(LogicalKeyboardKey key) {
    final Map<String, String?>? mappedKey =
        _keyMappings[key.keyLabel.toLowerCase()];
    return mappedKey?[_modifier];
  }

  /// Disposes the resources used by the `QrcodeBarcodeScanner`.
  ///
  /// Call this method when the `QrcodeBarcodeScanner` is no longer needed to release
  /// any resources (such as keyboard listeners) it may have acquired.
  void dispose() {
    RawKeyboard.instance.removeListener(_keyBoardCallback);
    _controller.close();
  }
}
