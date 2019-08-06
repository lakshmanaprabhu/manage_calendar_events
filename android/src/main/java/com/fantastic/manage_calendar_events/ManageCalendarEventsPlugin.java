package com.fantastic.manage_calendar_events;

import android.app.Activity;
import android.content.Context;

import com.fantastic.manage_calendar_events.models.Calendar;
import com.fantastic.manage_calendar_events.models.CalendarEvent;
import com.google.gson.Gson;

import java.util.ArrayList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ManageCalendarEventsPlugin
 */
public class ManageCalendarEventsPlugin implements MethodCallHandler {

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        Context context = registrar.context();
        Activity activity = registrar.activity();

        CalendarOperations CalendarOperations = new CalendarOperations(activity);

        final MethodChannel channel = new MethodChannel(registrar.messenger(),
                "manage_calendar_events");
        channel.setMethodCallHandler(new ManageCalendarEventsPlugin(channel, CalendarOperations));

        // registrar.addRequestPermissionsResultListener(CalendarOperations);
    }


    private final MethodChannel methodChannel;
    private final CalendarOperations operations;

    private final Gson gson = new Gson();

    public ManageCalendarEventsPlugin(MethodChannel methodChannel, CalendarOperations operations) {
        this.methodChannel = methodChannel;
        this.methodChannel.setMethodCallHandler(this);

        this.operations = operations;
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
            result.success(gson.toJson(operations.getEvents(calendarId)));
        } else if (call.method.equals("createEvent") || call.method.equals("updateEvent")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            String title = call.argument("title");
            String description = call.argument("description");
            long startDate = call.argument("startDate");
            long endDate = call.argument("endDate");
            String location = call.argument("location");
            boolean isAllDay = call.argument("isAllDay");
            boolean hasAlarm = call.argument("hasAlarm");
            CalendarEvent event = new CalendarEvent(eventId, title, description, startDate,
                    endDate, location, isAllDay, hasAlarm);
            operations.createUpdateEvent(calendarId, event);
            result.success(event.getEventId());
        } else if (call.method.equals("deleteEvent")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            result.success(operations.deleteEvent(calendarId, eventId));
        } else if (call.method.equals("addReminder")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            operations.addReminder(calendarId, eventId);
        } else if (call.method.equals("updateReminder")) {
            String calendarId = call.argument("calendarId");
            String eventId = call.argument("eventId");
            result.success(operations.updateReminder(calendarId, eventId));
        } else if (call.method.equals("deleteReminder")) {
            String eventId = call.argument("eventId");
            result.success(operations.deleteReminder(eventId));
        } else {
            result.notImplemented();
        }
    }

}
