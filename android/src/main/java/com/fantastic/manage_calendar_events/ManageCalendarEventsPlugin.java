package com.fantastic.manage_calendar_events;

import android.app.Activity;
import android.content.Context;

import com.fantastic.manage_calendar_events.models.Calendar;
import com.fantastic.manage_calendar_events.models.CalendarEvent;
import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ManageCalendarEventsPlugin
 */
public class ManageCalendarEventsPlugin implements MethodCallHandler {

    private final MethodChannel methodChannel;
    private final CalendarOperations operations;
    private final Gson gson = new Gson();

    public ManageCalendarEventsPlugin(MethodChannel methodChannel, CalendarOperations operations) {
        this.methodChannel = methodChannel;
        this.methodChannel.setMethodCallHandler(this);

        this.operations = operations;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        Context context = registrar.context();
        Activity activity = registrar.activity();


        CalendarOperations CalendarOperations = new CalendarOperations(activity, context);

        final MethodChannel channel = new MethodChannel(registrar.messenger(),
                "manage_calendar_events");
        channel.setMethodCallHandler(new ManageCalendarEventsPlugin(channel, CalendarOperations));

        // registrar.addRequestPermissionsResultListener(CalendarOperations);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("hasPermissions")) {
            result.success(operations.hasPermissions());
        } else if (call.method.equals("requestPermissions")) {
            operations.requestPermissions();
        } else if (call.method.equals("getCalendars")) {
            ArrayList<Calendar> calendarArrayList = operations.getCalendars();
            result.success(gson.toJson(calendarArrayList));
        } else if (call.method.equals("getEvents")) {
            String calendarId = call.argument("calendarId");
            result.success(gson.toJson(operations.getAllEvents(calendarId)));
        } else if (call.method.equals("getEventsByDateRange")) {
            String calendarId = call.argument("calendarId");
            long startDate = call.argument("startDate");
            long endDate = call.argument("endDate");
            result.success(gson.toJson(operations.getEventsByDateRange(calendarId, startDate,
                    endDate)));
        } else if (call.method.equals("createEvent") || call.method.equals("updateEvent")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            String title = call.argument("title");
            String description = call.argument("description");
            long startDate = call.argument("startDate");
            long endDate = call.argument("endDate");
            String location = call.argument("location");
            String url = call.argument("url");
            boolean isAllDay = call.argument("isAllDay");
            boolean hasAlarm = call.argument("hasAlarm");
            CalendarEvent event = new CalendarEvent(eventId, title, description, startDate,
                    endDate, location, url, isAllDay, hasAlarm);
            operations.createUpdateEvent(calendarId, event);
            if (call.hasArgument("attendees")) {
                addAttendees(event.getEventId(), call);
            }
            result.success(event.getEventId());
        } else if (call.method.equals("deleteEvent")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            result.success(operations.deleteEvent(calendarId, eventId));
        } else if (call.method.equals("addReminder")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            long minutes = Long.parseLong(call.<String>argument("minutes"));
            operations.addReminder(calendarId, eventId, minutes);
        } else if (call.method.equals("updateReminder")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            long minutes = Long.parseLong(call.<String>argument("minutes"));
            result.success(operations.updateReminder(calendarId, eventId, minutes));
        } else if (call.method.equals("deleteReminder")) {
            String eventId = call.argument("eventId");
            result.success(operations.deleteReminder(eventId));
        } else if (call.method.equals("getAttendees")) {
            String eventId = call.argument("eventId");
            result.success(gson.toJson(operations.getAttendees(eventId)));
        } else if (call.method.equals("addAttendees")) {
            String eventId = call.argument("eventId");
            addAttendees(eventId, call);
        } else if (call.method.equals("deleteAttendee")) {
            String eventId = call.argument("eventId");
            Map<String, Object> attendeeMap = call.argument("attendee");
            String name = (String) attendeeMap.get("name");
            String emailAddress = (String) attendeeMap.get("emailAddress");
            boolean isOrganiser = attendeeMap.get("isOrganiser") != null ?
                    (boolean) attendeeMap.get("isOrganiser") : false;
            CalendarEvent.Attendee attendee = new CalendarEvent.Attendee(name, emailAddress,
                    isOrganiser);
            result.success(operations.deleteAttendee(eventId, attendee));
        } else {
            result.notImplemented();
        }
    }

    private void addAttendees(String eventId, MethodCall call) {
        List<CalendarEvent.Attendee> attendees = new ArrayList<>();
        List<Map<String, Object>> jsonList = call.argument("attendees");
        for (Map<String, Object> map : jsonList) {
            String name = (String) map.get("name");
            String emailAddress = (String) map.get("emailAddress");
            boolean isOrganiser = (boolean) map.get("isOrganiser");
            attendees.add(new CalendarEvent.Attendee(name, emailAddress, isOrganiser));
        }
        operations.addAttendees(eventId, attendees);
    }

}
