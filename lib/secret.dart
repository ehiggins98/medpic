import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';
import 'api_keys.dart';

List<String> gifs = List<String>();
List<String> searchQueries = [
  'medicine',
  'doctor',
  'android'
];

void getGifs() async {
  Random random = new Random();
  var index = random.nextInt(searchQueries.length);
  var response = await http.get('http://api.giphy.com/v1/gifs/search?api_key=$giphy_key&q=${searchQueries[index]}');
  var data = jsonDecode(response.body);
  for(int i = 0; i < 25; i++) {
    if(data['data'][i]['type'] == 'gif')gifs.add('https://media.giphy.com/media/${data['data'][i]['id']}/giphy.gif');
  }
}

String getGifUrl() {
  Random random = new Random();
  return gifs[random.nextInt(gifs.length)];
}