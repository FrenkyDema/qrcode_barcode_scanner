// Basic smoke test for the example application.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:qrcode_barcode_scanner_example/main.dart';

void main() {
  testWidgets('shows the placeholder until something is scanned', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Waiting for a scan…'), findsOneWidget);
    expect(find.text('US layout'), findsOneWidget);
  });
}
