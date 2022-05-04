// from: https://arkenforge.com/universal-vtt-files/
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'universal_vtt_file.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  static const title = 'Universal VTT File Reader';

  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: title,
        home: HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _image;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Column(
          children: [
            if (_image != null) Center(child: Image.memory(_image!)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: _onOpenFile,
                  child: const Text('Open Universal VTT File'),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _onOpenFile() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'Universal VTT Files',
      extensions: <String>['dd2vtt', 'df2vtt', 'uvtt'],
    );

    final List<XFile> files =
        await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    // Operation was canceled by the user.
    if (files.isEmpty) return;

    final XFile file = files[0];
    final json = await file.readAsString();
    final uvtt = UniversalVttFile.fromRawJson(json);
    setState(() {
      _image = base64Decode(uvtt.image);
    });
  }
}
