part of manage_calendar_events;

class CalendarPlugin {
  static const MethodChannel _channel =
      const MethodChannel('manage_calendar_events');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Check your app has permissions to access the calendar events
  Future<bool?> hasPermissions() async {
    bool? hasPermission = false;
    try {
      hasPermission = await _channel.invokeMethod('hasPermissions');
    } catch (e) {
      print(e);
    }

    print("hasPermissions - " + hasPermission.toString());
    return hasPermission;
  }

  /// Request the app to fetch the permissions to access the calendar
  Future<void> requestPermissions() async {
    try {
      await _channel.invokeMethod('requestPermissions');
    } catch (e) {
      print(e);
    }

    return;
  }

  /// Returns the available calendars from the device
  Future<List<Calendar>?> getCalendars() async {
    List<Calendar>? calendars = [];
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

  /// Returns all the available events in the selected calendar
  Future<List<CalendarEvent>?> getEvents({required String calendarId}) async {
    List<CalendarEvent>? events = [];
    try {
      String eventsJson = await _channel.invokeMethod(
          'getEvents', <String, Object?>{"calendarId": calendarId});
      events =
          json.decode(eventsJson).map<CalendarEvent>((decodedCalendarEvent) {
        return CalendarEvent.fromJson(decodedCalendarEvent);
      }).toList();
    } catch (e) {
      print(e);
    }
    return events;
  }

  /// Returns all the available events on the given date Range
  Future<List<CalendarEvent>?> getEventsByDateRange({
    required String calendarId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    List<CalendarEvent>? events = [];
    try {
      String eventsJson =
          await _channel.invokeMethod('getEventsByDateRange', <String, Object?>{
        'calendarId': calendarId,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });
      events =
          json.decode(eventsJson).map<CalendarEvent>((decodedCalendarEvent) {
        return CalendarEvent.fromJson(decodedCalendarEvent);
      }).toList();
    } catch (e) {
      print(e);
    }
    return events;
  }

  /// Returns all the available events on the given date Range
  Future<List<CalendarEvent>?> getEventsByMonth({
    required String calendarId,
    required DateTime findDate,
  }) async {
    DateTime startDate = findFirstDateOfTheMonth(findDate);
    DateTime endDate = findLastDateOfTheMonth(findDate);

    return getEventsByDateRange(
        calendarId: calendarId, startDate: startDate, endDate: endDate);
  }

  /// Returns all the available events on the given date Range
  Future<List<CalendarEvent>?> getEventsByWeek({
    required String calendarId,
    required DateTime findDate,
  }) async {
    DateTime startDate = findFirstDateOfTheWeek(findDate);
    DateTime endDate = findLastDateOfTheWeek(findDate);

    return getEventsByDateRange(
        calendarId: calendarId, startDate: startDate, endDate: endDate);
  }

  /// Helps to create an event in the selected calendar
  Future<String?> createEvent({
    required String calendarId,
    required CalendarEvent event,
  }) async {
    String? eventId;

    try {
      eventId = await _channel.invokeMethod(
        'createEvent',
        <String, Object?>{
          'calendarId': calendarId,
          'eventId': event.eventId != null ? event.eventId : null,
          'title': event.title,
          'description': event.description,
          'startDate': event.startDate!.millisecondsSinceEpoch,
          'endDate': event.endDate!.millisecondsSinceEpoch,
          'location': event.location,
          'isAllDay': event.isAllDay != null ? event.isAllDay : false,
          'hasAlarm': event.hasAlarm != null ? event.hasAlarm : false,
          'reminder': event.reminder != null ? event.reminder!.minutes : null,
        },
      );
    } catch (e) {
      print(e);
    }
    return eventId;
  }

  /// Helps to update the edited event
  Future<String?> updateEvent({
    required String calendarId,
    required CalendarEvent event,
  }) async {
    String? eventId;

    try {
      eventId = await _channel.invokeMethod(
        'updateEvent',
        <String, Object?>{
          "calendarId": calendarId,
          'eventId': event.eventId != null ? event.eventId : null,
          'title': event.title,
          'description': event.description,
          'startDate': event.startDate!.millisecondsSinceEpoch,
          'endDate': event.endDate!.millisecondsSinceEpoch,
          'location': event.location,
          'isAllDay': event.isAllDay != null ? event.isAllDay : false,
          'hasAlarm': event.hasAlarm != null ? event.hasAlarm : false,
          'reminder': event.reminder != null ? event.reminder!.minutes : null,
        },
      );
    } catch (e) {
      print(e);
    }
    return eventId;
  }

  /// Deletes the selected event in the selected calendar
  Future<bool?> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    bool? isDeleted = false;
    try {
      isDeleted = await _channel.invokeMethod(
        'deleteEvent',
        <String, Object?>{
          "calendarId": calendarId,
          'eventId': eventId,
        },
      );
    } catch (e) {
      print(e);
    }
    return isDeleted;
  }

  /// Helps to add reminder in Android [add alarms in iOS]
  Future<void> addReminder({
    required String calendarId,
    required String eventId,
    int? minutes,
  }) async {
    try {
      await _channel.invokeMethod(
        'addReminder',
        <String, Object?>{
          "calendarId": calendarId,
          'eventId': eventId,
          'minutes': minutes.toString(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  /// Helps to update the selected reminder
  Future<int?> updateReminder({
    required String calendarId,
    required String eventId,
    int? minutes,
  }) async {
    int? updateCount = 0;
    try {
      updateCount = await _channel.invokeMethod(
        'updateReminder',
        <String, Object?>{
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

  /// Helps to delete the selected event's reminder
  Future<int?> deleteReminder({required String eventId}) async {
    int? updateCount = 0;
    try {
      updateCount = await _channel.invokeMethod(
        'deleteReminder',
        <String, Object?>{
          'eventId': eventId,
        },
      );
    } catch (e) {
      print(e);
    }
    return updateCount;
  }

  /// Find the first date of the month which contains the provided date.
  DateTime findFirstDateOfTheMonth(DateTime dateTime) {
    DateTime firstDayOfMonth = DateTime.utc(dateTime.year, dateTime.month, 1);
    print('firstDayOfMonth - $firstDayOfMonth');
    return firstDayOfMonth;
  }

  /// Find the last date of the month which contains the provided date.
  DateTime findLastDateOfTheMonth(DateTime dateTime) {
    DateTime lastDayOfMonth = DateTime.utc(dateTime.year, dateTime.month + 1, 1)
        .subtract(Duration(hours: 1));
    print('lastDayOfMonth - $lastDayOfMonth');
    return lastDayOfMonth;
  }

  /// Find the first date of the week which contains the provided date.
  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  /// Find last date of the week which contains provided date.
  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }
}
