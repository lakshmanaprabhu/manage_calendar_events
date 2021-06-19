import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

class EventDetails extends StatelessWidget {
  final CalendarEvent activeEvent;

  EventDetails({required this.activeEvent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.activeEvent.title!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Description: ${this.activeEvent.description}",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20),
              Text("Start Date: ${this.activeEvent.startDate}"),
              SizedBox(height: 20),
              Text("End Date: ${this.activeEvent.endDate}"),
              SizedBox(height: 20),
              Text("Location: ${this.activeEvent.location}"),
              SizedBox(height: 20),
              Text("URL: ${this.activeEvent.url}"),
              SizedBox(height: 20),
              Text("All day event: ${this.activeEvent.isAllDay}"),
              SizedBox(height: 20),
              Text("Has Alarm: ${this.activeEvent.hasAlarm}"),
              SizedBox(height: 20),
              Text("Reminder: ${this.activeEvent.reminder?.minutes}"),
              ...attendeeList(),
            ],
          ),
        ),
      ),
    );
  }

  attendeeList() {
    List<Widget> attendeeWidgets = [];
    if (this.activeEvent.attendees != null) {
      List<Attendee> attendees = this.activeEvent.attendees!.attendees;
      attendeeWidgets.add(SizedBox(height: 20));
      attendeeWidgets.add(Text("Attendees: ${attendees.length}"));

      attendees.forEach((attendee) {
        attendeeWidgets.add(ListTile(
          title: Text(attendee.name),
          subtitle: Text(attendee.emailAddress),
          trailing: Text(attendee.isOrganiser ? 'Organiser' : ''),
        ));
      });
    }
    return attendeeWidgets;
  }
}
