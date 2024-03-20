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
    debugPrint("$value ${value.length}");
    setState(() {
      _scanValue = value;
    });
  }

  @override
  void initState() {
    super.initState();
    QrcodeBarcodeScanner(
      onScannedCallback: (String value) {
        // debugPrint("Scan value vase64: '${utf8.decode(base64.decode(value))}'");
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
                child: Text(
                  _scanValue ?? 'none',
                  style: const TextStyle(fontSize: 30),
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
