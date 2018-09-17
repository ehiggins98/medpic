import 'package:flutter/material.dart';
import 'camera.dart';
import 'package:camera/camera.dart';
import 'google-calendar.dart';

List<CameraDescription> cameras;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("android/app/src/main/res/drawable/home.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: new Padding(
        padding: new EdgeInsets.fromLTRB(80.0, 400.0, 80.0, 80.0),
        child: Column(
          children: <Widget>[
            new MaterialButton(
              height: 40.0,
              minWidth: 70.0,
              child: const Text('Take a picture'),
              color: Colors.white70,
              elevation: 4.0,
              splashColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  new PageRouteBuilder(
                    pageBuilder: (_, __, ___) => new CameraWidget(cameras),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                    new FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
            ),
            new RaisedButton(
              child: const Text('Sign in'),
              color: Colors.white70,
              elevation: 4.0,
              splashColor: Colors.white,
              onPressed: () async {
                await signInWithGoogle();
              },
            ),
          ]
        ),
      ),
    );
  }
}