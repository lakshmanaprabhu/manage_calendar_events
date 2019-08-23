# Manage Calendar Events

A flutter plugin which will help you to add, edit and remove the events (with reminders) from your (Android and ios) calendars

## What are the features available?
* can read all the available calendars in your device (Android and ios)
* can read all the events from the selected calendar
* can add an event with title, description, start date, end date and a reminder in your selected calendar
* can update or delete the selected event
* can add, update and remove the reminders (/alarms in ios)

## For Android

Android support is used a Java code and it requires a following permissions

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

## For iOS

iOS support is used a swift code and it requires a following permissions to add in info.plist

```xml
<key>NSCalendarsUsageDescription</key>
<string>INSERT_REASON_HERE</string>
```