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
  UniversalVttFile? _file;
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
        drawer: Drawer(
          child: _error == null && _file != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      DrawerHeader(
                        padding: const EdgeInsets.all(0),
                        child: SelectableText(_file!.filename),
                      ),
                      SelectableText('format: ${_file!.format}'),
                      SelectableText(
                        'software: ${_file!.software.isNotEmpty ? _file!.software : 'unknown'}',
                      ),
                      SelectableText(
                        'creator: ${_file!.creator.isNotEmpty ? _file!.creator : 'unknown'}',
                      ),
                      SelectableText(
                        'map size: ${_file!.resolution.mapSize.x} x ${_file!.resolution.mapSize.y} (squares)',
                      ),
                      SelectableText(
                        'square size: ${_file!.resolution.pixelsPerGrid} x ${_file!.resolution.pixelsPerGrid} (pixels)',
                      ),
                    ],
                  ),
                )
              : const DrawerHeader(
                  child: Text('no open file'),
                ),
        ),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _onOpenFile,
                      child: const Text('Open Universal VTT File'),
                    ),
                    if (_file != null)
                      OutlinedButton(
                        onPressed: _onExtractImage,
                        child: const Text('Extract Image'),
                      ),
                  ],
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
            if (_error == null && _file != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(_file!.imageBytes),
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
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    // operation was canceled by user
    if (file == null) return;

    try {
      final json = await file.readAsString();
      setState(() {
        _error = null;
        _file = UniversalVttFile.fromRawJsonFile(
          filename: file.name,
          rawJson: json,
        );

        // check the image data so we get an error now instead of later
        final bytes = _file!.imageBytes;
        // ignore: avoid_print
        print(bytes[0]); // avoid the optimizer
      });
    } on Exception catch (ex) {
      setState(() {
        _error = ex.toString();
        _file = null;
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

  Future<void> _onExtractImage() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'Image Files',
      extensions: <String>['png'],
    );
    const name = "vtt-image.png";
    final path = await getSavePath(
      acceptedTypeGroups: [typeGroup],
      suggestedName: name,
    );

    // user canceled the operation
    if (path == null) return;

    const mimeType = "image/png";
    final file = XFile.fromData(
      _file!.imageBytes,
      name: name,
      mimeType: mimeType,
    );
    await file.saveTo(path);
  }
}
