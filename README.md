# qrcode_barcode_scanner

Plugin for managing QR and BAR code reading from an external device.

## Important

**THIS PACKAGE WILL WORK ONLY IN ANDROID!**

---

## Class Name

```dart
QrcodeBarcodeScanner
```

## Variables

```dart
ScannedCallback onScannedCallback;   //void Function(String scannedCode);
```

## Example

```dart
String? _scanValue;

@override
  void initState() {
    super.initState();
    QrcodeBarcodeScanner(
      onScannedCallback: (String value) => setState(
        () {
          _scanValue = value;
        },
      ),
    );
  }
```

## Installation

```bash
flutter pub add qrcode_barcode_scanner
```

## Tested Devices

- Sunmi Blink
