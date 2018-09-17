import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'textparser.dart';
import 'api_keys.dart';

class Vision {
  static Future<Info> fetchText(String encodedImage) async {
    var body = '''
      {
        "requests": [
          {
            "image": {
              "content": "$encodedImage"
            },
            "features": [
              {
                "type": "TEXT_DETECTION"
              }
            ]
          }
        ]
      }
''';
    var response = await http.post(
      "https://vision.googleapis.com/v1/images:annotate?key=$google_vision_key",
      body: body
    );

    try {
      var data = jsonDecode(response.body);
      String text = data['responses'][0]['textAnnotations'][0]['description'];
      return parseText(text);
    } catch(NoSuchMethodError) {
      print(response.body);
      return null;
    }
  }
}

class Info {
  String name;
  int refillsRemaining;
  int dosesDaily;
  int pills;

  Info(String name, int refillsRemaining, int dosesDaily, int pills) {
    this.name = name;
    this.refillsRemaining = refillsRemaining;
    this.dosesDaily = dosesDaily;
    this.pills = pills;
  }

  void setName(String name) {
    this.name = name;
  }

  void setRefills(int refills) {
    this.refillsRemaining = refills;
  }

  void setDoses(int doses) {
    this.dosesDaily = doses;
  }

  void setPills(int pills) {
    this.pills = pills;
  }
}
