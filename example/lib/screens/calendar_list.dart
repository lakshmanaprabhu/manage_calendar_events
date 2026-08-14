import 'package:flutter/material.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

import 'event_list.dart';

class CalendarList extends StatefulWidget {
  const CalendarList({super.key});

  @override
  State<CalendarList> createState() => _CalendarListState();
}

class _CalendarListState extends State<CalendarList> {
  final CalendarPlugin _myPlugin = CalendarPlugin();
  late Future<List<Calendar>?> _calendars;

  @override
  void initState() {
    super.initState();
    _calendars = _fetchCalendars();
  }

  void _refresh() {
    setState(() {
      _calendars = _fetchCalendars();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget futureBuilder = FutureBuilder<List<Calendar>?>(
      future: _calendars,
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
                    ? const Text('Read Only')
                    : null,
                trailing: calendar.isLocal == true
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteCalendar(calendar),
                      )
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
            futureBuilder,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCalendar,
        tooltip: 'Create a local calendar',
        child: const Icon(Icons.add),
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

  Future<void> _createCalendar() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New local calendar'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Calendar name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }

    await _myPlugin.createCalendar(
      calendarName: name.trim(),
      color: Colors.blue,
    );
    _refresh();
  }

  Future<void> _deleteCalendar(Calendar calendar) async {
    await _myPlugin.deleteCalendar(calendarId: calendar.id!);
    _refresh();
  }
}
