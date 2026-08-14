part of '../../manage_calendar_events.dart';

class Calendar {
  String? id;
  String? name;
  String? accountName;
  String? ownerName;
  bool? isReadOnly;

  Calendar({
    required this.id,
    this.name,
    this.accountName,
    this.ownerName,
    this.isReadOnly,
  });

  Calendar.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    accountName = data["accountName"];
    ownerName = data["ownerName"];
    isReadOnly = data["isReadOnly"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["accountName"] = accountName;
    data["ownerName"] = ownerName;
    data["isReadOnly"] = isReadOnly;
    return data;
  }
}
