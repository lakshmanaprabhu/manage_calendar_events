part of '../../manage_calendar_events.dart';

class Calendar {
  String? id;
  String? name;
  String? accountName;
  String? ownerName;
  bool? isReadOnly;

  /// Whether this calendar is a local, non-synced calendar (e.g. one
  /// created via [CalendarPlugin.createCalendar]) rather than one backed
  /// by a synced account such as Google or iCloud.
  ///
  /// Only local calendars can be removed with
  /// [CalendarPlugin.deleteCalendar].
  bool? isLocal;

  Calendar({
    required this.id,
    this.name,
    this.accountName,
    this.ownerName,
    this.isReadOnly,
    this.isLocal,
  });

  Calendar.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    accountName = data["accountName"];
    ownerName = data["ownerName"];
    isReadOnly = data["isReadOnly"];
    isLocal = data["isLocal"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["accountName"] = accountName;
    data["ownerName"] = ownerName;
    data["isReadOnly"] = isReadOnly;
    data["isLocal"] = isLocal;
    return data;
  }
}
