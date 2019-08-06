import Flutter
import UIKit
import EventKit

extension Date {
    var millisecondsSinceEpoch: Double { return self.timeIntervalSince1970 * 1000.0 }
}

public class SwiftManageCalendarEventsPlugin: NSObject, FlutterPlugin {
    let eventStore = EKEventStore()
    
    struct Calendar: Codable {
        let id: String
        let name: String
        let accountName: String?
        let ownerName: String?
        let isReadOnly: Bool
    }
    
    struct CalendarEvent: Codable {
        let eventId: String
        let title: String
        let description: String?
        let startDate: Int64
        let endDate: Int64
        let location: String?
        let isAllDay: Bool
        let hasAlarm: Bool
        var reminder: Reminder?
    }
    
    struct Reminder: Codable {
        let minutes: Int64
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "manage_calendar_events", binaryMessenger: registrar.messenger())
        let instance = SwiftManageCalendarEventsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if (call.method == "hasPermissions") {
            result(self.hasPermissions());
        } else if (call.method == "requestPermissions") {
            self.requestPermissions();
        } else if (call.method == "getCalendars") {
            let calendarArrayList = self.getCalendars();
            result(calendarArrayList);
        } else if (call.method == "getEvents") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let calendarId = arguments["calendarId"] as! String
            result(self.getEvents(calendarId: calendarId));
            //    } else if (call.method == "createEvent") || call.method == "updateEvent") {
            //        String calendarId = call.argument("calendarId");
            //        String eventId = call.argument("eventId");
            //        String title = call.argument("title");
            //        String description = call.argument("description");
            //        long startDate = call.argument("startDate");
            //        long endDate = call.argument("endDate");
            //        String location = call.argument("location");
            //        boolean isAllDay = call.argument("isAllDay");
            //        boolean hasAlarm = call.argument("hasAlarm");
            //        CalendarEvent event = new CalendarEvent(eventId, title, description, startDate,
            //                                                endDate, location, isAllDay, hasAlarm);
            //        self.createUpdateEvent(calendarId, event);
            //        result(event.getEventId());
            //    } else if (call.method == "deleteEvent") {
            //        String calendarId = call.argument("calendarId");
            //        String eventId = call.argument("eventId");
            //        result(self.deleteEvent(calendarId, eventId));
            //    } else if (call.method == "addReminder") {
            //        String calendarId = call.argument("calendarId");
            //        String eventId = call.argument("eventId");
            //        self.addReminder(calendarId, eventId);
            //    } else if (call.method == "updateReminder") {
            //        String calendarId = call.argument("calendarId");
            //        String eventId = call.argument("eventId");
            //        result(self.updateReminder(calendarId, eventId));
            //    } else if (call.method == "deleteReminder") {
            //        String eventId = call.argument("eventId");
            //        result(self.deleteReminder(eventId));
            //    } else {
            //        result.notImplemented();
        }
    }
    
    private func hasPermissions() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        return status == EKAuthorizationStatus.authorized;
    }
    
    private func requestPermissions() {
        eventStore.requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            print("Access Granted")
        })
    }
    
    private func getCalendars() -> String? {
        if(!hasPermissions()) {
            requestPermissions();
        }
        let ekCalendars = self.eventStore.calendars(for: .event)
        var calendars = [Calendar]()
        for ekCalendar in ekCalendars {
            let calendar = Calendar(id: ekCalendar.calendarIdentifier, name: ekCalendar.title, accountName: "", ownerName: "", isReadOnly: !ekCalendar.allowsContentModifications)
            calendars.append(calendar)
        }
        print("isEmpty",  ekCalendars.count);
        let jsonEncoder = JSONEncoder();
        var jsonString = "";
        do {
            let jsonData = try jsonEncoder.encode(calendars)
            jsonString = (String(data: jsonData, encoding: .utf8))!
        } catch {
            print("fetching calendars failed.. ");
        }
        
        return jsonString;
    }
    
    private func getEvents(calendarId : String) -> String? {
        if(!hasPermissions()) {
            requestPermissions();
        }
        let selectedCalendar = self.eventStore.calendar(withIdentifier: calendarId)
        let startDate = NSDate(timeIntervalSinceNow: -60*60*24*180)
        let endDate = NSDate(timeIntervalSinceNow: 60*60*24*180)
        let predicate = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: [selectedCalendar!])
        let ekEvents = self.eventStore.events(matching: predicate)
        
        var events = [CalendarEvent]()
        for ekEvent in ekEvents {
            NSLog("events.count inside for = %d",  events.count);
            NSLog("event = %@",  ekEvent);
            var reminder : Reminder?
            if(ekEvent.hasAlarms) {
                NSLog("HasAlarms: ")
                reminder = Reminder(minutes:Int64(ekEvent.alarms![0].relativeOffset))
            }
            let event = CalendarEvent(
                eventId: ekEvent.eventIdentifier,
                title: ekEvent.title,
                description: ekEvent.notes,
                startDate: Int64(ekEvent.startDate.millisecondsSinceEpoch),
                endDate: Int64(ekEvent.endDate.millisecondsSinceEpoch),
                location: ekEvent.location,
                isAllDay: ekEvent.isAllDay,
                hasAlarm: ekEvent.hasAlarms,
                reminder: reminder
            )
            events.append(event)
        }
        NSLog("events.count = %d",  events.count);
        let jsonEncoder = JSONEncoder();
        var jsonString = "";
        do {
            let jsonData = try jsonEncoder.encode(events)
            jsonString = (String(data: jsonData, encoding: .utf8))!
        } catch {
            debugPrint("fetching events failed.. ");
        }
        
        return jsonString;
    }
}
