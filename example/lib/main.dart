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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.deepPurple),
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
  late QrcodeBarcodeScanner _scanner;

  @override
  void initState() {
    super.initState();
    // Initialize the scanner and set the callback for handling scanned values
    _scanner = QrcodeBarcodeScanner(
      onScannedCallback: (String value) {
        setState(() {
          _scannedValue = value;
        });
      },
    );
  }

  @override
  void dispose() {
    // Dispose the scanner when the widget is removed from the tree
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR & Barcode Scanner Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Scanned value:",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _scannedValue ?? 'none',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Focus here to disable scanner',
                          hintText: 'Tap to focus',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _scannedValue = null; // Clear the scanned value
                });
              },
              child: const Text("Clear scanned value"),
            ),
          ],
        ),
      ),
    );
  }
}
