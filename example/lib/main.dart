import 'package:flutter/material.dart';
import 'package:qrcode_barcode_scanner/qrcode_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _scanValue;

  void setScannedValue(String value) {
    setState(() {
      _scanValue = value;
    });
  }

  @override
  void initState() {
    super.initState();
    QrcodeBarcodeScanner(
      onScannedCallback: (String value) {
        setScannedValue(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Scan value: ${_scanValue ?? 'none'}",
                      style: const TextStyle(fontSize: 30),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _scanValue = null;
                });
              },
              child: const Text("Clear scanned"),
            )
          ],
        ),
      ),
    );
  }
}
