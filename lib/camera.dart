import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:hackmit_2018/verification.dart';
import 'dart:convert';

class CameraWidget extends StatefulWidget {
  List<CameraDescription> availableCameras;

  CameraWidget(List<CameraDescription> cameras) {
    availableCameras = cameras;
  }

  @override
  State<StatefulWidget> createState() {
    return new _CameraWidgetState(availableCameras);
  }
}

class _CameraWidgetState extends State<CameraWidget> {
  List<CameraDescription> cameras;
  CameraController controller;

  _CameraWidgetState(List<CameraDescription> cameras) {
    this.cameras = cameras;
  }

  @override
  void initState() {
    super.initState();
    controller = new CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if(!mounted) return;
      setState(() {});
    });
  }

  Future<String> _takePicture() async {
    var filePath = await getFilePath();
    await controller.takePicture(filePath);
    var image = new File(filePath).readAsBytesSync();
    Base64Codec BASE64 = const Base64Codec();
    print(image.length);
    return BASE64.encode(image);
  }

  @override
  Widget build(BuildContext context) {
    if(!controller.value.isInitialized) return new Container();
    return new Scaffold(
      body: new CameraPreview(controller),
      floatingActionButton: new Padding(
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 135.0, 0.0),
        child: new FloatingActionButton(
          onPressed: () async {
            String encodedImage = await _takePicture();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VerificationWidget(encodedImage)),
            );
          },
          tooltip: 'Take picture',
          backgroundColor: Colors.white70,
        ),
      ),
    );
  }

  Future<String> getFilePath() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
    print(filePath);
    return filePath;
  }
}

