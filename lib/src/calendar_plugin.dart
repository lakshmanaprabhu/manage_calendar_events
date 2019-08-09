part of manage_calendar_events;

class CalendarPlugin {
  static const MethodChannel _channel =
      const MethodChannel('manage_calendar_events');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool> hasPermissions() async {
    bool hasPermission = false;
    try {
      hasPermission = await _channel.invokeMethod('hasPermissions');
    } catch (e) {
      print(e);
    }

    print("hasPermissions - " + hasPermission.toString());
    return hasPermission;
  }

  Future<void> requestPermissions() async {
    try {
      await _channel.invokeMethod('requestPermissions');
    } catch (e) {
      print(e);
    }

    return;
  }

  Future<List<Calendar>> getCalendars() async {
    List<Calendar> calendars = List();
    try {
      String calendarsJson = await _channel.invokeMethod('getCalendars');
      calendars = json.decode(calendarsJson).map<Calendar>((decodedCalendar) {
        return Calendar.fromJson(decodedCalendar);
      }).toList();
    } catch (e) {
      print(e);
    }
    return calendars;
  }

  Future<List<CalendarEvent>> getEvents({String calendarId}) async {
    List<CalendarEvent> events = List();
    try {
      String eventsJson = await _channel.invokeMethod(
          'getEvents', <String, Object>{"calendarId": calendarId});
      events =
          json.decode(eventsJson).map<CalendarEvent>((decodedCalendarEvent) {
        return CalendarEvent.fromJson(decodedCalendarEvent);
      }).toList();
    } catch (e) {
      print(e);
    }
    return events;
  }

  Future<String> createEvent({String calendarId, CalendarEvent event}) async {
    String eventId;

    try {
      eventId = await _channel.invokeMethod(
        'createEvent',
        <String, Object>{
          "calendarId": calendarId,
          'eventId': event.eventId != null ? event.eventId : null,
          'title': event.title,
          'description': event.description,
          'startDate': event.startDate.millisecondsSinceEpoch,
          'endDate': event.endDate.millisecondsSinceEpoch,
          'location': event.location,
          'isAllDay': event.isAllDay != null ? event.isAllDay : false,
          'hasAlarm': event.hasAlarm != null ? event.hasAlarm : false,
          'reminder': event.reminder != null ? event.reminder.minutes : null,
        },
      );
    } catch (e) {
      print(e);
    }
    return eventId;
  }

  Future<String> updateEvent({String calendarId, CalendarEvent event}) async {
    String eventId;

    try {
      eventId = await _channel.invokeMethod(
        'updateEvent',
        <String, Object>{
          "calendarId": calendarId,
          'eventId': event.eventId != null ? event.eventId : null,
          'title': event.title,
          'description': event.description,
          'startDate': event.startDate.millisecondsSinceEpoch,
          'endDate': event.endDate.millisecondsSinceEpoch,
          'location': event.location,
          'isAllDay': event.isAllDay != null ? event.isAllDay : false,
          'hasAlarm': event.hasAlarm != null ? event.hasAlarm : false,
          'reminder': event.reminder != null ? event.reminder.minutes : null,
        },
      );
    } catch (e) {
      print(e);
    }
    return eventId;
  }

  Future<int> deleteEvent({String calendarId, String eventId}) async {
    int updateCount = 0;
    try {
      updateCount = await _channel.invokeMethod(
        'deleteEvent',
        <String, Object>{
          "calendarId": calendarId,
          'eventId': eventId,
        },
      );
    } catch (e) {
      print(e);
    }
    return updateCount;
  }

  Future<void> addReminder(
      {String calendarId, String eventId, int minutes}) async {
    try {
      await _channel.invokeMethod(
        'addReminder',
        <String, Object>{
          "calendarId": calendarId,
          'eventId': eventId,
          'minutes': minutes.toString(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<int> updateReminder(
      {String calendarId, String eventId, int minutes}) async {
    int updateCount = 0;
    try {
      updateCount = await _channel.invokeMethod(
        'updateReminder',
        <String, Object>{
          "calendarId": calendarId,
          'eventId': eventId,
          'minutes': minutes.toString(),
        },
      );
    } catch (e) {
      print(e);
    }
    return updateCount;
  }

  Future<int> deleteReminder({String eventId}) async {
    int updateCount = 0;
    try {
      updateCount = await _channel.invokeMethod(
        'deleteReminder',
        <String, Object>{
          'eventId': eventId,
        },
      );
    } catch (e) {
      print(e);
    }
    return updateCount;
  }
}
