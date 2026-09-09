import 'package:flutter/services.dart';

/// A single key press on a US QWERTY keyboard, as an HID scanner emits it.
class UsKeystroke {
  const UsKeystroke(this.physical, this.logical, {this.shift = false});

  /// The layout independent physical key (USB HID usage).
  final PhysicalKeyboardKey physical;

  /// The logical key a US layout would report for it.
  final LogicalKeyboardKey logical;

  /// Whether `Shift` is held while the key is pressed.
  final bool shift;
}

const List<PhysicalKeyboardKey> _letterPhysicalKeys = <PhysicalKeyboardKey>[
  PhysicalKeyboardKey.keyA,
  PhysicalKeyboardKey.keyB,
  PhysicalKeyboardKey.keyC,
  PhysicalKeyboardKey.keyD,
  PhysicalKeyboardKey.keyE,
  PhysicalKeyboardKey.keyF,
  PhysicalKeyboardKey.keyG,
  PhysicalKeyboardKey.keyH,
  PhysicalKeyboardKey.keyI,
  PhysicalKeyboardKey.keyJ,
  PhysicalKeyboardKey.keyK,
  PhysicalKeyboardKey.keyL,
  PhysicalKeyboardKey.keyM,
  PhysicalKeyboardKey.keyN,
  PhysicalKeyboardKey.keyO,
  PhysicalKeyboardKey.keyP,
  PhysicalKeyboardKey.keyQ,
  PhysicalKeyboardKey.keyR,
  PhysicalKeyboardKey.keyS,
  PhysicalKeyboardKey.keyT,
  PhysicalKeyboardKey.keyU,
  PhysicalKeyboardKey.keyV,
  PhysicalKeyboardKey.keyW,
  PhysicalKeyboardKey.keyX,
  PhysicalKeyboardKey.keyY,
  PhysicalKeyboardKey.keyZ,
];

const List<LogicalKeyboardKey> _letterLogicalKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyB,
  LogicalKeyboardKey.keyC,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyE,
  LogicalKeyboardKey.keyF,
  LogicalKeyboardKey.keyG,
  LogicalKeyboardKey.keyH,
  LogicalKeyboardKey.keyI,
  LogicalKeyboardKey.keyJ,
  LogicalKeyboardKey.keyK,
  LogicalKeyboardKey.keyL,
  LogicalKeyboardKey.keyM,
  LogicalKeyboardKey.keyN,
  LogicalKeyboardKey.keyO,
  LogicalKeyboardKey.keyP,
  LogicalKeyboardKey.keyQ,
  LogicalKeyboardKey.keyR,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyT,
  LogicalKeyboardKey.keyU,
  LogicalKeyboardKey.keyV,
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyX,
  LogicalKeyboardKey.keyY,
  LogicalKeyboardKey.keyZ,
];

const List<PhysicalKeyboardKey> _digitPhysicalKeys = <PhysicalKeyboardKey>[
  PhysicalKeyboardKey.digit0,
  PhysicalKeyboardKey.digit1,
  PhysicalKeyboardKey.digit2,
  PhysicalKeyboardKey.digit3,
  PhysicalKeyboardKey.digit4,
  PhysicalKeyboardKey.digit5,
  PhysicalKeyboardKey.digit6,
  PhysicalKeyboardKey.digit7,
  PhysicalKeyboardKey.digit8,
  PhysicalKeyboardKey.digit9,
];

const List<LogicalKeyboardKey> _digitLogicalKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.digit0,
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];

/// The key press a US layout scanner emits to produce [char].
///
/// Written by hand, independently from the production translation table, so
/// that tests decoding a payload through it are real assertions rather than
/// tautologies. Covers the base64 alphabet.
UsKeystroke keystrokeFor(String char) {
  final int code = char.codeUnitAt(0);
  if (code >= 0x61 && code <= 0x7A) {
    final int index = code - 0x61; // a-z
    return UsKeystroke(_letterPhysicalKeys[index], _letterLogicalKeys[index]);
  }
  if (code >= 0x41 && code <= 0x5A) {
    final int index = code - 0x41; // A-Z
    return UsKeystroke(
      _letterPhysicalKeys[index],
      _letterLogicalKeys[index],
      shift: true,
    );
  }
  if (code >= 0x30 && code <= 0x39) {
    final int index = code - 0x30; // 0-9
    return UsKeystroke(_digitPhysicalKeys[index], _digitLogicalKeys[index]);
  }
  return switch (char) {
    '=' => const UsKeystroke(
      PhysicalKeyboardKey.equal,
      LogicalKeyboardKey.equal,
    ),
    '+' => const UsKeystroke(
      PhysicalKeyboardKey.equal,
      LogicalKeyboardKey.equal,
      shift: true,
    ),
    '/' => const UsKeystroke(
      PhysicalKeyboardKey.slash,
      LogicalKeyboardKey.slash,
    ),
    _ => throw ArgumentError.value(char, 'char', 'Not a base64 character'),
  };
}

/// The character an **Italian** keyboard layout produces for [keystroke].
///
/// Only the keys that actually move between the US and the Italian layout are
/// listed; every other key produces the same character on both.
String italianCharacterFor(UsKeystroke keystroke, String usCharacter) {
  if (keystroke.physical == PhysicalKeyboardKey.equal) {
    return keystroke.shift ? '^' : 'ì';
  }
  if (keystroke.physical == PhysicalKeyboardKey.slash) {
    return keystroke.shift ? '_' : '-';
  }
  if (keystroke.physical == PhysicalKeyboardKey.minus) {
    return keystroke.shift ? '?' : "'";
  }
  return usCharacter;
}
