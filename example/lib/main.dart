import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR & Barcode Scanner',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ScannerDemo(),
    );
  }
}

class ScannerDemo extends StatefulWidget {
  const ScannerDemo({super.key});

  @override
  State<ScannerDemo> createState() => _ScannerDemoState();
}

class _ScannerDemoState extends State<ScannerDemo> {
  String? _scannedValue;
  ScannerKeyMapping _keyMapping = ScannerKeyMapping.usPhysicalLayout;
  late QrcodeBarcodeScanner _scanner;

  @override
  void initState() {
    super.initState();
    _scanner = _createScanner();
  }

  QrcodeBarcodeScanner _createScanner() {
    return QrcodeBarcodeScanner(
      keyMapping: _keyMapping,
      onScannedCallback: (String value) {
        setState(() => _scannedValue = value);
      },
    );
  }

  /// Recreates the scanner so the demo can be switched between the layout
  /// independent decoding and the raw characters reported by the platform.
  void _setKeyMapping(ScannerKeyMapping mapping) {
    setState(() {
      _scanner.dispose();
      _keyMapping = mapping;
      _scanner = _createScanner();
    });
  }

  @override
  void dispose() {
    // Dispose the scanner when the widget is removed from the tree
    _scanner.dispose();
    super.dispose();
  }

  /// Decodes [value] as base64 text, or returns `null` when it is not base64.
  String? _base64Preview(String value) {
    try {
      return utf8.decode(base64.decode(value));
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? value = _scannedValue;
    final String? preview = value == null ? null : _base64Preview(value);

    return Scaffold(
      appBar: AppBar(title: const Text('QR & Barcode Scanner Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SegmentedButton<ScannerKeyMapping>(
            segments: const <ButtonSegment<ScannerKeyMapping>>[
              ButtonSegment<ScannerKeyMapping>(
                value: ScannerKeyMapping.usPhysicalLayout,
                label: Text('US layout'),
                icon: Icon(Icons.keyboard),
              ),
              ButtonSegment<ScannerKeyMapping>(
                value: ScannerKeyMapping.platformCharacter,
                label: Text('OS character'),
                icon: Icon(Icons.language),
              ),
            ],
            selected: <ScannerKeyMapping>{_keyMapping},
            onSelectionChanged: (Set<ScannerKeyMapping> selection) =>
                _setKeyMapping(selection.first),
          ),
          const SizedBox(height: 8),
          Text(
            'Switch to "OS character" to see how a non-US keyboard layout '
            'corrupts characters such as = + / on the device.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Text('Scanned value', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                value ?? 'Waiting for a scan…',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
          if (value != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '${value.length} characters',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (preview != null) ...<Widget>[
            const SizedBox(height: 16),
            Text('Decoded as base64', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  preview,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Focus here to disable the scanner',
              hintText: 'Tap to focus',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => setState(() => _scannedValue = null),
            child: const Text('Clear scanned value'),
          ),
        ],
      ),
    );
  }
}
