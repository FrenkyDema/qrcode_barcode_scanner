import 'dart:async';

import 'package:flutter/services.dart';

import 'delayed_action_handler.dart';

typedef ScannedCallback = void Function(String scannedCode);

const Duration hundredMs = Duration(milliseconds: 100);

class QrcodeBarcodeScanner {
  final ScannedCallback onBarcodeScannedCallback;
  final List<String> pressedKeys = [];
  final StreamController<String?> _controller = StreamController<String?>();
  final DelayedActionHandler _actionHandler;
  final Map<String, Map<String, String?>> keyMappings = {
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
  };

  isShift(LogicalKeyboardKey key) => key.synonyms.isNotEmpty
      ? key.synonyms.first == LogicalKeyboardKey.shift
      : false;

  isKeyDown(RawKeyEvent event) => event is RawKeyDownEvent;

  String _modifier = "normal";
  QrcodeBarcodeScanner({
    required this.onBarcodeScannedCallback,
    bool useKeyDownEvent = true,
  }) : _actionHandler = DelayedActionHandler(hundredMs) {
    RawKeyboard.instance.addListener(_keyBoardCallback);
    _controller.stream.where((char) => char != null).listen(onKeyEvent);
  }

  void onKeyEvent(String? readChar) {
    if (readChar != null) {
      pressedKeys.add(readChar);
      _actionHandler.executeDelayed(() {
        final String scannedCode =
            pressedKeys.isNotEmpty ? pressedKeys.join() : "";
        onBarcodeScannedCallback(scannedCode);
        pressedKeys.clear();
      });
    }
  }

  void _keyBoardCallback(RawKeyEvent event) {
    final LogicalKeyboardKey logicalKey = event.logicalKey;
    if (isKeyDown(event)) {
      if (isShift(logicalKey)) {
        _modifier = "shift";
      } else {
        final String? key = _getKeyForLogicalKey(logicalKey);
        _controller.add(key);
      }
    } else {
      if (isShift(logicalKey)) {
        _modifier = "normal";
      }
    }
  }

  String? _getKeyForLogicalKey(LogicalKeyboardKey key) {
    final Map<String, String?>? mappedKey =
        keyMappings[key.keyLabel.toLowerCase()];

    return mappedKey?[_modifier];
  }

  void dispose() {
    RawKeyboard.instance.removeListener(_keyBoardCallback);
    _controller.close();
  }
}
