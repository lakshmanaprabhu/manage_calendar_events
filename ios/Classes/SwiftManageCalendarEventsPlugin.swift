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
        let title: String?
        let description: String?
        let startDate: Int64
        let endDate: Int64
        let location: String?
        let isAllDay: Bool
        let hasAlarm: Bool
        let url: String?
        var reminder: Reminder?
        let attendees: [Attendee]?
    }

    struct Reminder: Codable {
        let minutes: Int64
    }

    struct Attendee: Codable {
        let name: String?
        let emailAddress: String?
        let isOrganiser: Bool
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
            result(self.getAllEvents(calendarId: calendarId))
        } else if (call.method == "getEventsByDateRange") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let calendarId = arguments["calendarId"] as! String
            let startDate = arguments["startDate"] as! Int64
            let endDate = arguments["endDate"] as! Int64
            result(self.getEventsByDateRange(calendarId: calendarId, startDate: startDate, endDate: endDate))
        } else if ((call.method == "createEvent") || (call.method == "updateEvent")) {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let calendarId = arguments["calendarId"] as! String
            let eventId = arguments["eventId"] as? String
            let title = arguments["title"] as! String
            let description = arguments["description"] as! String
            let startDate = arguments["startDate"] as! Int64
            let endDate = arguments["endDate"] as! Int64
            let location = arguments["location"] as? String
            let isAllDay = arguments["isAllDay"] as! Bool
            let hasAlarm = arguments["hasAlarm"] as! Bool
            let url = arguments["url"] as? String
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
                url: url,
                reminder: reminder,
                attendees: []
            )
            self.createUpdateEvent(calendarId: calendarId, event: &event)
            if arguments["attendees"] as? NSObject != NSNull() {
                self.addAttendees(eventId: event.eventId!, arguments: arguments)
            }
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
        } else if(call.method == "getAttendees") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let eventId = arguments["eventId"] as? String

            let attendees = self.getAttendees(eventId: eventId!)

            let jsonEncoder = JSONEncoder()
            var attendeesJson = ""
            do {
                let jsonData = try jsonEncoder.encode(attendees)
                attendeesJson = (String(data: jsonData, encoding: .utf8))!
            } catch {
                debugPrint("fetching attendees failed.. ")
            }

            result(attendeesJson)
        } else if(call.method == "addAttendees") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let eventId = arguments["eventId"] as! String

            self.addAttendees(eventId: eventId, arguments: arguments)
        } else if(call.method == "deleteAttendee") {
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let eventId = arguments["eventId"] as! String

            self.deleteAttendees(eventId: eventId, arguments: arguments)
        }
