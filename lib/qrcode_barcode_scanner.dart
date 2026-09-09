import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner_platform_interface.dart';

import 'src/delayed_action_handler.dart';
import 'src/scanner_key_mapping.dart';
import 'src/us_keyboard_layout.dart';

export 'src/scanner_key_mapping.dart';
export 'src/us_keyboard_layout.dart';

/// A callback function type to handle scanned barcodes.
///
/// [scannedCode] is the string representing the scanned barcode.
typedef ScannedCallback = void Function(String scannedCode);

/// Duration representing 100 milliseconds.
const Duration hundredMs = Duration(milliseconds: 100);

/// A class responsible for scanning QR codes and barcodes.
///
/// The [QrcodeBarcodeScanner] class listens to the hardware keyboard events
/// emitted by an external "keyboard wedge" scanner, rebuilds the scanned string
/// from them, and hands it over to [onScannedCallback].
///
/// Characters are decoded from the *physical* key of each event through a US
/// QWERTY layout (see [ScannerKeyMapping.usPhysicalLayout]), because that is
/// what scanners emit. Relying on the character the operating system reports
/// instead corrupts every key whose position differs between the US layout and
/// the layout selected on the device — on an Italian layout, for instance, the
/// `=` of a base64 payload is reported as `ì`, `/` as `-` and `+` as `]`.
class QrcodeBarcodeScanner {
  /// The callback function to handle scanned barcodes.
  final ScannedCallback onScannedCallback;

  /// How raw key events are translated into characters.
  ///
  /// Defaults to [ScannerKeyMapping.usPhysicalLayout], which keeps the scanned
  /// value independent from the keyboard layout of the device.
  final ScannerKeyMapping keyMapping;

  /// Whether `Enter` and `Tab` end the current scan immediately.
  ///
  /// Most scanners are configured to append such a suffix after the payload.
  /// Honouring it delivers the value as soon as it is complete instead of
  /// waiting for [scanDelay] to elapse. Defaults to `true`.
  final bool submitOnTerminator;

  /// Whether key events are ignored while a text field owns the focus.
  ///
  /// Keeps the scanner from stealing the input of a focused [EditableText].
  /// Defaults to `true`.
  final bool ignoreWhenTextInputFocused;

  /// The idle time after the last key event before the scan is delivered.
  final Duration scanDelay;

  /// The keys a scanner may send to mark the end of a scan.
  static final Set<PhysicalKeyboardKey> _terminatorKeys = <PhysicalKeyboardKey>{
    PhysicalKeyboardKey.enter,
    PhysicalKeyboardKey.numpadEnter,
    PhysicalKeyboardKey.tab,
  };

  /// The characters read so far for the scan in progress.
  final List<String> _pressedKeys = <String>[];

  /// A delayed action handler used to detect the end of a scan.
  final DelayedActionHandler _actionHandler;

  bool _disposed = false;

  /// Creates a new instance of [QrcodeBarcodeScanner].
  ///
  /// The [onScannedCallback] parameter is a required callback function that
  /// handles scanned barcodes.
  QrcodeBarcodeScanner({
    required this.onScannedCallback,
    this.keyMapping = ScannerKeyMapping.usPhysicalLayout,
    this.scanDelay = hundredMs,
    this.submitOnTerminator = true,
    this.ignoreWhenTextInputFocused = true,
  }) : _actionHandler = DelayedActionHandler(scanDelay) {
    HardwareKeyboard.instance.addHandler(_keyBoardCallback);
  }

  /// Retrieves the platform version from the native platform.
  Future<String?> getPlatformVersion() {
    return QrcodeBarcodeScannerPlatform.instance.getPlatformVersion();
  }

