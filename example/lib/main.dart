import 'package:flutter/material.dart';
import 'package:flutter_barcode_keyboard_listener/flutter_barcode_keyboard_listener.dart';

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

  @override
  void initState() {
    super.initState();
    BarcodeListener(
      onBarcodeScannedCallback: (String value) => setState(
        () {
          _scanValue = value;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Scan value: ${_scanValue ?? "none"}'),
        ),
      ),
    );
  }
}
