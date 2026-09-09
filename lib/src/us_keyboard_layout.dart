import 'package:flutter/services.dart';

/// Translation table from a [PhysicalKeyboardKey] to the character a US QWERTY
/// (ANSI) keyboard would produce for it.
///
/// Virtually every HID barcode/QR scanner ("keyboard wedge") is shipped
/// configured to emit **US layout** key codes. The operating system, however,
/// translates those key codes using the layout selected on the device, so a
/// scanner sending the key code for `=` produces `ì` on an Italian layout,
/// `´` on a Spanish one, and so on.
///
/// Decoding [PhysicalKeyboardKey] — which carries the layout independent USB
/// HID usage — through this table restores the characters the scanner actually
/// meant to send, whatever layout the device is set to.
abstract final class UsKeyboardLayout {
  /// Keys that produce a character which does not depend on Num Lock.
  ///
  /// The record holds the unshifted and the shifted character of the key.
  static final Map<PhysicalKeyboardKey, (String, String)>
  _printableKeys = <PhysicalKeyboardKey, (String, String)>{
    // Letters.
    PhysicalKeyboardKey.keyA: ('a', 'A'),
    PhysicalKeyboardKey.keyB: ('b', 'B'),
    PhysicalKeyboardKey.keyC: ('c', 'C'),
    PhysicalKeyboardKey.keyD: ('d', 'D'),
    PhysicalKeyboardKey.keyE: ('e', 'E'),
    PhysicalKeyboardKey.keyF: ('f', 'F'),
    PhysicalKeyboardKey.keyG: ('g', 'G'),
    PhysicalKeyboardKey.keyH: ('h', 'H'),
    PhysicalKeyboardKey.keyI: ('i', 'I'),
    PhysicalKeyboardKey.keyJ: ('j', 'J'),
    PhysicalKeyboardKey.keyK: ('k', 'K'),
    PhysicalKeyboardKey.keyL: ('l', 'L'),
    PhysicalKeyboardKey.keyM: ('m', 'M'),
    PhysicalKeyboardKey.keyN: ('n', 'N'),
    PhysicalKeyboardKey.keyO: ('o', 'O'),
    PhysicalKeyboardKey.keyP: ('p', 'P'),
    PhysicalKeyboardKey.keyQ: ('q', 'Q'),
    PhysicalKeyboardKey.keyR: ('r', 'R'),
    PhysicalKeyboardKey.keyS: ('s', 'S'),
    PhysicalKeyboardKey.keyT: ('t', 'T'),
    PhysicalKeyboardKey.keyU: ('u', 'U'),
    PhysicalKeyboardKey.keyV: ('v', 'V'),
    PhysicalKeyboardKey.keyW: ('w', 'W'),
    PhysicalKeyboardKey.keyX: ('x', 'X'),
    PhysicalKeyboardKey.keyY: ('y', 'Y'),
    PhysicalKeyboardKey.keyZ: ('z', 'Z'),
    // Digit row.
    PhysicalKeyboardKey.digit1: ('1', '!'),
    PhysicalKeyboardKey.digit2: ('2', '@'),
    PhysicalKeyboardKey.digit3: ('3', '#'),
    PhysicalKeyboardKey.digit4: ('4', r'$'),
    PhysicalKeyboardKey.digit5: ('5', '%'),
    PhysicalKeyboardKey.digit6: ('6', '^'),
    PhysicalKeyboardKey.digit7: ('7', '&'),
    PhysicalKeyboardKey.digit8: ('8', '*'),
    PhysicalKeyboardKey.digit9: ('9', '('),
    PhysicalKeyboardKey.digit0: ('0', ')'),
    // Punctuation. These are the keys that differ the most between layouts and
    // that carry the base64/URL characters barcodes are usually built from.
    PhysicalKeyboardKey.minus: ('-', '_'),
    PhysicalKeyboardKey.equal: ('=', '+'),
    PhysicalKeyboardKey.bracketLeft: ('[', '{'),
    PhysicalKeyboardKey.bracketRight: (']', '}'),
    PhysicalKeyboardKey.backslash: (r'\', '|'),
    PhysicalKeyboardKey.semicolon: (';', ':'),
    PhysicalKeyboardKey.quote: ("'", '"'),
    PhysicalKeyboardKey.backquote: ('`', '~'),
    PhysicalKeyboardKey.comma: (',', '<'),
    PhysicalKeyboardKey.period: ('.', '>'),
    PhysicalKeyboardKey.slash: ('/', '?'),
    PhysicalKeyboardKey.space: (' ', ' '),
    // Numeric keypad operators are layout independent.
    PhysicalKeyboardKey.numpadDivide: ('/', '/'),
    PhysicalKeyboardKey.numpadMultiply: ('*', '*'),
    PhysicalKeyboardKey.numpadSubtract: ('-', '-'),
    PhysicalKeyboardKey.numpadAdd: ('+', '+'),
    PhysicalKeyboardKey.numpadEqual: ('=', '='),
  };

  /// Keypad keys that only produce a character while Num Lock is enabled.
  ///
  /// With Num Lock off these keys act as navigation keys (arrows, home, end,
  /// …) and must not contribute any character to the scanned value.
  static final Map<PhysicalKeyboardKey, String> _numpadKeys =
      <PhysicalKeyboardKey, String>{
        PhysicalKeyboardKey.numpad0: '0',
        PhysicalKeyboardKey.numpad1: '1',
        PhysicalKeyboardKey.numpad2: '2',
        PhysicalKeyboardKey.numpad3: '3',
        PhysicalKeyboardKey.numpad4: '4',
        PhysicalKeyboardKey.numpad5: '5',
        PhysicalKeyboardKey.numpad6: '6',
        PhysicalKeyboardKey.numpad7: '7',
        PhysicalKeyboardKey.numpad8: '8',
        PhysicalKeyboardKey.numpad9: '9',
        PhysicalKeyboardKey.numpadDecimal: '.',
        PhysicalKeyboardKey.numpadComma: ',',
      };

  /// The character a US QWERTY keyboard produces for [key].
  ///
  /// Returns `null` when [key] is not a character producing key (modifiers,
  /// function keys, navigation keys, …) or when it is a keypad digit while
  /// [isNumLockOn] is `false`. Callers should fall back to the character
  /// reported by the platform in that case.
  ///
  /// [isCapsLockOn] only affects letters, exactly like a real keyboard does.
  static String? characterFor(
    PhysicalKeyboardKey key, {
    bool isShiftPressed = false,
    bool isCapsLockOn = false,
    bool isNumLockOn = true,
  }) {
    final (String, String)? mapping = _printableKeys[key];
    if (mapping != null) {
      final (String unshifted, String shifted) = mapping;
      final bool upperCase = isLetterKey(key)
          ? isShiftPressed != isCapsLockOn
          : isShiftPressed;
      return upperCase ? shifted : unshifted;
    }
    if (isNumLockOn) {
      return _numpadKeys[key];
    }
    return null;
  }

  /// Whether [key] is an alphabetic key, and therefore affected by Caps Lock.
  static bool isLetterKey(PhysicalKeyboardKey key) {
    final (String, String)? mapping = _printableKeys[key];
    if (mapping == null) {
      return false;
    }
    final int codeUnit = mapping.$1.codeUnitAt(0);
    return codeUnit >= 0x61 && codeUnit <= 0x7A; // 'a' .. 'z'
  }

  /// Whether [key] produces a character on a US QWERTY layout.
  static bool isPrintableKey(PhysicalKeyboardKey key) =>
      _printableKeys.containsKey(key) || _numpadKeys.containsKey(key);
}
