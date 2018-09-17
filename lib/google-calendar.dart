import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn(scopes: [
  "https://www.googleapis.com/auth/calendar"
]);

Future<FirebaseUser> signInWithGoogle() async {
  // Attempt to get the currently authenticated user
  GoogleSignInAccount currentUser = _googleSignIn.currentUser;
  if (currentUser == null) {
    // Attempt to sign in without user interaction
    currentUser = await _googleSignIn.signInSilently();
  }
  if (currentUser == null) {
    // Force the user to interactively sign in
    currentUser = await _googleSignIn.signIn();
  }

  final GoogleSignInAuthentication auth = await currentUser.authentication;

  // Authenticate with firebase
  final FirebaseUser user = await _auth.signInWithGoogle(
    idToken: auth.idToken,
    accessToken: auth.accessToken,
  );

  assert(user != null);
  assert(!user.isAnonymous);

  return user;
}

Future<Null> signOutWithGoogle() async {
  // Sign out with firebase
  await _auth.signOut();
  // Sign out with google
  await _googleSignIn.signOut();
}

void createEvent(String date, String title) async {
  if(_googleSignIn.currentUser != null) {
    var body =
    {
      'start': {
        'date': date
      },
      'end': {
        'date': date
      },
      'summary': title
    };
    var bodyString = json.encode(body).replaceAll('"', "'");
    print(bodyString);
    var headers = await _googleSignIn.currentUser.authHeaders;
    headers["Content-Type"] = "application/json";
    var response = await http.post("https://www.googleapis.com/calendar/v3/calendars/primary/events", headers: headers, body: bodyString);
    print(response.body);
  }
}