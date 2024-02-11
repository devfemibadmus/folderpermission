import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPermissionGranted = false;
  List<String> _files = [];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool isGranted = await FolderPicker.isPermissionGranted();
    setState(() {
      _isPermissionGranted = isGranted;
    });
    if (_isPermissionGranted) {
      _fetchFiles();
    }
  }

  Future<void> _requestPermission() async {
    await FolderPicker.requestPermission();
    _checkPermission();
  }

  Future<void> _fetchFiles() async {
    List<String> files = await FolderPicker.fetchFilesFromDirectory();
    setState(() {
      _files = files;
    });
  }
/*
  String convertContentUriToFilePath(String contentUri) {
    String prefix = "primary:";
    String newPathPrefix = "/storage/emulated/0/";

    String newPath = contentUri.replaceAll("%2F", "/");
    newPath = newPath.replaceAll("%3A", ":");
    newPath = newPath.replaceAll("%2E", ".");
    //newPath = newPath.replaceAll(prefix, "");
    newPath = newPath.substring(newPath.indexOf('document/') + 9);
    //newPath = newPath.substring(newPath.indexOf(':') + 1);
    newPath = newPath.replaceAll(prefix, newPathPrefix);
    return newPath;
  }

*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Downloader'),
      ),
      body: Center(
        child: _isPermissionGranted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Permission Granted'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchFiles,
                    child: const Text('Fetch Files'),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        return _files[index].endsWith(".jpg")
                            ? Image.file(File(_files[
                                index])) //try convertContentUriToFilePath(_files[index])
                            : ListTile(
                                title: Text(_files[index]),
                              );
                      },
                    ),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Request Permission'),
              ),
      ),
    );
  }
}

class FolderPicker {
  static const MethodChannel _channel =
      MethodChannel('com.blackstackhub.folderpicker');

  static Future<bool> isPermissionGranted() async {
    try {
      final bool result = await _channel.invokeMethod('isPermissionGranted');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check permission: '${e.message}'.");
      return false;
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestSpecificFolderAccess');
    } on PlatformException catch (e) {
      print("Failed to request permission: '${e.message}'.");
    }
  }

  static Future<List<String>> fetchFilesFromDirectory() async {
    try {
      final List<dynamic> result =
          await _channel.invokeMethod('fetchFilesFromDirectory');
      print(result);
      print(result.length);
      return result.cast<String>();
    } on PlatformException catch (e) {
      print("Failed to fetch files: '${e.message}'.");
      return [];
    }
  }
}
