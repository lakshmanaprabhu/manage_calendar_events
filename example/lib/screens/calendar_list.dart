import 'package:flutter/material.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

import 'event_list.dart';

class CalendarList extends StatelessWidget {
  final CalendarPlugin _myPlugin = CalendarPlugin();

  @override
  Widget build(BuildContext context) {
    Widget _futureBuilder = FutureBuilder<List<Calendar>?>(
      future: _fetchCalendars(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        List<Calendar> calendars = snapshot.data!;
        return ListView.builder(
            shrinkWrap: true,
            itemCount: calendars.length,
            itemBuilder: (context, index) {
              Calendar calendar = calendars[index];
              return ListTile(
                title: Text(calendar.name!),
                subtitle: calendar.isReadOnly != null && calendar.isReadOnly!
                    ? Text('Read Only')
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return EventList(
                          calendarId: calendar.id!,
                          isReadOnly: calendar.isReadOnly ?? false,
                        );
                      },
                    ),
                  );
                },
              );
            });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Calendars List',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            _futureBuilder,
          ],
        ),
      ),
    );
  }

  Future<List<Calendar>?> _fetchCalendars() async {
    _myPlugin.hasPermissions().then((value) {
      if (!value!) {
        _myPlugin.requestPermissions();
      }
    });

    return _myPlugin.getCalendars();
  }
}
