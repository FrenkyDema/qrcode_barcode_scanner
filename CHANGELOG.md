# CHANGELOG

## 4.0.0

**Scanning correctness**

- Fix scanned values being corrupted on non‑US keyboard layouts. Characters are
  now decoded from the *physical* key of the event through a US QWERTY table,
  which is what HID scanners actually emit, instead of the character the
  operating system reports. On an Italian layout this fixes `=` being read as
  `ì`, `/` as `-` and `+` as `]`, which silently broke every base64 payload.
- Add `ScannerKeyMapping` and the `keyMapping` parameter to opt back into the
  previous behaviour (`ScannerKeyMapping.platformCharacter`) for scanners that
  are programmed with the same layout as the device.
- Deliver the scan immediately when the scanner sends its `Enter`/`Tab` suffix
  instead of waiting for the idle timeout, and stop appending that suffix to the
  value. Configurable through `submitOnTerminator`.
- Only handle key *down* events, so a scanner that reports characters on key up
  can no longer duplicate them.
- Add the `scanDelay` and `ignoreWhenTextInputFocused` parameters, and a public
  `flush()` to deliver a partial scan on demand.
- `dispose()` is now idempotent and cancels the pending scan.

**Migration to the current Flutter toolchain**

- Require Dart `^3.8.0` / Flutter `>=3.32.0`.
- Android: `compileSdk` 36, `minSdk` 24, Java 17, AGP 8.11.1, unconditional
  `namespace`, `dependencies` moved out of the `android` block.
- Example app: Gradle 8.14.3, AGP 8.11.1, Kotlin 2.2.20, `flutter.*` SDK
  versions, `rootProject.layout.buildDirectory` instead of the removed
  `buildDir`.
- CI now builds against a current Flutter and runs the test suite.

**Breaking changes**

- The Android package moved from `com.example.qrcode_barcode_scanner` to
  `com.francescodema.dev.qrcode_barcode_scanner`. The pub.dev package name is
  unchanged, and the Flutter tool regenerates `GeneratedPluginRegistrant.java`
  automatically, so no action is needed unless you referenced the plugin class
  by its fully qualified Java name (manual registration in an add-to-app host,
  or a ProGuard/R8 keep rule).
- `DelayedActionHandler` moved to `lib/src/`; it is an internal utility and is
  no longer importable from `package:qrcode_barcode_scanner/delayed_action_handler.dart`.
- Values are decoded through the US layout by default. If your scanner is
  programmed for a non‑US layout, pass
  `keyMapping: ScannerKeyMapping.platformCharacter`.

## 3.0.3

Refactoring doc

## 3.0.2

Fix focus loss when text field is present
dart format

## 3.0.1

Fix handle space in scanned value
dart format

## 3.0.0

Update gradle infrastructure
Update Scanning method
Refactoring

## 2.0.1

dart format

## 2.0.0

Rewrite project

## 1.1.0

Bugfix

## 1.0.1

Update License

## 1.0.0

Renomination of the repository and refactoring

## 0.1.0

Refactoring, add better documentation

## 0.0.2

Refactoring, add better documentation

## 0.0.1

Implementation of basic functions, listener and callback management.
