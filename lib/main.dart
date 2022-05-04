// from: https://arkenforge.com/universal-vtt-files/
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'universal_vtt_file.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  static const title = 'Universal VTT File Reader';

  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: title,
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _image;
  String? _error;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(App.title),
          actions: [
            IconButton(
              onPressed: _onGitHub,
              icon: Image.asset(
                'assets/github_icon.webp',
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _onAbout,
              icon: const Icon(Icons.info),
            ),
          ],
        ),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: _onOpenFile,
                  child: const Text('Open Universal VTT File'),
                ),
              ),
            ),
            if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_error == null && _image != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(_image!),
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

    try {
      final XFile file = files[0];
      final json = await file.readAsString();
      final uvtt = UniversalVttFile.fromRawJson(json);
      setState(() {
        _error = null;
        _image = base64Decode(uvtt.image);
      });
    } on Exception catch (ex) {
      setState(() {
        _error = ex.toString();
        _image = null;
      });
    }
  }

  Future<void> _onGitHub() async {
    await launchUrl(Uri.parse('https://github.com/csells/uvtt'));
  }

  Future<void> _onAbout() async {
    final packageInfo = await PackageInfo.fromPlatform();
    showAboutDialog(
      context: context,
      applicationName: 'Universal VTT File Reader',
      applicationVersion: 'v${packageInfo.version}',
      applicationLegalese: 'Copyright © 2022, Sells Brothers, Inc.',
    );
  }
}
