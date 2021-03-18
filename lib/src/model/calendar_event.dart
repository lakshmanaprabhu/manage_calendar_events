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
  Reminder? reminder;

  CalendarEvent(
      {this.eventId,
      this.title = '',
      this.description = '',
      required this.startDate,
      required this.endDate,
      this.location,
      this.duration,
      this.isAllDay = false,
      this.hasAlarm = false});

  CalendarEvent.fromJson(Map<String, dynamic> data) {
    this.eventId = data["eventId"];
    this.title = data["title"];
    this.description = data["description"];
    var date = data["startDate"];
    if (date != null) {
      this.startDate = DateTime.fromMillisecondsSinceEpoch(date);
    }
    date = data["endDate"];
    if (date != null) {
      this.endDate = DateTime.fromMillisecondsSinceEpoch(date);
    }
    this.location = data["location"];
    this.isAllDay = data["isAllDay"];
    this.hasAlarm = data["hasAlarm"];
    if (data["reminder"] != null) {
      this.reminder = Reminder.fromJson(data["reminder"]);
    }
  }

  setReminder(Reminder reminder) {
    this.reminder = reminder;
  }
}

class Reminder {
  final int? minutes;

  Reminder({required this.minutes});

  Reminder.fromJson(Map<String, dynamic> data) : this.minutes = data["minutes"];
}
