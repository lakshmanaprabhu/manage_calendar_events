# manage_calendar_events

[![pub package](https://img.shields.io/pub/v/manage_calendar_events.svg)](https://pub.dev/packages/manage_calendar_events)
[![pub points](https://img.shields.io/pub/points/manage_calendar_events?logo=dart)](https://pub.dev/packages/manage_calendar_events/score)
[![pub likes](https://img.shields.io/pub/likes/manage_calendar_events?logo=dart)](https://pub.dev/packages/manage_calendar_events/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Flutter plugin for reading, creating, updating, and deleting device calendar events — with reminders and attendees — on Android and iOS.

## Platform support

| Android | iOS |
| :-----: | :-: |
|    ✓    |  ✓  |

## Features

* List all calendars available on the device, including whether each one is read-only
* Read events from a calendar — all events, a date range, or a whole week/month
* Create and update events: title, description, location, URL, all-day flag, and a reminder
* Delete events
* Add, update, and delete reminders on an existing event
* Add, list, and remove attendees on an event

## Getting started

### 1. Add the dependency

```yaml
dependencies:
  manage_calendar_events: ^2.1.2
```

### 2. Android setup

Add the calendar permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

### 3. iOS setup

Add the calendar usage description(s) to `ios/Runner/Info.plist`:

```xml
<key>NSCalendarsUsageDescription</key>
<string>This app needs calendar access to manage your events.</string>
<key>NSCalendarsFullAccessUsageDescription</key>
<string>This app needs calendar access to manage your events.</string>
```

`NSCalendarsFullAccessUsageDescription` is required on iOS 17+; `NSCalendarsUsageDescription` covers earlier versions.

## Usage

```dart
import 'package:manage_calendar_events/manage_calendar_events.dart';

final _calendarPlugin = CalendarPlugin();
```

### Request permissions

```dart
final granted = await _calendarPlugin.hasPermissions() ?? false;
if (!granted) {
  await _calendarPlugin.requestPermissions();
}
```

### List calendars

```dart
final calendars = await _calendarPlugin.getCalendars();
final calendar = calendars!.first;
```

### Read events

```dart
// Every event on a calendar
final events = await _calendarPlugin.getEvents(calendarId: calendar.id!);

// Events in an explicit date range
final events = await _calendarPlugin.getEventsByDateRange(
  calendarId: calendar.id!,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(const Duration(days: 30)),
);

// Shortcuts for the current week / month
final weekEvents = await _calendarPlugin.getEventsByWeek(
  calendarId: calendar.id!,
  findDate: DateTime.now(),
);
final monthEvents = await _calendarPlugin.getEventsByMonth(
  calendarId: calendar.id!,
  findDate: DateTime.now(),
);
```

### Create an event

```dart
final event = CalendarEvent(
  title: 'Team standup',
  description: 'Daily sync',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(const Duration(hours: 1)),
  reminder: Reminder(minutes: 15), // remind 15 minutes before the event
);

final eventId = await _calendarPlugin.createEvent(
  calendarId: calendar.id!,
  event: event,
);
```

### Update or delete an event

```dart
event
  ..eventId = eventId
  ..title = 'Team standup (moved)';
await _calendarPlugin.updateEvent(calendarId: calendar.id!, event: event);

await _calendarPlugin.deleteEvent(calendarId: calendar.id!, eventId: eventId!);
```

### Reminders

```dart
await _calendarPlugin.addReminder(
  calendarId: calendar.id!,
  eventId: eventId!,
  minutes: 30,
);
await _calendarPlugin.updateReminder(
  calendarId: calendar.id!,
  eventId: eventId!,
  minutes: 10,
);
await _calendarPlugin.deleteReminder(eventId: eventId!);
```

### Attendees

```dart
await _calendarPlugin.addAttendees(
  eventId: eventId!,
  newAttendees: [
    Attendee(name: 'Jane Doe', emailAddress: 'jane@example.com'),
  ],
);

final attendees = await _calendarPlugin.getAttendees(eventId: eventId!);
```

A full working app that exercises the whole API is in [`example/`](example).

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/lakshmanaprabhu/manage_calendar_events).

## License

MIT — see [LICENSE](LICENSE).
