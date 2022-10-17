import 'package:flutter/material.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

import 'screens/calendar_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: new CalendarPluginCheck());
  }
}

class CalendarPluginCheck extends StatelessWidget {
  final CalendarPlugin _myPlugin = CalendarPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _myPlugin.hasPermissions().then((value) {
              if (!value!) {
                _myPlugin.requestPermissions();
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CalendarList()));
              }
            });
          },
          child: Text('Show Calendars'),
        ),
      ),
    );
  }
}
