import 'dart:math';

import 'package:flutter/material.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

class EventDetails extends StatefulWidget {
  final CalendarEvent activeEvent;
  final CalendarPlugin calendarPlugin;
  final bool isReadOnly;

  EventDetails({
    required this.activeEvent,
    required this.calendarPlugin,
    this.isReadOnly = false,
  });

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.activeEvent.title!),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Description: ${this.widget.activeEvent.description}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 20),
                  Text('Start Date: ${this.widget.activeEvent.startDate}'),
                  SizedBox(height: 20),
                  Text('End Date: ${this.widget.activeEvent.endDate}'),
                  SizedBox(height: 20),
                  Text('Location: ${this.widget.activeEvent.location}'),
                  SizedBox(height: 20),
                  Text('URL: ${this.widget.activeEvent.url}'),
                  SizedBox(height: 20),
                  Text('All day event: ${this.widget.activeEvent.isAllDay}'),
                  SizedBox(height: 20),
                  Text('Has Alarm: ${this.widget.activeEvent.hasAlarm}'),
                  SizedBox(height: 20),
                  Text(
                    'Reminder: ${this.widget.activeEvent.reminder?.minutes}',
                  ),
                ],
              ),
            ),
            buildAttendeeList(),
          ],
        ),
      ),
      floatingActionButton: widget.isReadOnly
          ? null
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                setState(() {
                  _addAttendee(widget.activeEvent.eventId!);
                });
              },
            ),
    );
  }

  buildAttendeeList() {
    return FutureBuilder<List<Attendee>?>(
      future: _getAttendees(widget.activeEvent.eventId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: Text('No Attendee found'));
        }
        List<Attendee> attendees = snapshot.data!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text('Attendees: ${attendees.length}'),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: attendees.length,
              itemBuilder: (context, index) {
                Attendee attendee = attendees.elementAt(index);
                return populateListContent(attendee);
              },
            ),
          ],
        );
      },
    );
  }

  Widget populateListContent(Attendee attendee) {
    return Dismissible(
      key: Key(attendee.emailAddress),
      confirmDismiss: (direction) async {
        setState(() {
          widget.calendarPlugin.deleteAttendee(
            eventId: widget.activeEvent.eventId!,
            attendee: attendee,
          );
        });
        return false;
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
      // other side delete option
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      child: ListTile(
        title: Text(attendee.name),
        subtitle: Text(attendee.emailAddress),
        trailing: Text(attendee.isOrganiser ? 'Organiser' : ''),
      ),
    );
  }

  Future<List<Attendee>?> _getAttendees(String eventId) async {
    return await widget.calendarPlugin.getAttendees(eventId: eventId);
  }

  _addAttendee(String eventId) async {
    var number = Random().nextInt(100);
    var newAttendee = Attendee(
        emailAddress: 'attendee$number@gmail.com', name: 'Attendee$number');
    await widget.calendarPlugin
        .addAttendees(eventId: eventId, newAttendees: [newAttendee]);
  }
}
