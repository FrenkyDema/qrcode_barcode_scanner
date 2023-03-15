import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

typedef ScannedCallback = void Function(String scannedCode);

const Duration aSecond = Duration(seconds: 1);
const Duration hundredMs = Duration(milliseconds: 100);
const String lineFeed = '\n';

/// Listening keyboard input from barcode scanner
///
/// Listens to keyboard input. Upon detection of scanning button press,
/// records incoming sequence of presses, after the scanning button was released
/// provides recorded data as a string of scanning result
class QrcodeBarcodeScanner {
  final _pressedKeys = <LogicalKeyboardKey>{};
  final _specialKeys = <LogicalKeyboardKey, Map<LogicalKeyboardKey, String>>{};
  final ScannedCallback _onBarcodeScannedCallback;
  final Duration _bufferDuration;
  final bool _useKeyDownEvent;

  final Map<String, Map<String, String?>> _keyMappings = {
    "a": {"normal": "a", "shift": "A", "altGr": null},
    "b": {"normal": "b", "shift": "B", "altGr": null},
    "c": {"normal": "c", "shift": "C", "altGr": null},
    "d": {"normal": "d", "shift": "D", "altGr": null},
    "e": {"normal": "e", "shift": "E", "altGr": null},
    "f": {"normal": "f", "shift": "F", "altGr": null},
    "g": {"normal": "g", "shift": "G", "altGr": null},
    "h": {"normal": "h", "shift": "H", "altGr": null},
    "i": {"normal": "i", "shift": "I", "altGr": null},
    "j": {"normal": "j", "shift": "J", "altGr": null},
    "k": {"normal": "k", "shift": "K", "altGr": null},
    "l": {"normal": "l", "shift": "L", "altGr": null},
    "m": {"normal": "m", "shift": "M", "altGr": null},
    "n": {"normal": "n", "shift": "N", "altGr": null},
    "o": {"normal": "o", "shift": "O", "altGr": null},
    "p": {"normal": "p", "shift": "P", "altGr": null},
    "q": {"normal": "q", "shift": "Q", "altGr": null},
    "r": {"normal": "r", "shift": "R", "altGr": null},
    "s": {"normal": "s", "shift": "S", "altGr": null},
    "t": {"normal": "t", "shift": "T", "altGr": null},
    "u": {"normal": "u", "shift": "U", "altGr": null},
    "v": {"normal": "v", "shift": "V", "altGr": null},
    "w": {"normal": "w", "shift": "W", "altGr": null},
    "x": {"normal": "x", "shift": "X", "altGr": null},
    "y": {"normal": "y", "shift": "Y", "altGr": null},
    "z": {"normal": "z", "shift": "Z", "altGr": null},
    "1": {"normal": "1", "shift": "!", "altGr": null},
    "2": {"normal": "2", "shift": "@", "altGr": null},
    "3": {"normal": "3", "shift": "#", "altGr": null},
    "4": {"normal": "4", "shift": "\$", "altGr": null},
    "5": {"normal": "5", "shift": "%", "altGr": null},
    "6": {"normal": "6", "shift": "^", "altGr": null},
    "7": {"normal": "7", "shift": "&", "altGr": null},
    "8": {"normal": "8", "shift": "*", "altGr": null},
    "9": {"normal": "9", "shift": "(", "altGr": null},
    "0": {"normal": "0", "shift": ")", "altGr": null},
    "`": {"normal": "`", "shift": "~", "altGr": null},
    "-": {"normal": "-", "shift": "_", "altGr": null},
    "=": {"normal": "=", "shift": "+", "altGr": null},
    "[": {"normal": "[", "shift": "{", "altGr": null},
    "]": {"normal": "]", "shift": "}", "altGr": null},
    "\\": {"normal": "\\", "shift": "|", "altGr": null},
    ";": {"normal": ";", "shift": ":", "altGr": null},
    "'": {"normal": "'", "shift": "\"", "altGr": null},
    ",": {"normal": ",", "shift": "<", "altGr": null},
    ".": {"normal": ".", "shift": ">", "altGr": null},
    "/": {"normal": "/", "shift": "?", "altGr": null},
    " ": {"normal": " ", "shift": null, "altGr": null},
    "Tab": {"normal": "\t", "shift": null, "altGr": null},
    "Enter": {"normal": "\n", "shift": null, "altGr": null},
    "Numpad /": {"normal": "/", "shift": null, "altGr": null},
    "Numpad *": {"normal": "*", "shift": null, "altGr": null},
    "Numpad -": {"normal": "-", "shift": null, "altGr": null},
    "Numpad +": {"normal": "+", "shift": null, "altGr": null},
    "Numpad Enter": {"normal": "\n", "shift": null, "altGr": null},
    "Numpad 1": {"normal": "1", "shift": null, "altGr": null},
    "Numpad 2": {"normal": "2", "shift": null, "altGr": null},
    "Numpad 3": {"normal": "3", "shift": null, "altGr": null},
    "Numpad 4": {"normal": "4", "shift": null, "altGr": null},
    "Numpad 5": {"normal": "5", "shift": null, "altGr": null},
    "Numpad 6": {"normal": "6", "shift": null, "altGr": null},
    "Numpad 7": {"normal": "7", "shift": null, "altGr": null},
    "Numpad 8": {"normal": "8", "shift": null, "altGr": null},
    "Numpad 9": {"normal": "9", "shift": null, "altGr": null},
    "Numpad 0": {"normal": "0", "shift": null, "altGr": null},
    "Numpad .": {"normal": ".", "shift": null, "altGr": null},
  };

