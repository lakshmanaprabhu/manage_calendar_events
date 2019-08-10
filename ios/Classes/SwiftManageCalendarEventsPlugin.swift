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
        var eventId: String?
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
            result(self.hasPermissions())
        } else if (call.method == "requestPermissions") {
            self.requestPermissions()
        } else if (call.method == "getCalendars") {
            let calendarArrayList = self.getCalendars()
            result(calendarArrayList)
        } else if (call.method == "getEvents") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let calendarId = arguments["calendarId"] as! String
            result(self.getEvents(calendarId: calendarId))
        } else if ((call.method == "createEvent") || (call.method == "updateEvent")) {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let calendarId = arguments["calendarId"] as! String
            let eventId = arguments["eventId"] as? String
            let title = arguments["title"] as! String
            let description = arguments["description"] as! String
            let startDate = arguments["startDate"] as! Int64
            let endDate = arguments["endDate"] as! Int64
            let location = arguments["location"] as! String
            let isAllDay = arguments["isAllDay"] as! Bool
            let hasAlarm = arguments["hasAlarm"] as! Bool
            let reminder = arguments["reminder"] as? Reminder

            var event = CalendarEvent(
                eventId: eventId,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                location: location,
                isAllDay: isAllDay,
                hasAlarm: hasAlarm,
                reminder: reminder
            )
            self.createUpdateEvent(calendarId: calendarId, event: &event)
            result(event.eventId)
        } else if (call.method == "deleteEvent") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let calendarId = arguments["calendarId"] as! String
            let eventId = arguments["eventId"] as! String
            result(self.deleteEvent(calendarId: calendarId, eventId: eventId))
        } else if (call.method == "addReminder") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let eventId = arguments["eventId"] as! String
            let minutes = arguments["minutes"] as! NSString
            self.addReminder(eventId: eventId, reminder: Reminder(minutes: minutes.longLongValue))
        } else if (call.method == "updateReminder") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let eventId = arguments["eventId"] as! String
            let minutes = arguments["minutes"] as! NSString
            result(self.updateReminder(eventId: eventId, reminder: Reminder(minutes: minutes.longLongValue)))
        } else if (call.method == "deleteReminder") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let eventId = arguments["eventId"] as? String
            result(self.deleteReminder(eventId: eventId!))
            //    } else {
            //        result.notImplemented();
        }
    }

    private func secondsToMinutes(seconds: Int64) -> Int64 {
        return seconds / 60
    }

    private func minutesToSeconds(minutes: Int64) -> TimeInterval {
        return TimeInterval(minutes * 60)
    }


    private func hasPermissions() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        return status == EKAuthorizationStatus.authorized
    }

    private func requestPermissions() {
        eventStore.requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            print("Access Granted")
        })
    }

    private func getCalendars() -> String? {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let ekCalendars = self.eventStore.calendars(for: .event)
        var calendars = [Calendar]()
        for ekCalendar in ekCalendars {
            let calendar = Calendar(id: ekCalendar.calendarIdentifier, name: ekCalendar.title, accountName: "", ownerName: "", isReadOnly: !ekCalendar.allowsContentModifications)
            calendars.append(calendar)
        }
        print("isEmpty", ekCalendars.count)
        let jsonEncoder = JSONEncoder()
        var jsonString = ""
        do {
            let jsonData = try jsonEncoder.encode(calendars)
            jsonString = (String(data: jsonData, encoding: .utf8))!
        } catch {
            print("fetching calendars failed.. ")
        }

        return jsonString
    }

    private func getEvents(calendarId: String) -> String? {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let selectedCalendar = self.eventStore.calendar(withIdentifier: calendarId)
        let startDate = NSDate(timeIntervalSinceNow: -60 * 60 * 24 * 180)
        let endDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 180)
        let predicate = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: [selectedCalendar!])
        let ekEvents = self.eventStore.events(matching: predicate)

        var events = [CalendarEvent]()
        for ekEvent in ekEvents {
            //            NSLog("events.count inside for = %d",  events.count);
            //            NSLog("event = %@",  ekEvent);
            var reminder: Reminder?
            if(ekEvent.hasAlarms) {
                NSLog("HasAlarms: ")
                reminder = Reminder(minutes: self.secondsToMinutes(seconds: Int64(ekEvent.alarms![0].relativeOffset)))
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
        NSLog("events.count = %d", events.count)
        let jsonEncoder = JSONEncoder()
        var jsonString = ""
        do {
            let jsonData = try jsonEncoder.encode(events)
            jsonString = (String(data: jsonData, encoding: .utf8))!
        } catch {
            debugPrint("fetching events failed.. ")
        }

        return jsonString
    }

    private func createUpdateEvent(calendarId: String, event: inout CalendarEvent) {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let eventId = event.eventId
        let title = event.title
        let description = event.description
        let startDate = Date (timeIntervalSince1970: Double(event.startDate) / 1000.0)
        let endDate = Date (timeIntervalSince1970: Double(event.endDate) / 1000.0)
        let reminder = event.reminder

        let ekCalendar = self.eventStore.calendar(withIdentifier: calendarId)
        //        if (!(ekCalendar!.allowsContentModifications)) {
        //            return
        //        }

        var ekEvent: EKEvent?
        if(eventId == nil) {
            ekEvent = EKEvent.init(eventStore: self.eventStore)
        } else {
            ekEvent = self.eventStore.event(withIdentifier: eventId!)
            //            if(ekEvent == nil) {
            //                return
            //            }
        }

        ekEvent!.title = title
        ekEvent!.notes = description
        ekEvent!.startDate = startDate
        ekEvent!.endDate = endDate
        ekEvent!.calendar = ekCalendar!

        if(reminder != nil) {
            let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: 1800, since: Date (timeIntervalSince1970: Double(event.startDate) / 1000.0)))
            ekEvent!.addAlarm(alarm)
        }

        do {
            try self.eventStore.save(ekEvent!, span: .futureEvents)
            event.eventId = ekEvent!.eventIdentifier
        } catch {
            self.eventStore.reset()
        }
    }

    private func deleteEvent(calendarId: String, eventId: String) -> Bool {
        //            let ekCalendar = self.eventStore.calendar(withIdentifier: calendarId)

        //            if (!(ekCalendar!.allowsContentModifications)) {
        //                return
        //            }
        let ekEvent = self.eventStore.event(withIdentifier: eventId)
        //            if (ekEvent == nil) {
        //                return
        //            }

        do {
            try self.eventStore.remove(ekEvent!, span: .futureEvents)
            return true
        } catch {
            self.eventStore.reset()
            return false
        }
    }

    private func addReminder(eventId: String, reminder: Reminder) {
        let ekEvent = self.eventStore.event(withIdentifier: eventId)
        let seconds = self.minutesToSeconds(minutes: reminder.minutes)

        let alarm = EKAlarm.init(relativeOffset: seconds)
        ekEvent!.addAlarm(alarm)

        do {
            try self.eventStore.save(ekEvent!, span: .futureEvents)
        } catch {
            self.eventStore.reset()
        }
    }

    private func updateReminder(eventId: String, reminder: Reminder) -> Bool {
        let response = deleteReminder(eventId: eventId)
        if(!response) {
            return false
        }
        addReminder(eventId: eventId, reminder: reminder)
        return true
    }


    private func deleteReminder(eventId: String) -> Bool {
        let ekEvent = self.eventStore.event(withIdentifier: eventId)
        if(!ekEvent!.hasAlarms) {
            return false
        }
        ekEvent!.removeAlarm(ekEvent!.alarms![0])

        do {
            try self.eventStore.save(ekEvent!, span: .futureEvents)
        } catch {
            self.eventStore.reset()
        }
        return true
    }
}

