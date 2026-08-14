part of '../../manage_calendar_events.dart';

class CalendarEvent {
  String? eventId;
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  String? location;
  int? duration;
  bool? isAllDay;
  bool? hasAlarm;
  String? url;
  Reminder? reminder;
  Attendees? attendees;

  CalendarEvent({
    this.eventId,
    this.title = '',
    this.description = '',
    required this.startDate,
    required this.endDate,
    this.location,
    this.duration,
    this.isAllDay = false,
    this.hasAlarm = false,
    this.url,
    this.attendees,
    this.reminder,
  });

  CalendarEvent.fromJson(Map<String, dynamic> data) {
    eventId = data['eventId'];
    title = data['title'];
    description = data['description'];
    var date = data['startDate'];
    if (date != null) {
      startDate = DateTime.fromMillisecondsSinceEpoch(date);
    }
    date = data['endDate'];
    if (date != null) {
      endDate = DateTime.fromMillisecondsSinceEpoch(date);
    }
    location = data['location'];
    isAllDay = data['isAllDay'];
    hasAlarm = data['hasAlarm'];
    url = data['url'];
    if (data['reminder'] != null) {
      reminder = Reminder.fromJson(data['reminder']);
    }
    if (data['attendees'] != null && (data['attendees'] as List).isNotEmpty) {
      attendees = Attendees.fromJson(data['attendees']);
    }
  }

  void setReminder(Reminder reminder) {
    this.reminder = reminder;
  }
}

class Reminder {
  final int minutes;

  Reminder({required this.minutes});

  Reminder.fromJson(Map<String, dynamic> data) : minutes = data['minutes'];
}

class Attendees {
  final List<Attendee> attendees;

  bool get hasAttendees => attendees.isNotEmpty;

  Attendees({required this.attendees});

  static Attendees fromJson(List<dynamic> data) {
    List<Attendee> attendees = List.empty(growable: true);
    for (var element in data) {
      Attendee attendee = Attendee.fromJson(element);
      attendees.add(attendee);
    }
    return Attendees(attendees: attendees);
  }
}

class Attendee {
  final String name;
  final String emailAddress;
  final bool isOrganiser;

  Attendee({
    required this.name,
    required this.emailAddress,
    this.isOrganiser = false,
  });

  Attendee.fromJson(Map<String, dynamic> data)
      : name = data['name'],
        emailAddress = data['emailAddress'],
        isOrganiser = data['isOrganiser'] ?? false;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'emailAddress': emailAddress,
      'isOrganiser': isOrganiser,
    };
  }

  @override
  String toString() {
    return 'Name is: $name - Email Address is $emailAddress - isOrganiser: $isOrganiser';
  }
}