  QrcodeBarcodeScanner({
    bool useKeyDownEvent = true,
    required ScannedCallback onBarcodeScannedCallback,
    Duration bufferDuration = hundredMs,
  })  : _onBarcodeScannedCallback = onBarcodeScannedCallback,
        _bufferDuration = bufferDuration,
        _useKeyDownEvent = useKeyDownEvent {
    final keyboardLocale = ui.window.locale.languageCode;
    print('Keyboard language: $keyboardLocale');
    RawKeyboard.instance.addListener(_keyBoardCallback);
    _controller.stream.where((char) => char != null).listen(onKeyEvent);
  }

  final List<String> _scannedChars = [];
  DateTime? _lastScannedCharCodeTime;

  final _controller = StreamController<String?>();

  void _keyBoardCallback(RawKeyEvent event) {
    final isKeyDown =
        _useKeyDownEvent ? event is RawKeyDownEvent : event is RawKeyUpEvent;

    if (isKeyDown) {
      final logicalKey = event.logicalKey;
      final specialKey = _keyMappings[logicalKey];
      if (specialKey != null) {
        _pressedKeys.add(logicalKey);
      }
      final key = _getKeyForLogicalKey(logicalKey);
      print('Pressed key: $key');
      _controller.add(key);
    } else {
      _pressedKeys.remove(event.logicalKey);
    }
  }

  void onKeyEvent(String? key) {
    if (_lastScannedCharCodeTime == null ||
        DateTime.now().difference(_lastScannedCharCodeTime!) >
            _bufferDuration) {
      _scannedChars.clear();
    }
    _lastScannedCharCodeTime = DateTime.now();
    _scannedChars.add(key!);
    final scannedCode = _scannedChars.join();
    print('Scanned code: $scannedCode');
    if (scannedCode.contains(lineFeed)) {
      final codes = scannedCode.split(lineFeed);
      final lastCode = codes.removeLast();
      codes.forEach(_onBarcodeScannedCallback);
      _onBarcodeScannedCallback(lastCode);
      _scannedChars.clear();
    }
  }

  int _getKeyForMappedKey(String key, List<String> modifiers) {
    // Map the key to its standard equivalent
    String standardKey = "";
    if (_keyMappings.containsKey(key)) {
      Map<String, String?> keyMap = _keyMappings[key]!;
      if (modifiers.contains("shift") && keyMap["shift"] != null) {
        standardKey = keyMap["shift"]!;
      } else if (modifiers.contains("altGr") && keyMap["altGr"] != null) {
        standardKey = keyMap["altGr"]!;
      } else {
        standardKey = keyMap["normal"]!;
      }
    } else {
      standardKey = key;
    }

    // Generate the key code based on the standard key and modifiers
    int keyCode = standardKey.codeUnitAt(0);
    if (modifiers.contains("shift")) {
      keyCode |= ModifierKey.shiftModifier;
    }
    if (modifiers.contains("alt")) {
      keyCode |= ModifierKey.altModifier;
    }
    if (modifiers.contains("control")) {
      keyCode |= ModifierKey.controlModifier;
    }
    if (modifiers.contains("meta")) {
      keyCode |= ModifierKey.metaModifier;
    }
    return keyCode;
  }

  LogicalKeyboardKey _getKeyForLogicalKey(LogicalKeyboardKey key) {
    final modifiers = <String>[];
    if (_pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.shiftRight)) {
      modifiers.add('shift');
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.altLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.altRight)) {
      modifiers.add('alt');
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.controlRight)) {
      modifiers.add('ctrl');
    }

    final specialKey = _specialKeys[key];
    if (specialKey != null) {
      final physicalKey = specialKey.keys.firstWhere(
            (k) => _pressedKeys.contains(k),
        orElse: () => null,
      );
      if (physicalKey != null) {
        final mappedKey = _keyMappings[specialKey[physicalKey]];
        if (mappedKey != null) {
          final defaultKey = mappedKey['default'];
          return LogicalKeyboardKey.findKeyByKeyId(
              _getKeyForMappedKey(_keyMappings[String.fromCharCodes(keyChars)]?['default'] ?? '', modifiers) as int
          ) ?? LogicalKeyboardKey(LogicalKeyboardKey.unknown);

        }
        return specialKey[physicalKey]!;
      }
    }

    final keyLabel = key.keyLabel;
    if (keyLabel == null || keyLabel.isEmpty) {
      return LogicalKeyboardKey.none;
    }
    final keyChars = keyLabel.runes.toList();
    return LogicalKeyboardKey.findKeyByKeyId(
        _getKeyForMappedKey(_keyMappings[String.fromCharCodes(keyChars)]?['default'] ?? '', modifiers).toInt()
    ) ?? LogicalKeyboardKey(LogicalKeyboardKey.unknown);
  }

}
