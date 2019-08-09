import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';
import 'package:manage_calendar_events_example/screens/event_details.dart';

class EventList extends StatefulWidget {
  final String calendarId;

  EventList({this.calendarId});

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final CalendarPlugin _myPlugin = CalendarPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events List"),
      ),
      body: FutureBuilder(
        future: _fetchEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text("No Events found"));
          }
          List<CalendarEvent> events = snapshot.data;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              CalendarEvent event = events.elementAt(index);
              return Dismissible(
                key: Key(event.eventId),
                confirmDismiss: (direction) async {
                  if (DismissDirection.startToEnd == direction) {
                    print("startToEnd");
                    _deleteEvent(event.eventId);
                    return true;
                  } else {
                    print("endToStart");
                    setState(() {
                      _updateEvent(event);
                    });

                    return false;
                  }
                },

                // delete option
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                // update the event
                secondaryBackground: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(DateFormat("yyyy-MM-dd hh:mm:ss")
                      .format(event.startDate)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EventDetails(
                            activeEvent: event,
                          );
                        },
                      ),
                    );
                  },
                  onLongPress: () {
                    _deleteReminder(event.eventId);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _addEvent();
        },
      ),
    );
  }

  _fetchEvents() async {
    return _myPlugin.getEvents(calendarId: this.widget.calendarId);
  }

  void _addEvent() async {
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(Duration(hours: 3));
    CalendarEvent _newEvent = CalendarEvent(
        title: "Event from plugin",
        description: "test plugin description",
        startDate: startDate,
        endDate: endDate,
        location: "Chennai, Tamilnadu");
    _myPlugin
        .createEvent(calendarId: widget.calendarId, event: _newEvent)
        .then((evenId) {
      setState(() {
        print("Event Id is: $evenId");
      });
    });
  }

  void _deleteEvent(String eventId) async {
    _myPlugin
        .deleteEvent(calendarId: widget.calendarId, eventId: eventId)
        .then((count) {
      print("Updated count is: $count");
    });
  }

  void _updateEvent(CalendarEvent event) async {
    event.title = "Updated from Event";
    event.description = "Test description is updated now";
    _myPlugin
        .updateEvent(calendarId: widget.calendarId, event: event)
        .then((eventId) {
      print("${event.eventId} is updated to $eventId");
    });

    if (event.hasAlarm) {
      _updateReminder(event.eventId, 65);
    } else {
      _addReminder(event.eventId, 40);
    }
  }

  void _addReminder(String eventId, int minutes) async {
    _myPlugin.addReminder(
        calendarId: widget.calendarId, eventId: eventId, minutes: minutes);
  }

  void _updateReminder(String eventId, int minutes) async {
    _myPlugin.updateReminder(
        calendarId: widget.calendarId, eventId: eventId, minutes: minutes);
  }

  void _deleteReminder(String eventId) {
    _myPlugin.deleteReminder(eventId: eventId);
  }
}
