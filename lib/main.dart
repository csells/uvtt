import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'universal_vtt_file.dart';
import 'package:path/path.dart' as path;

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
  UniversalVttFile? _uvtt;
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
          child: _error == null && _uvtt != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Text(
                        _uvtt!.filename,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('format: ${_uvtt!.format}'),
                      Text(
                        'software: ${_uvtt!.software.isNotEmpty ? _uvtt!.software : 'unknown'}',
                      ),
                      Text(
                        'creator: ${_uvtt!.creator.isNotEmpty ? _uvtt!.creator : 'unknown'}',
                      ),
                      Text(
                        'image size: ${_uvtt!.parsedImage!.width} x ${_uvtt!.parsedImage!.height} (pixels)',
                      ),
                      Text(
                        'square size: ${_uvtt!.resolution.pixelsPerGrid} x ${_uvtt!.resolution.pixelsPerGrid} (pixels)',
                      ),
                      Text(
                        'map size: ${_uvtt!.resolution.mapSize.x} x ${_uvtt!.resolution.mapSize.y} (squares)',
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
                    if (_uvtt != null)
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
            if (_error == null && _uvtt != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RawImage(image: _uvtt!.parsedImage),
                  ),
                ),
              ),
          ],
        ),
      );

  Future<void> _onOpenFile() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'Universal VTT Files',
      extensions: ['dd2vtt', 'df2vtt', 'uvtt'],
    );
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    // operation was canceled by user
    if (file == null) return;

    try {
      final json = await file.readAsString();
      final uvtt = await UniversalVttFile.fromRawJsonFile(
        filename: file.name,
        rawJson: json,
      );

      setState(() {
        _error = null;
        _uvtt = uvtt;
      });
    } on Exception catch (ex) {
      setState(() {
        _error = ex.toString();
        _uvtt = null;
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
      extensions: ['png'],
    );

    final name = path.setExtension(_uvtt!.filename, '.png');
    final pathname = await getSavePath(
      acceptedTypeGroups: [typeGroup],
      suggestedName: name,
    );

    // user canceled the operation
    if (pathname == null) return;

    const mimeType = "image/png";
    final data = await _uvtt!.parsedImage!.toByteData(
      format: ImageByteFormat.png,
    );

    final file = XFile.fromData(
      data!.buffer.asUint8List(),
      name: name,
      mimeType: mimeType,
    );

    await file.saveTo(pathname);
  }
}
