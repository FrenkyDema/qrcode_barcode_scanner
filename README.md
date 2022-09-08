# flutter_barcode_keyboard_listener

Plugin for managing QR and BAR code reading from an external device.

## Important

**THIS PACKAGE WILL WORK ONLY IN ANDROID!**

---

## Class Name

```dart
BarcodeListener
```

## Variables

```dart
BarcodeScannedCallback onBarcodeScannedCallback //<- Function(String barcode)
Duration bufferDuration
bool useKeyDownEvent
```

## Example

```dart
@override
void initState() {
    BarcodeListener(
        onBarcodeScannedCallback:
            (String value) => setState(() {
                print(value);
            },
        ),
    );
}
```

## Installation

```bash
flutter pub add flutter_barcode_keyboard_listener
```

## Tested Devices

```bash
Sunmi Blink
```
