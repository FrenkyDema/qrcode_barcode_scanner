# QRCode & Barcode Scanner

[![pub package](https://img.shields.io/pub/v/qrcode_barcode_scanner.svg)](https://pub.dev/packages/qrcode_barcode_scanner)
[![Build Status](https://img.shields.io/github/actions/workflow/status/FrenkyDema/qrcode_barcode_scanner/flutter.yml)](https://github.com/FrenkyDema/qrcode_barcode_scanner/actions/workflows/flutter.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

### Overview

The **QRCode & Barcode Scanner** plugin is designed to manage QR and Barcode scanning from external
devices, offering a streamlined API for integration in Android applications.

> **Important:** This package currently supports **Android** only.

### Features

- **Simple Integration**: Use the `QrcodeBarcodeScanner` class to easily handle scan events.
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

Here is a simple example of how to use the `QrcodeBarcodeScanner`:

```dart
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';

class MyScannerApp extends StatefulWidget {
  @override
  _MyScannerAppState createState() => _MyScannerAppState();
}

class _MyScannerAppState extends State<MyScannerApp> {
  String? _scanValue;

  @override
  void initState() {
    super.initState();
    QrcodeBarcodeScanner(
      onScannedCallback: (String value) {
        setState(() {
          _scanValue = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR & Barcode Scanner")),
      body: Center(
        child: Text(_scanValue ?? "Waiting for scan..."),
      ),
    );
  }
}
```

### API Documentation

#### Class: `QrcodeBarcodeScanner`

The `QrcodeBarcodeScanner` class is the core component of this plugin. It allows you to configure
and manage barcode and QR code scanning events.

**Constructor:**

```dart
QrcodeBarcodeScanner({
  required ScannedCallback onScannedCallback,
});
```

**Properties:**

- `onScannedCallback`: A callback function that is triggered when a scan is successful. Receives the
  scanned value as a string.

### Tested Devices

This plugin has been tested with the following devices:

- Sunmi Blink

### Additional Resources

For more detailed documentation and advanced use cases, check out
the [Wiki](https://github.com/FrenkyDema/qrcode_barcode_scanner/wiki).

### Changelog

Check out the [Changelog](CHANGELOG.md) for details on recent updates.

### Contributing

Want to contribute? Check out the [Contribution Guide](.github/CONTRIBUTING.md) to get started!

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.