  /// Handles a keyboard event by adding the read character to the buffer.
  ///
  /// [readChar] is the character read from the keyboard. If [readChar] is not
  /// null, it is appended to the scan in progress and the idle timer is
  /// restarted; once [scanDelay] elapses without further input the buffer is
  /// delivered to [onScannedCallback].
  void onKeyEvent(String? readChar) {
    if (readChar == null || _disposed) {
      return;
    }
    _pressedKeys.add(readChar);
    _actionHandler.executeDelayed(flush);
  }

  /// Delivers the scan in progress, if any, to [onScannedCallback].
  ///
  /// Called automatically when [scanDelay] elapses or when a terminator key is
  /// received; can also be called manually to force the delivery of a partial
  /// scan.
  void flush() {
    _actionHandler.cancelDelayed();
    if (_pressedKeys.isEmpty) {
      return;
    }
    final String scannedCode = _pressedKeys.join();
    _pressedKeys.clear();
    onScannedCallback(scannedCode.trim());
  }

  /// Cancels the currently scheduled scan action, if any.
  ///
  /// This method can be used to cancel any pending scan action, preventing the
  /// callback from being triggered.
  void cancelScan() {
    _actionHandler.cancelDelayed();
    _pressedKeys.clear();
  }

  /// The callback function that is called when a keyboard event occurs.
  ///
  /// [event] is the hardware key event that occurred. Returns `true` when the
  /// event was consumed as part of a scan.
  bool _keyBoardCallback(KeyEvent event) {
    // Only key presses carry a character; handling up events too would double
    // every character of the scanned value.
    if (event is! KeyDownEvent) {
      return false;
    }

    if (ignoreWhenTextInputFocused && _isTextInputFocused()) {
      return false; // Bypass scanner logic when text input is focused
    }

    if (submitOnTerminator && _terminatorKeys.contains(event.physicalKey)) {
      if (_pressedKeys.isEmpty) {
        return false; // Let a plain Enter/Tab through when no scan is running.
      }
      flush();
      return true;
    }

    final String? character = _characterOf(event);
    if (!_isValidCharacter(character)) {
      return false;
    }

    onKeyEvent(character);
    return true;
  }

  /// Resolves the character carried by [event] according to [keyMapping].
  String? _characterOf(KeyEvent event) {
    if (keyMapping == ScannerKeyMapping.platformCharacter) {
      return event.character;
    }

    final HardwareKeyboard keyboard = HardwareKeyboard.instance;
    // Alt/AltGr, Control and Meta combinations are used by some scanners to
    // inject characters that do not exist on a US layout; the platform is the
    // only one able to resolve those, so defer to it.
    if (keyboard.isAltPressed ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed) {
      return event.character;
    }

    return UsKeyboardLayout.characterFor(
          event.physicalKey,
          isShiftPressed: keyboard.isShiftPressed,
          isCapsLockOn: keyboard.lockModesEnabled.contains(
            KeyboardLockMode.capsLock,
          ),
          isNumLockOn: keyboard.lockModesEnabled.contains(
            KeyboardLockMode.numLock,
          ),
        ) ??
        event.character;
  }

  /// Checks if the character is valid for scanning (non-null and non-empty).
  bool _isValidCharacter(String? character) {
    return character != null &&
        character.isNotEmpty &&
        character.codeUnits.any((unit) => unit != 0);
  }

  /// Checks if a text input field is currently focused.
  bool _isTextInputFocused() {
    final FocusNode? focus = FocusManager.instance.primaryFocus;
    if (focus != null) {
      return focus.context?.findAncestorWidgetOfExactType<EditableText>() !=
          null;
    }
    return false;
  }

  /// Disposes the resources used by the `QrcodeBarcodeScanner`.
  ///
  /// Call this method when the `QrcodeBarcodeScanner` is no longer needed to
  /// release any resources (such as keyboard listeners) it may have acquired.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    // Remove keyboard listener
    HardwareKeyboard.instance.removeHandler(_keyBoardCallback);
    _actionHandler.cancelDelayed();
    _pressedKeys.clear();
  }
}
