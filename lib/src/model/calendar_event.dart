part of manage_calendar_events;

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
  });

  CalendarEvent.fromJson(Map<String, dynamic> data) {
    this.eventId = data['eventId'];
    this.title = data['title'];
    this.description = data['description'];
    var date = data['startDate'];
    if (date != null) {
      this.startDate = DateTime.fromMillisecondsSinceEpoch(date);
    }
    date = data['endDate'];
    if (date != null) {
      this.endDate = DateTime.fromMillisecondsSinceEpoch(date);
    }
    this.location = data['location'];
    this.isAllDay = data['isAllDay'];
    this.hasAlarm = data['hasAlarm'];
    this.url = data['url'];
    if (data['reminder'] != null) {
      this.reminder = Reminder.fromJson(data['reminder']);
    }
    if (data['attendees'] != null && (data['attendees'] as List).isNotEmpty) {
      this.attendees = Attendees.fromJson(data['attendees']);
    }
  }

  setReminder(Reminder reminder) {
    this.reminder = reminder;
  }
}

class Reminder {
  final int minutes;

  Reminder({required this.minutes});

  Reminder.fromJson(Map<String, dynamic> data) : this.minutes = data['minutes'];
}

class Attendees {
  final List<Attendee> attendees;

  bool get hasAttendees => attendees.isNotEmpty;

  Attendees({required this.attendees});

  static fromJson(List<dynamic> data) {
    List<Attendee> attendees = List.empty(growable: true);
    data.forEach((element) {
      Attendee attendee = Attendee.fromJson(element);
      attendees.add(attendee);
    });
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
      : this.name = data['name'],
        this.emailAddress = data['emailAddress'],
        this.isOrganiser = data['isOrganiser'] ?? false;

  @override
  String toString() {
    return 'Name is: $name - Email Address is $emailAddress - isOrganiser: $isOrganiser';
  }
}
