## 2.1.2
* Replace the LICENSE file with an actual MIT license (it previously just said "All rights reserved", which pub.dev flagged as `license:unknown`)
* Rewrite README.md with badges, platform support table, full setup instructions (including the iOS 17 `NSCalendarsFullAccessUsageDescription` key), and copy-pasteable usage examples for every API method
* Bump `flutter_lints` to `^6.0.0` and fix the lints it surfaced, in both the plugin and the example app
* `dart format` the whole `lib/`/`test/` tree
* Move the example app's `manage_calendar_events` dependency from `dev_dependencies` to `dependencies` (matches how it's actually used)
* Fix #24: `addReminder` never resolved its result on Android or iOS, leaving the Dart `Future` hanging
* Fix #42: `onDetachedFromEngine` NPE when the plugin is detached without ever attaching to an Activity
* Fix #23: Android event timezone used a display name instead of a valid IANA timezone ID
* Fix #36: `createEvent`/`updateEvent` crashed on iOS when the calendar/event lookup failed instead of failing gracefully
* Fix #30: `createEvent`/`updateEvent` ignored the caller's `reminder`/`hasAlarm` on both Android and iOS (Android never wrote a Reminders row at all; iOS used a hardcoded fixed offset)
* Fix #37: migrate iOS calendar permission requests/checks to the iOS 17+ full-access API, with a fallback for older versions; document `NSCalendarsFullAccessUsageDescription` in the README
## 2.1.1
* Fix iOS crashes reported in #3, #27, #28, #33, #34, #39:
  * `createEvent`/`updateEvent` no longer crash when `title`/`description` are nil (#3)
  * `deleteEvent` no longer crashes when the event can't be found (#33, #34)
  * `getAttendees`/event fetching no longer crash on attendees without an email address, or events without alarms (#27, #28)
  * `addAttendees` no longer crashes when merging existing participants that lack a name/email (#39)
* Remove stray `print()` calls from the Dart API surface; route error logging through `debugPrint`
* Add `analysis_options.yaml` (`flutter_lints`) and `topics` to pubspec.yaml
* Remove vestigial `gradlew`/`gradlew.bat`/`gradle-wrapper.jar`/`.iml` files from the plugin's own `android/` folder (never needed by consumers)
* Remove unused `MY_CAL_WRITE_REQ` constant in `CalendarOperations.java`
## 2.1.0
* Update to support the latest Android and iOS toolchains
  * Android: AGP 8.7.0, Kotlin 1.8.22, compileSdk 35, minSdk 21, Java 11
  * iOS: raise deployment target to 12.0
* Raise Dart/Flutter SDK constraints (Dart >=3.4.0, Flutter >=3.24.0)
* Add `repository` field to pubspec.yaml
## 2.0.3
* Update the android compile/min SDK
* Update the iOS latest support
* Remove the deprecated code
## 2.0.2
* Update the android compile/min SDK
* Fixed some iOS issues with the help
## 2.0.1
* Supporting the new Android plugins APIs. Ref: https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration

## 2.0.0
* Add Attendee field support on the Event both iOS and Android
## 1.0.9
* Add Attendee field [Read-only] support in iOS and Android
## 1.0.8
* Add URL field on the Event (specially for iOS)

## 1.0.7
* Implemented a way to filter the events by Week, Month and given dates

## 1.0.6
* Fixed the Android release mode issue
* Added isAllDay flag in event as suggested by @sageata

## 1.0.5
* Added Null Safety support

## 1.0.4
* Added the required values to avoid unnecessary errors

## 1.0.3

* Added support for latest Android and iOS SDK
* Fixed a minor issue for iOS

## 1.0.1

* Added dartdoc comment for APIs

## 0.0.1

* Initial release 
* Provides the add, update and delete event support 
