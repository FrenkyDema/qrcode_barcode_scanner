import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Keyboard Language Test',
      home: KeyboardLanguageTest(),
    );
  }
}

class KeyboardLanguageTest extends StatefulWidget {
  const KeyboardLanguageTest({Key? key}) : super(key: key);

  @override
  _KeyboardLanguageTestState createState() => _KeyboardLanguageTestState();
}

class _KeyboardLanguageTestState extends State<KeyboardLanguageTest> {
  final TextEditingController _textController = TextEditingController();
  bool isKeyboardVisible = false;
  String? keyboardLanguage;

  @override
  void initState() {
    super.initState();
    final KeyboardVisibilityController keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  Future<void> checkKeyboardLanguage() async {
    final String? language =
    await SystemChannels.textInput.invokeMethod<String>('TextInput.getKeyboardLayout');
    setState(() {
      keyboardLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Language Test'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Is keyboard visible? $isKeyboardVisible'),
          Text('Keyboard language: $keyboardLanguage'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: checkKeyboardLanguage,
            child: const Text('Check Keyboard Language'),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type something...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
