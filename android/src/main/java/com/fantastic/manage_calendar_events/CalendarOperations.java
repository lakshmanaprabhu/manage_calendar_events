package com.fantastic.manage_calendar_events;

import android.Manifest.permission;
import android.app.Activity;
import android.content.Context;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract;
import android.provider.CalendarContract.Calendars;
import android.provider.CalendarContract.Events;
import android.util.Log;

import com.fantastic.manage_calendar_events.models.Calendar;
import com.fantastic.manage_calendar_events.models.CalendarEvent;
import com.fantastic.manage_calendar_events.models.CalendarEvent.Reminder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class CalendarOperations {

    private static final int MY_CAL_REQ = 101;
    private static final int MY_CAL_WRITE_REQ = 102;

    private static final String[] EVENT_PROJECTION =
            {
                    CalendarContract.Instances._ID,
                    Events.TITLE,
                    Events.DESCRIPTION,
                    Events.EVENT_LOCATION,
                    Events.CUSTOM_APP_URI,
                    Events.DTSTART,
                    Events.DTEND,
                    Events.ALL_DAY,
                    Events.DURATION,
                    Events.HAS_ALARM,

            };

    private Context ctx;
    private Activity activity;

    public CalendarOperations(Activity activity, Context ctx) {
        this.activity = activity; this.ctx = ctx;
    }


    boolean hasPermissions() {
        if (23 <= android.os.Build.VERSION.SDK_INT && activity != null) {
            boolean writeCalendarPermissionGranted =
                    ctx.checkSelfPermission(permission.WRITE_CALENDAR)
                            == PackageManager.PERMISSION_GRANTED;
            boolean readCalendarPermissionGranted =
                    ctx.checkSelfPermission(permission.READ_CALENDAR)
                            == PackageManager.PERMISSION_GRANTED;

            return writeCalendarPermissionGranted && readCalendarPermissionGranted;
        }

        return true;
    }

    void requestPermissions() {
        if (23 <= android.os.Build.VERSION.SDK_INT && activity != null) {
            String[] permissions = new String[]{permission.WRITE_CALENDAR,
                    permission.READ_CALENDAR};
            activity.requestPermissions(permissions, MY_CAL_REQ);
        }
    }

    public ArrayList<Calendar> getCalendars() {
        ContentResolver cr = ctx.getContentResolver();
        ArrayList<Calendar> calendarList = new ArrayList<>();

        String[] mProjection =
                {
                        Calendars._ID,
                        Calendars.ACCOUNT_NAME,
                        Calendars.CALENDAR_DISPLAY_NAME,
                        Calendars.OWNER_ACCOUNT,
                        Calendars.CALENDAR_ACCESS_LEVEL
                };

        Uri uri = Calendars.CONTENT_URI;

        if (!hasPermissions()) {
            requestPermissions();
        }
        Cursor cur = cr.query(uri, mProjection, null, null, null);

        try {
            while (cur.moveToNext()) {
                String calenderId = cur.getLong(cur.getColumnIndex(Calendars._ID)) + "";
                String displayName = cur
                        .getString(cur.getColumnIndex(Calendars.CALENDAR_DISPLAY_NAME));
                String accountName = cur
                        .getString(cur.getColumnIndex(Calendars.ACCOUNT_NAME));
                String ownerName = cur
                        .getString(cur.getColumnIndex(Calendars.OWNER_ACCOUNT));
                Calendar calendar = new Calendar(calenderId, displayName, accountName, ownerName);
                calendarList.add(calendar);
            }
        } catch (Exception e) {
            Log.e("XXX", e.getMessage());
        } finally {
            cur.close();
        }
        return calendarList;
    }

    public ArrayList<CalendarEvent> getAllEvents(String calendarId) {
        String selection =
                Events.CALENDAR_ID + " = " + calendarId + " AND " + Events.DELETED + " != 1";
        return getEvents(selection);
    }

    public ArrayList<CalendarEvent> getEventsByDateRange(String calendarId, long startDate,
                                                         long endDate) {
        String selection =
                Events.CALENDAR_ID + " = " + calendarId + " AND "
                        + Events.DELETED + " != 1 AND ((" + Events.DTSTART +
                        " >= " + startDate + ") AND (" + Events.DTEND + " <= " + endDate + "))";
        return getEvents(selection);
    }

    /**
     * Return all the events from calendar which satisfies the given query selection
     *
     * @param selection - Conditions to filter the calendar events
     * @return List of Calendar events
     */
    public ArrayList<CalendarEvent> getEvents(String selection) {
        if (!hasPermissions()) {
            requestPermissions();
        }
        ContentResolver cr = ctx.getContentResolver();

        ArrayList<CalendarEvent> calendarEvents = new ArrayList<>();

        Uri uri = Events.CONTENT_URI;
        // String selection =
        //        Events.CALENDAR_ID + " = " + calendarId + " AND " + Events.DELETED + " != 1";
        // String[] selectionArgs = new String[]{"Chennai, Tamilnadu"};
        String eventsSortOrder = Events.DTSTART + " ASC";

        Cursor cur = cr.query(uri, EVENT_PROJECTION, selection, null, eventsSortOrder);

        try {
            while (cur.moveToNext()) {
                String eventId =
                        cur.getLong(cur.getColumnIndex(CalendarContract.Instances._ID)) + "";
                String title = cur.getString(cur.getColumnIndex(Events.TITLE));
                String desc = cur.getString(cur.getColumnIndex(Events.DESCRIPTION));
                String location = cur
                        .getString(cur.getColumnIndex(Events.EVENT_LOCATION));
                String url = cur.getString(cur.getColumnIndex(Events.CUSTOM_APP_URI));
                long startDate =
                        cur.getLong(cur.getColumnIndex(Events.DTSTART));
                long endDate = cur.getLong(cur.getColumnIndex(Events.DTEND));
                long duration = cur.getLong(cur.getColumnIndex(Events.DURATION));
                boolean isAllDay = cur.getInt(cur.getColumnIndex(Events.ALL_DAY)) > 0;
                boolean hasAlarm = cur.getInt(cur.getColumnIndex(Events.HAS_ALARM)) > 0;
                CalendarEvent event = new CalendarEvent(eventId, title, desc, startDate, endDate,
                        location,
                        url,
                        isAllDay, hasAlarm);
                calendarEvents.add(event);
            }
        } catch (Exception e) {
            Log.e("XXX", e.getMessage());
        } finally {
            cur.close();
        }

        updateRemindersAndAttendees(calendarEvents);
        return calendarEvents;
    }

    private CalendarEvent getEvent(String calendarId, String eventId) {
        if (!hasPermissions()) {
            requestPermissions();
        }
        String selection =
                Events.CALENDAR_ID + " = " + calendarId + " AND " + CalendarContract.Instances._ID
                        + " = " + eventId;

        ArrayList<CalendarEvent> events = getEvents(selection);
        assert (events.size() == 1);
        return events.get(0);
    }

    public void createUpdateEvent(String calendarId, CalendarEvent event) {
        if (!hasPermissions()) {
            requestPermissions();
        }

        ContentResolver cr = ctx.getContentResolver();

        String currentTimeZone = java.util.Calendar.getInstance().getTimeZone().getDisplayName();
        String eventId = event.getEventId() != null ? event.getEventId() : null;
        ContentValues values = new ContentValues();
        values.put(Events.DTSTART, event.getStartDate());
        values.put(Events.DTEND, event.getEndDate());
        values.put(Events.TITLE, event.getTitle());
        values.put(Events.DESCRIPTION, event.getDescription());
        values.put(Events.CALENDAR_ID, calendarId);
        values.put(Events.EVENT_TIMEZONE, currentTimeZone);
        values.put(Events.ALL_DAY, event.isAllDay());
        values.put(Events.HAS_ALARM, event.isHasAlarm());
        if (event.getLocation() != null) {
            values.put(Events.EVENT_LOCATION, event.getLocation());
        }
        if (event.getUrl() != null) {
            values.put(Events.CUSTOM_APP_URI, event.getUrl());
        }

        try {
            if (eventId == null) {
                Uri uri = cr.insert(Events.CONTENT_URI, values);
                // get the event ID that is the last element in the Uri
                eventId = Long.parseLong(uri.getLastPathSegment()) + "";
                event.setEventId(eventId);
            } else {
                String selection =
                        Events.CALENDAR_ID + " = " + calendarId + " AND " + CalendarContract.Instances._ID
                                + " = " + eventId;
                int updCount = cr.update(Events.CONTENT_URI, values, selection,
                        null);
            }
        } catch (Exception e) {
            Log.e("XXX", e.getMessage());
        }
    }

    public boolean deleteEvent(String calendarId, String eventId) {
        if (!hasPermissions()) {
            requestPermissions();
        }
        Uri uri = Events.CONTENT_URI;
        String selection =
                Events.CALENDAR_ID + " = " + calendarId + " AND " + CalendarContract.Instances._ID
                        + " = " + eventId;

        int updCount = ctx.getContentResolver().delete(uri, selection, null);
        return updCount != 0;
    }

    private void updateRemindersAndAttendees(ArrayList<CalendarEvent> events) {
        for (CalendarEvent event : events) {
            getReminders(event);
            event.setAttendees(getAttendees(event.getEventId()));
        }
    }

    public List<CalendarEvent.Attendee> getAttendees(String eventId) {
        if (!hasPermissions()) {
            requestPermissions();
        }
        ContentResolver cr = ctx.getContentResolver();

        String[] mProjection =
                {
                        CalendarContract.Attendees.EVENT_ID,
                        CalendarContract.Attendees._ID,
                        CalendarContract.Attendees.ATTENDEE_NAME,
                        CalendarContract.Attendees.ATTENDEE_EMAIL,
                        CalendarContract.Attendees.ATTENDEE_RELATIONSHIP,
                        CalendarContract.Attendees.IS_ORGANIZER,
                };

        Uri uri = CalendarContract.Attendees.CONTENT_URI;
        String selection = CalendarContract.Attendees.EVENT_ID + " = " + eventId;

        Cursor cur = cr.query(uri, mProjection, selection, null, null);
        int cursorSize = cur.getCount();

        Set<CalendarEvent.Attendee> attendees = new HashSet<>();

        CalendarEvent.Attendee organiser = null;
        try {
            while (cur.moveToNext()) {
                String attendeeId =
                        cur.getLong(cur.getColumnIndex(CalendarContract.Attendees._ID)) + "";
                String name =
                        cur.getString(cur.getColumnIndex(CalendarContract.Attendees.ATTENDEE_NAME));
                String emailAddress =
                        cur.getString(cur.getColumnIndex(CalendarContract.Attendees.ATTENDEE_EMAIL));
                int relationship = cur
                        .getInt(cur.getColumnIndex(CalendarContract.Attendees.ATTENDEE_RELATIONSHIP));

                boolean isOrganiser =
                        relationship == CalendarContract.Attendees.RELATIONSHIP_ORGANIZER;

                if (name.isEmpty() && !emailAddress.isEmpty()) {
                    name = capitalize(emailAddress.replaceAll("((@.*)|[^a-zA-Z])+", " ").trim());
                }
                CalendarEvent.Attendee attendee = new CalendarEvent.Attendee(attendeeId, name,
                        emailAddress, isOrganiser);

                if (isOrganiser) {
                    organiser = attendee;
                } else {
                    attendees.add(attendee);
                }
            }
        } catch (Exception e) {
            Log.e("XXX", e.getMessage());
        } finally {
            cur.close();
        }
        ArrayList attendeeList = new ArrayList<>(attendees);
        Collections.sort(attendeeList, new Comparator<CalendarEvent.Attendee>() {
            @Override
            public int compare(CalendarEvent.Attendee o1, CalendarEvent.Attendee o2) {
                return o1.getEmailAddress().compareTo(o2.getEmailAddress());
            }
        });
        if (organiser != null && !attendeeList.isEmpty())
            attendeeList.add(0, organiser);

        if (cursorSize != attendeeList.size()) {
            deleteAllAttendees(eventId);
            addAttendees(eventId, attendeeList);
        }
        return attendeeList;
    }

    private String capitalize(final String line) {
        return Character.toUpperCase(line.charAt(0)) + line.substring(1);
    }

    public void addAttendees(String eventId,
                             List<CalendarEvent.Attendee> attendees) {
        if (!hasPermissions()) {
            requestPermissions();
        }
        if (attendees.isEmpty()) {
            return;
        }

        ContentResolver cr = ctx.getContentResolver();
        ContentValues[] valuesArray = new ContentValues[attendees.size()];

        for (int i = 0, attendeesSize = attendees.size(); i < attendeesSize; i++) {
            CalendarEvent.Attendee attendee = attendees.get(i);
            ContentValues values = new ContentValues();
            values.put(CalendarContract.Attendees.EVENT_ID, eventId);
            values.put(CalendarContract.Attendees.ATTENDEE_NAME, attendee.getName());
            values.put(CalendarContract.Attendees.ATTENDEE_EMAIL, attendee.getEmailAddress());
            values.put(CalendarContract.Attendees.ATTENDEE_RELATIONSHIP,
                    attendee.isOrganiser() ? CalendarContract.Attendees.RELATIONSHIP_ORGANIZER :
                            CalendarContract.Attendees.RELATIONSHIP_ATTENDEE);

            valuesArray[i] = values;
        }
        cr.bulkInsert(CalendarContract.Attendees.CONTENT_URI, valuesArray);
    }

    public int deleteAttendee(String eventId,
                              CalendarEvent.Attendee attendee) {
        if (!hasPermissions()) {
            requestPermissions();
        }

        Uri uri = CalendarContract.Attendees.CONTENT_URI;
        String selection =
                CalendarContract.Attendees.EVENT_ID + " = " + eventId
                        + " AND " + CalendarContract.Attendees.ATTENDEE_EMAIL
                        + " = '" + attendee.getEmailAddress() + "'";

        int updCount = ctx.getContentResolver().delete(uri, selection, null);
        return updCount;
    }

    private int deleteAllAttendees(String eventId) {
        if (!hasPermissions()) {
            requestPermissions();
        }

        Uri uri = CalendarContract.Attendees.CONTENT_URI;
        String selection = CalendarContract.Attendees.EVENT_ID + " = " + eventId;

        int updCount = ctx.getContentResolver().delete(uri, selection, null);
        return updCount;
    }

    private void getReminders(CalendarEvent event) {
        String eventId = event.getEventId();
        if (!hasPermissions()) {
            requestPermissions();
        }
        ContentResolver cr = ctx.getContentResolver();

        String[] mProjection =
                {
                        CalendarContract.Reminders.EVENT_ID,
                        CalendarContract.Reminders.METHOD,
                        CalendarContract.Reminders.MINUTES,
                };

        Uri uri = CalendarContract.Reminders.CONTENT_URI;
        String selection = CalendarContract.Reminders.EVENT_ID + " = " + eventId;
//        String[] selectionArgs = new String[]{"2"};

        Cursor cur = cr.query(uri, mProjection, selection, null, null);

        try {
            while (cur.moveToNext()) {
                long minutes = cur.getLong(cur.getColumnIndex(CalendarContract.Reminders.MINUTES));
                Reminder reminder = new CalendarEvent.Reminder(minutes);
                event.setReminder(reminder);
            }
        } catch (Exception e) {
            Log.e("XXX", e.getMessage());
        } finally {
            cur.close();
        }

    }

    public void addReminder(String calendarId, String eventId, long minutes) {
        if (!hasPermissions()) {
            requestPermissions();
        }

        CalendarEvent event = getEvent(calendarId, eventId);

        ContentResolver cr = ctx.getContentResolver();
        ContentValues values = new ContentValues();

        values.put(CalendarContract.Reminders.EVENT_ID, event.getEventId());
        values.put(CalendarContract.Reminders.MINUTES, minutes);
        values.put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALARM);

        cr.insert(CalendarContract.Reminders.CONTENT_URI, values);

        event.setHasAlarm(true);
    }

    public int updateReminder(String calendarId, String eventId, long minutes) {
        if (!hasPermissions()) {
            requestPermissions();
        }
        CalendarEvent event = getEvent(calendarId, eventId);

        ContentValues contentValues = new ContentValues();
        contentValues.put(CalendarContract.Reminders.MINUTES, minutes);

        Uri uri = CalendarContract.Reminders.CONTENT_URI;

        String selection = CalendarContract.Reminders.EVENT_ID + " = " + event.getEventId();
        int updCount = ctx.getContentResolver()
                .update(uri, contentValues, selection, null);
        return updCount;
    }

    public int deleteReminder(String eventId) {
        if (!hasPermissions()) {
            requestPermissions();
        }

        Uri uri = CalendarContract.Reminders.CONTENT_URI;
        String selection = CalendarContract.Reminders.EVENT_ID + " = " + eventId;

        int updCount = ctx.getContentResolver().delete(uri, selection, null);
        return updCount;
    }

}
