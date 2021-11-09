part of manage_calendar_events;

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
    this.id = data["id"];
    this.name = data["name"];
    this.accountName = data["accountName"];
    this.ownerName = data["ownerName"];
    this.isReadOnly = data["isReadOnly"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = this.id;
    data["name"] = this.name;
    data["accountName"] = this.accountName;
    data["ownerName"] = this.ownerName;
    data["isReadOnly"] = this.isReadOnly;
    return data;
  }
}