//        else {
//            result.notImplemented()
//        }
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
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: {
                granted, error in
                    print("Access granted")
            })
        } else {
            // Fallback on earlier versions
            eventStore.requestAccess(to: .event, completion: {
                (accessGranted: Bool, error: Error?) in
                print("Access Granted")
            })
        }
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

    private func getAllEvents(calendarId: String) -> String? {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let selectedCalendar = self.eventStore.calendar(withIdentifier: calendarId)
        let startDate = NSDate(timeIntervalSinceNow: -60 * 60 * 24 * 180)
        let endDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 180)
        if (selectedCalendar != nil) {
            let predicate = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: [selectedCalendar!])

            return getEvents(predicate: predicate)
        }
        return "[]"
    }

    private func getEventsByDateRange(calendarId: String, startDate: Int64, endDate: Int64) -> String? {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let selectedCalendar = self.eventStore.calendar(withIdentifier: calendarId)
        let startDate = Date (timeIntervalSince1970: Double(startDate) / 1000.0)
        let endDate = Date (timeIntervalSince1970: Double(endDate) / 1000.0)
        if (selectedCalendar != nil) {
            let predicate = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: [selectedCalendar!])

            return getEvents(predicate: predicate)
        }
        return "[]"
    }

    private func getEvents(predicate: NSPredicate) -> String? {
        let ekEvents = self.eventStore.events(matching: predicate)

        var events = [CalendarEvent]()
        for ekEvent in ekEvents {
            //            NSLog("events.count inside for = %d",  events.count);
            //            NSLog("event = %@",  ekEvent);

            var reminder: Reminder?
            if(ekEvent.hasAlarms) {
                reminder = Reminder(minutes: self.secondsToMinutes(seconds: Int64(ekEvent.alarms![0].relativeOffset)))
            }

            var attendees = [Attendee]()
            if (ekEvent.hasAttendees) {
                attendees = getAttendees(eventId: ekEvent.eventIdentifier)
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
                url: ekEvent.url?.absoluteString,
                reminder: reminder,
                attendees: attendees
            )
            events.append(event)
        }
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
        let location = event.location
        let isAllDay = event.isAllDay
        let url = event.url

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
        ekEvent!.isAllDay = isAllDay

        if(location != nil) {
            ekEvent!.location = location
        }

        if(url != nil) {
            ekEvent!.url = URL(string: url ?? "")
        }


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
        let ekEvent = self.eventStore.event(withIdentifier: eventId)

        do {
            try self.eventStore.remove(ekEvent!, span: .futureEvents)
            return true
        } catch {
            self.eventStore.reset()
            return false
        }
    }

    private func getAttendees(eventId: String) -> [Attendee] {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let ekEvent = self.eventStore.event(withIdentifier: eventId)
        if (!ekEvent!.hasAttendees) {
            return []
        }

        let attendeesList = ekEvent!.attendees
        var attendees = [Attendee]()
        var organiser: Attendee?
        for attendeeElement in attendeesList! {
            let isOrganiser = ekEvent!.organizer?.emailAddress == attendeeElement.emailAddress!

            let existingAttendee = attendees.first { element in
                return element.emailAddress == attendeeElement.emailAddress
            }
            if existingAttendee != nil && isOrganiser {
                continue
            }

            let attendee = Attendee(name: attendeeElement.name, emailAddress: attendeeElement.emailAddress!, isOrganiser: isOrganiser)
            if(isOrganiser) {
                organiser = attendee
            } else {
                attendees.append(attendee)
            }
        }
        attendees = attendees.sorted { ($0.name == nil ? "" : $0.name!) < ($1.name == nil ? "" : $1.name!) }

        if organiser != nil && !attendees.isEmpty {
            attendees.insert(organiser!, at: 0)
        }
        return attendees
    }

    private func addAttendees(eventId: String, arguments: Dictionary<String, AnyObject>) {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let ekEvent = self.eventStore.event(withIdentifier: eventId)
        let attendeesArguments = arguments["attendees"] as! NSArray
        var attendees = Set<EKParticipant>()

        for attendeeArg in attendeesArguments {
            let attendeeMap = attendeeArg as! Dictionary<String, AnyObject>
            let emailAddress = attendeeMap["emailAddress"] as! String
            let name = attendeeMap["name"] as! String
            let isOrganiser = attendeeMap["isOrganiser"] as! Bool


            let attendee = self.createEKParticipant(name: name, emailAddress: emailAddress, isOrganiser: isOrganiser)

            if(attendee == nil) {
                continue
            }

            attendees.insert(attendee!)
        }

        // include existing attendees to the new list (to avoid override)
        if (ekEvent!.hasAttendees) {
            let attendeesList = ekEvent!.attendees
            for attendeeElement in attendeesList! {
                let existingAttendee = attendees.first { element in
                    return element.emailAddress == attendeeElement.emailAddress
                }
                if existingAttendee != nil {
                    if ekEvent!.organizer?.emailAddress == attendeeElement.emailAddress {
                        attendees.insert(existingAttendee!)
                    }
                    continue
                }

                let attendee = self.createEKParticipant(name: attendeeElement.name!, emailAddress: attendeeElement.emailAddress!, isOrganiser: attendeeElement.isCurrentUser)

                if(attendee == nil) {
                    continue
                }

                attendees.insert(attendee!)
            }
        }

        ekEvent!.setValue(Array(attendees), forKey: "attendees")

        do {
            try self.eventStore.save(ekEvent!, span: .futureEvents)
        } catch {
            self.eventStore.reset()
        }
    }

    private func createEKParticipant(name: String, emailAddress: String, isOrganiser: Bool) -> EKParticipant? {
        let attendeeClasss: AnyClass? = NSClassFromString("EKAttendee")
        if let type = attendeeClasss as? NSObject.Type {
            let attendee = type.init()
            attendee.setValue(name, forKey: "displayName")
            attendee.setValue(emailAddress, forKey: "emailAddress")

            return attendee as? EKParticipant
        }
        return nil
    }

    private func deleteAttendees(eventId: String, arguments: Dictionary<String, AnyObject>) {
        if(!hasPermissions()) {
            requestPermissions()
        }
        let attendeesMap = arguments["attendee"] as! Dictionary<String, AnyObject>
        let ekEvent = self.eventStore.event(withIdentifier: eventId)

        if !(ekEvent!.hasAttendees) {
            return
        }
        let emailAddress = attendeesMap["emailAddress"] as! String

        var attendees = ekEvent!.attendees!
        let foundIndex = attendees.firstIndex { element in
            return element.emailAddress == emailAddress
        }
        if foundIndex == nil {
            return
        }
        attendees.remove(at: foundIndex!)

        ekEvent!.setValue(attendees, forKey: "attendees")

        do {
            try self.eventStore.save(ekEvent!, span: .futureEvents)
        } catch {
            self.eventStore.reset()
        }
    }

    private func addReminder(eventId: String, reminder: Reminder) {
        if(!hasPermissions()) {
            requestPermissions()
        }
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
        if(!hasPermissions()) {
            requestPermissions()
        }
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

extension EKParticipant {
    var emailAddress: String? {
        return self.value(forKey: "emailAddress") as? String
    }
    var isOrganiser: Bool? {
        return self.value(forKey: "isOrganiser") as? Bool
    }
}


