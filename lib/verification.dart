import 'package:flutter/material.dart';
import 'package:onesignal/onesignal.dart';
import 'cloud.dart';
import 'dart:async';
import 'package:hackmit_2018/congrats.dart';
import 'package:hackmit_2018/submitted.dart';
import 'secret.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'google-calendar.dart';

class VerificationWidget extends StatefulWidget {

  Future<Info> infoFuture;

  VerificationWidget(String encodedImage) {
    infoFuture = Vision.fetchText(encodedImage);
    getGifs();
  }

  @override
  State<VerificationWidget> createState() {
    return new _VerificationWidgetState(infoFuture);
  }
}

class _VerificationWidgetState extends State<VerificationWidget> {

  Future<Info> infoFuture;
  String overallName;
  Info info;
  final _formKey = GlobalKey<FormState>();

  _VerificationWidgetState(Future<Info> infoFuture) {
    this.infoFuture = infoFuture;
  }

  Widget processReminders(Info info) {
    List<Widget> result = new List<Container>();
    List<Reminder> reminders = new List<Reminder>();
    List<DateTime> times = new List<DateTime>();

    if(info.dosesDaily == 1 || info.dosesDaily == 3) {
      times.add(new DateTime(2018, 1, 1, 12, 0));
    }
    if(info.dosesDaily == 2 || info.dosesDaily == 3) {
      times.add(new DateTime(2018, 1, 1, 8, 0));
      times.add(new DateTime(2018, 1, 1, 18, 0));
    }
    else if(info.dosesDaily > 3) {
      double interval = 12 / info.dosesDaily;
      for(double time = 8.0; time <= 20.0; time+=interval) {
        times.add(new DateTime(2018, 1, 1, time.floor(), ((time - time.floor()) * 60).floor()));
      }
    }

    for(String day in ['M', 'T', 'W', 'Th', 'F', 'Sa', 'S']) {
      for(DateTime time in times) {
        reminders.add(new Reminder(day, time));
      }
    }

    reminders.forEach((r) {
      result.add(
        new Container(
            width: 200.0,
            decoration: new BoxDecoration(border: Border.all()),
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
            padding: EdgeInsets.all(5.0),
            child: new Row(
              children: <Widget>[
                Container(
                    width: 40.0,
                    child: TextFormField(
                      initialValue: r.day,
                      decoration: InputDecoration(labelText: "Time"),
                      validator: (text) {
                        RegExp exp = new RegExp(r"M|T|W|Th|F|Sa|S");
                        if(!exp.hasMatch(text.toUpperCase())) return 'Day must be one of M, T, W, Th, F, Sa, or S.';
                      },
                    )
                ),
                Container(
                    width: 75.0,
                    margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0.0),
                    child: TextFormField(
                      initialValue: parseTime(r.time.hour, r.time.minute),
                      decoration: InputDecoration(labelText: "Time"),
                      validator: (text) {
                        RegExp exp = new RegExp(r"\d{1,2}:\d{2} (AM|PM)");
                        if(exp.hasMatch(text)) {
                          if(int.parse(text.substring(0, text.indexOf(":"))) <= 0 || int.parse(text.substring(0, text.indexOf(":"))) > 12) {
                            return "Invalid time format.";
                          }
                        }
                        else {
                          return "Invalid time format.";
                        }
                      }
                    ),
                ),
              ],
            )
        )
      );
    });

    return new Container(
      child: new Column(
        children: result,
      )
    );
  }

  String parseTime(int hour, int minute) {
    String minuteString = minute < 10 ? '0${minute.toString()}' : minute.toString();
    if(hour == 12) return '${hour}:$minuteString PM';
    return hour > 12 ? '${hour - 12}:$minuteString PM' : '$hour:$minuteString AM';
  }

  bool isNumber(String value) {
    return new RegExp(r"\d+").hasMatch(value);
  }

  void sendRefillNotifications() {
    int days = (info.pills / info.dosesDaily).floor();
    var dateTime = DateTime.now();

    for(int i = 0; i < info.refillsRemaining; i++) {
      dateTime = dateTime.add(new Duration(days: days));
      String monthString = dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month.toString();
      String dayString = dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day.toString();
      createEvent('${dateTime.year}-$monthString-$dayString', 'Remember to refill your ${info.name} prescription.');
    }
  }

  void onSubmit() {

    if(_formKey.currentState.validate()) {
      sendRefillNotifications();
      scheduleNotifications();
      handleSendNotification();

    }
  }

  void handleSendNotification() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    var playerId = status.subscriptionStatus.userId;
    var notification = OSCreateNotification(
        playerIds: [playerId],
        content: "It's time to take " + overallName,
        heading: "Reminder",
        buttons: [
          OSActionButton(
              text: "Done!", id: "id1"
          )
        ]);

    var response = await OneSignal.shared.postNotification(notification);

  }

  void scheduleNotifications() {
    OneSignal.shared.init("f55292e5-b948-4cc5-a030-7cc819f72dbd");
    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // will be called whenever a notification is opened/button pressed.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Congrats()),
      );
    });
    void _handleNotificationReceived(OSNotification notification) {

    }
    OneSignal.shared.setNotificationReceivedHandler(_handleNotificationReceived);
  }

  void showGif() {
    String url = getGifUrl();
    InAppBrowser browser = new InAppBrowser();
    browser.open(url);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("android/app/src/main/res/drawable/home.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: FutureBuilder(
        future: infoFuture,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            info = snapshot.data;
            return buildForm(context);
          }
          return Center(
            child: CircularProgressIndicator(
              value: null,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white70),
            )
          );
        }
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    String pills = info.pills.toString();
    if (info.pills < 0) {
      pills = "";
    }
    String refills = info.refillsRemaining.toString();
    if (info.refillsRemaining < 0) {
      refills = "";
    }
    overallName = info.name;
    return new Padding(
      padding: new EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: Form(
        key: _formKey,
        child: Material(
          child: Padding(
            padding: new EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Text("Schedule", style: Theme.of(context).textTheme.headline),
                Container(
                  width: 200.0,
                  child: TextFormField(
                    initialValue: info.name,
                    decoration: InputDecoration(labelText: "Medication Name"),
                    validator: (text) {
                      if(text.length <= 0) return 'You must enter a name for this medication.';
                      else info.name = text;
                      overallName = text;
                    },
                  ),
                ),
                Container(
                    width: 200.0,
                    child: TextFormField(
                      initialValue: pills,
                      decoration: InputDecoration(labelText: "Pills per bottle"),
                      validator: (text) {
                        if(!isNumber(text)) return 'You must enter a number';
                        else info.pills = int.parse(text);
                      },
                    )
                ),
                Container(
                  width: 200.0,
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
                  child: TextFormField(
                    initialValue: refills,
                    decoration: InputDecoration(labelText: "Refills remaining"),
                    validator: (text) {
                      if(!isNumber(text)) return 'You must enter a number';
                      else info.refillsRemaining = int.parse(text);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                  child: Text("Reminders", style: Theme.of(context).textTheme.subhead),
                ),
                processReminders(info),
                GestureDetector(
                  onLongPress: showGif,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Submitted()),
                      );
                      overallName = info.name;
                      onSubmit();
                    },
                    child: Text("Save", style: Theme.of(context).textTheme.body1),
                  ),
                ),
              ],
            ),
          )
        ),
      )
    );
  }
}

class Reminder {
  String day;
  DateTime time;

  Reminder(String days, DateTime time) {
    this.day = days;
    this.time = time;
  }
}