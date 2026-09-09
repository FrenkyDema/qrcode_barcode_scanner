import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';

import 'us_keystrokes.dart';

void main() {
  group('UsKeyboardLayout.characterFor', () {
    test('decodes the punctuation that non-US layouts remap', () {
      // These are exactly the keys that break on an Italian layout, where the
      // OS reports `ì` for `=`, `-` for `/` and `]` for `+`.
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.equal), '=');
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.equal,
          isShiftPressed: true,
        ),
        '+',
      );
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.slash), '/');
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.slash,
          isShiftPressed: true,
        ),
        '?',
      );
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.minus), '-');
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.minus,
          isShiftPressed: true,
        ),
        '_',
      );
      expect(
        UsKeyboardLayout.characterFor(PhysicalKeyboardKey.bracketRight),
        ']',
      );
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.semicolon), ';');
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.semicolon,
          isShiftPressed: true,
        ),
        ':',
      );
      expect(
        UsKeyboardLayout.characterFor(PhysicalKeyboardKey.backslash),
        r'\',
      );
    });

    test('applies shift to the digit row', () {
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.digit1), '1');
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.digit1,
          isShiftPressed: true,
        ),
        '!',
      );
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.digit0,
          isShiftPressed: true,
        ),
        ')',
      );
    });

    test('caps lock only affects letters, and combines with shift', () {
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.keyA), 'a');
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.keyA,
          isShiftPressed: true,
        ),
        'A',
      );
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.keyA,
          isCapsLockOn: true,
        ),
        'A',
      );
      // Shift while caps lock is on goes back to lower case, like a real
      // keyboard does.
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.keyA,
          isShiftPressed: true,
          isCapsLockOn: true,
        ),
        'a',
      );
      // Caps lock must not turn `1` into `!`.
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.digit1,
          isCapsLockOn: true,
        ),
        '1',
      );
    });

    test('keypad digits require num lock, operators do not', () {
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.numpad7), '7');
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.numpad7,
          isNumLockOn: false,
        ),
        isNull,
      );
      expect(
        UsKeyboardLayout.characterFor(
          PhysicalKeyboardKey.numpadAdd,
          isNumLockOn: false,
        ),
        '+',
      );
    });

    test('returns null for keys that produce no character', () {
      expect(
        UsKeyboardLayout.characterFor(PhysicalKeyboardKey.shiftLeft),
        isNull,
      );
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.enter), isNull);
      expect(UsKeyboardLayout.characterFor(PhysicalKeyboardKey.f1), isNull);
    });

    test('isPrintableKey and isLetterKey classify keys correctly', () {
      expect(
        UsKeyboardLayout.isPrintableKey(PhysicalKeyboardKey.equal),
        isTrue,
      );
      expect(
        UsKeyboardLayout.isPrintableKey(PhysicalKeyboardKey.numpad7),
        isTrue,
      );
      expect(
        UsKeyboardLayout.isPrintableKey(PhysicalKeyboardKey.enter),
        isFalse,
      );
      expect(UsKeyboardLayout.isLetterKey(PhysicalKeyboardKey.keyZ), isTrue);
      expect(UsKeyboardLayout.isLetterKey(PhysicalKeyboardKey.digit1), isFalse);
    });

    test('round trips a real base64 QR payload', () {
      // The payload that used to be truncated to `...In0ì` on an Italian
      // keyboard layout, because the OS remaps the physical `=` key to `ì`.
      const String payload =
          'eyJlbmRwb2ludCI6Imh0dHBzOlwvXC91bmliei5tYXJrYXMuaW5mb1wvIiwiaWQiOiIxMCIsInNlY3JldCI6IjM4NTgzNDI4M2YzMzliYThhMTA2NmZhYTc5YTdiNTVmMGE3ZjNlY2I3YWIyZDQyMDU3YmNhNmYxMzJlYzE3MjZkMjhlMWI3NTY2NGY3ZGQ1MDdlMjM5NDBmYTBmMmUzMjZlYWYxMGUxNzE0ZjZiNjg3MmQwNDViZWY0YWM5OWNlIn0=';

      final StringBuffer decoded = StringBuffer();
      for (final String char in payload.split('')) {
        final UsKeystroke keystroke = keystrokeFor(char);
        decoded.write(
          UsKeyboardLayout.characterFor(
            keystroke.physical,
            isShiftPressed: keystroke.shift,
          ),
        );
      }

      expect(decoded.toString(), payload);
      expect(decoded.toString(), endsWith('In0='));
    });
  });
}
