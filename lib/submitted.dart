import 'package:flutter/material.dart';

class Submitted extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("android/app/src/main/res/drawable/success.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
