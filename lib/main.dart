import 'package:flutter/material.dart';
import 'camera.dart';
import 'package:camera/camera.dart';
import 'package:hackmit_2018/home.dart';
import 'dart:async';
import 'textparser.dart';

void main() async {
  cameras = await availableCameras();
  runApp(new HackMIT());
}

class HackMIT extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'medpic',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Home(),
    );
  }
}
