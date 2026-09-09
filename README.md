# QRCode & Barcode Scanner

[![pub package](https://img.shields.io/pub/v/qrcode_barcode_scanner.svg)](https://pub.dev/packages/qrcode_barcode_scanner)
[![Build Status](https://img.shields.io/github/actions/workflow/status/FrenkyDema/qrcode_barcode_scanner/flutter.yml)](https://github.com/FrenkyDema/qrcode_barcode_scanner/actions/workflows/flutter.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

### Overview

The **QRCode & Barcode Scanner** plugin manages QR and Barcode scanning from external "keyboard
wedge" devices, offering a streamlined API for integration in Android applications.

> **Important:** This package currently supports **Android** only.

### Features

- **Simple Integration**: Use the `QrcodeBarcodeScanner` class to easily handle scan events.
- **Layout independent**: Scanned values are decoded from the physical keys the scanner emits, so
  they are not corrupted by the keyboard layout configured on the device.
- **Customizable Callbacks**: Register custom callback functions to handle scanned data in
  real-time.
- **Android Only**: This plugin is developed with Android compatibility in mind.
- **Tested Devices**: Supports external scanning devices such as Sunmi Blink.

### Installation

Add the following dependency in your `pubspec.yaml` file:

```bash
flutter pub add qrcode_barcode_scanner
```

### Usage Example

```dart
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';

class MyScannerApp extends StatefulWidget {
  const MyScannerApp({super.key});

  @override
  State<MyScannerApp> createState() => _MyScannerAppState();
}

class _MyScannerAppState extends State<MyScannerApp> {
  String? _scanValue;
  late final QrcodeBarcodeScanner _scanner;

  @override
  void initState() {
    super.initState();
    _scanner = QrcodeBarcodeScanner(
      onScannedCallback: (String value) {
        setState(() => _scanValue = value);
      },
    );
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR & Barcode Scanner")),
      body: Center(child: Text(_scanValue ?? "Waiting for scan...")),
    );
  }
}
```

### Keyboard layouts

A keyboard wedge scanner does not send text: it sends **key codes**, exactly like a physical
keyboard. Virtually all of them are shipped configured for a **US layout**, while the device
translates those key codes with the layout the user has selected. The two disagree on every key
whose position differs, so the value silently changes:

| Scanner sends | Read on an Italian layout | Read on a German layout |
|---------------|---------------------------|-------------------------|
| `=`           | `ì`                       | `´`                     |
| `+`           | `]`                       | `*`                     |
| `/`           | `-`                       | `-`                     |
| `_`           | `?`                       | `?`                     |

This breaks base64 payloads in particular, where `+`, `/` and the `=` padding are part of the
alphabet — a QR code ending in `In0=` is read as `In0ì`.

Since 4.0.0 the plugin decodes the **physical** key of each event through a US QWERTY table, so the
scanned value is the same whatever layout the device uses. If your scanner is instead programmed
with the same layout as the device, opt out:

```dart
QrcodeBarcodeScanner(
  keyMapping: ScannerKeyMapping.platformCharacter,
  onScannedCallback: (String value) { /* ... */ },
);
```

### API Documentation

#### Class: `QrcodeBarcodeScanner`

**Constructor:**

```dart
QrcodeBarcodeScanner({
  required ScannedCallback onScannedCallback,
  ScannerKeyMapping keyMapping = ScannerKeyMapping.usPhysicalLayout,
  Duration scanDelay = const Duration(milliseconds: 100),
  bool submitOnTerminator = true,
  bool ignoreWhenTextInputFocused = true,
});
```

**Parameters:**

| Parameter                    | Default             | Description                                                                                                  |
|------------------------------|---------------------|--------------------------------------------------------------------------------------------------------------|
| `onScannedCallback`          | —                   | Called with the scanned value once the scan is complete.                                                       |
| `keyMapping`                 | `usPhysicalLayout`  | How key events are turned into characters. See [Keyboard layouts](#keyboard-layouts).                          |
| `scanDelay`                  | `100 ms`            | Idle time after the last key event before the scan is delivered.                                               |
| `submitOnTerminator`         | `true`              | Deliver the scan as soon as the scanner sends its `Enter`/`Tab` suffix, without waiting for `scanDelay`.        |
| `ignoreWhenTextInputFocused` | `true`              | Ignore key events while a text field owns the focus, so the scanner does not steal its input.                   |

**Methods:**

- `flush()`: delivers the scan in progress immediately.
- `cancelScan()`: discards the scan in progress.
- `dispose()`: releases the keyboard listener. Always call it when the scanner is no longer needed.

### Tested Devices

This plugin has been tested with the following devices:

- Sunmi Blink

### Requirements

- Dart `^3.8.0`, Flutter `>=3.32.0`
- Android `minSdk` 24, `compileSdk` 36

### Additional Resources

For more detailed documentation and advanced use cases, check out
the [Wiki](https://github.com/FrenkyDema/qrcode_barcode_scanner/wiki).

### Changelog

Check out the [Changelog](CHANGELOG.md) for details on recent updates.

### Contributing

Want to contribute? Check out the [Contribution Guide](.github/CONTRIBUTING.md) to get started!

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
