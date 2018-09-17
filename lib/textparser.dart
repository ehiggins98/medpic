import 'cloud.dart';

Info parseText(String text) {
  //print('here1');
  return new Info("", refills(text), doses(text), quantity(text));
}

int refills(String text) {
  const match = "REFILLS";
  for (int length = match.length; length >= 2; length--) {
    for (int start = 0; start < match.length - length; start++) {
      String substr = match.substring(start, start+length);
      if(text.toUpperCase().contains(substr)) {
        int left = digitNear(text.toUpperCase().indexOf(substr), -1, text);
        int right = digitNear(text.toUpperCase().indexOf(substr), 1, text);
        return left == -1 ? right : left;
      }
    }
  }

  return -1;
}

int quantity(String text) {
  if(text.toUpperCase().contains("Q")) {
    int left = digitNear(text.toUpperCase().indexOf("Q"), -1, text);
    int right = digitNear(text.toUpperCase().indexOf("Q"), 1, text);
    return left == -1 ? right : left;
  }
  else if(text.toUpperCase().contains("TY")) {
    int left = digitNear(text.toUpperCase().indexOf("TY"), -1, text);
    int right = digitNear(text.toUpperCase().indexOf("TY"), 1, text);
    return left == -1 ? right : left;
  }

  return -1;
}

int doses(String text) {
  text = mapNumbers(text);
  if(text.toUpperCase().contains("DA")) {
    int number = digitNear(text.toUpperCase().indexOf("DA"), -1, text);
    bool every = containsEvery(text);
    if(every) return 1;
    return number;
  }
  else if(text.toUpperCase().contains("HOUR")) {
    String interval = intervalNear(text.toUpperCase().indexOf("HOUR"), -1, text);
    int number = digitNear(text.toUpperCase().indexOf("HOUR"), -1, text);

    if(interval.length > 0) {
      List<String> tokens = interval.split('-');
      int first = int.parse(tokens[0]);
      int second = int.parse(tokens[1]);
      return (48/(first+second)).floor();
    }
    else if(number > -1) {
      return (24 / number).floor();
    }
  }
  return -1;
}

int digitNear(int index, int increment, String text, [int interval = 10]) {
  bool spaceFound = false;
  String found = "";
  RegExp space = new RegExp(r"\s+");
  RegExp exp = new RegExp(r"\d");
  for(int i = 0; i.abs() < interval && (!spaceFound || !space.hasMatch(text[index + i])); i += increment) {
    if(index + i < 0 || index + i > text.length) return -1;
    else if(text[index+i] == '\n' || (!(new RegExp(r"\d+").hasMatch(text[index+i])) && text[index + i].toUpperCase() != "N" && text[index + i].toUpperCase() != "O" && found.length > 0)) {
      break;
    }
    else if(exp.hasMatch(text[index + i])) {
      found = increment > 0 ? found + text[index + i] : text[index + i] + found;
    }
    else if((text[index + i].toUpperCase() == "N" || text[index + i].toUpperCase() == "O") && !new RegExp(r"\d+").hasMatch(found)) {
      found = increment > 0 ? found + text[index + i] : text[index + i] + found;
    }
    else if(space.hasMatch(text[index + i])) {
      spaceFound = true;
    }
  }
  if(found.toUpperCase() == "NO") return 0;
  return found.length > 0 && new RegExp(r"\d+").hasMatch(found) ? int.parse(found) : -1;
}

String intervalNear(int index, int increment, String text, [int interval = 10]) {
  int firstDigit = digitNear(index, increment, text, interval);
  if(text.indexOf(firstDigit.toString()) < 0) return "";
  if(text[text.indexOf(firstDigit.toString()) + increment] == '-') {
    int secondDigit = digitNear(text.indexOf(firstDigit.toString()) + increment, increment, text, 2);
    return increment > 0 ? '${firstDigit}-$secondDigit' : '${secondDigit}-$firstDigit';
  }

  return "";
}

String mapNumbers(String text) {
  var map = {
    "once a": 1,
    "once": 1,
    "twice a": 2,
    "twice": 2,
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9
  };

  text = text.toUpperCase();
  map.forEach((k, v) {
    text = text.replaceAll(k.toUpperCase(), v.toString());
  });

  text = text.replaceAll(" to ", "-");
  return text;
}

bool containsEvery(String text) {
  const match = "EVERY";
  for (int length = match.length; length >= 3; length--) {
    for (int start = 0; start < match.length - length; start++) {
      String substr = match.substring(start, start+length);
      if(text.toUpperCase().contains(substr)) {
        return true;
      }
    }
  }
  return false;
}