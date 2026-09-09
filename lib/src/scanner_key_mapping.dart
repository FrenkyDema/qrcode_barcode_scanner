/// Strategy used to turn a raw hardware key event into a character.
///
/// A "keyboard wedge" scanner does not send text: it sends key codes, exactly
/// like a physical keyboard. Which character those key codes end up producing
/// depends on the keyboard layout configured on the device, which is why the
/// same barcode can be read differently on two devices.
enum ScannerKeyMapping {
  /// Decodes the physical key of the event through a US QWERTY layout.
  ///
  /// This is the default and the correct choice for the vast majority of
  /// scanners, which are shipped configured to emit US layout key codes. It
  /// makes the scanned value independent from the keyboard layout selected on
  /// the device, fixing the classic corruptions of `=`, `+`, `/`, `-` and `_`
  /// on Italian, German, French or Spanish layouts.
  ///
  /// When the physical key is unknown (or the event carries modifiers such as
  /// `Alt`/`AltGr`, used by some scanners to inject non‑ASCII characters) the
  /// character reported by the platform is used instead, so nothing is lost.
  usPhysicalLayout,

  /// Uses the character the platform reports for the event.
  ///
  /// This reproduces the behaviour of versions prior to 4.0.0. Pick it when the
  /// scanner is explicitly programmed with the same keyboard layout as the
  /// device, or when it emits characters that do not exist on a US layout.
  platformCharacter,
}
