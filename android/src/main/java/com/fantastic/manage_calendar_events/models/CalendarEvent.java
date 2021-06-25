package com.fantastic.manage_calendar_events.models;

import android.os.Build;

import androidx.annotation.RequiresApi;

import com.google.gson.annotations.SerializedName;

import java.util.List;
import java.util.Objects;

public final class CalendarEvent {

  @SerializedName("eventId")
  private String eventId;
  @SerializedName("title")
  private String title;
  @SerializedName("description")
  private String description;
  @SerializedName("startDate")
  private long startDate;
  @SerializedName("endDate")
  private long endDate;
  @SerializedName("location")
  private String location;
  @SerializedName("url")
  private String url;
  @SerializedName("duration")
  private long duration;
  @SerializedName("isAllDay")
  private boolean isAllDay;
  @SerializedName("hasAlarm")
  private boolean hasAlarm;
  @SerializedName("reminder")
  private Reminder reminder;

  @SerializedName("attendees")
  private List<Attendee> attendees;

  public CalendarEvent(String eventId, String title, String description, long startDate,
      long endDate,
      String location, String url, boolean isAllDay, boolean hasAlarm) {
    this.eventId = eventId;
    this.title = title;
    this.description = description;
    this.startDate = startDate;
    this.endDate = endDate;
    this.location = location;
    this.url = url;
    this.isAllDay = isAllDay;
    this.hasAlarm = hasAlarm;
  }

  public String getEventId() {
    return eventId;
  }

  public void setEventId(String eventId) {
    this.eventId = eventId;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public long getStartDate() {
    return startDate;
  }

  public void setStartDate(long startDate) {
    this.startDate = startDate;
  }

  public long getEndDate() {
    return endDate;
  }

  public void setEndDate(long endDate) {
    this.endDate = endDate;
  }

  public String getLocation() {
    return location;
  }

  public void setLocation(String location) {
    this.location = location;
  }

  public String getUrl() {
      return url;
  }

  public void setUrl(String url) {
      this.url = url;
  }

  public long getDuration() {
    return duration;
  }

  public void setDuration(long duration) {
    this.duration = duration;
  }

  public boolean isAllDay() {
    return isAllDay;
  }

  public void setAllDay(boolean allDay) {
    isAllDay = allDay;
  }

  public boolean isHasAlarm() {
    return hasAlarm;
  }

  public void setHasAlarm(boolean hasAlarm) {
    this.hasAlarm = hasAlarm;
  }

  public Reminder getReminder() {
    return reminder;
  }

  public void setReminder(Reminder reminder) {
    this.reminder = reminder;
  }

  public void setAttendees(List<Attendee> attendees) {
    this.attendees = attendees;
  }

  @Override
  public String toString() {
    return eventId + "-" + title + "-" + description + "-" + startDate + "-" + endDate + "-"
        + location + "-"
        + duration + "-"
        + hasAlarm;
  }

  public static class Reminder {

    @SerializedName("minutes")
    private final long minutes;

    public Reminder(long minutes) {
      this.minutes = minutes;
    }

    public long getMinutes() {
      return minutes;
    }

    @Override
    public String toString() {
      return "Minutes - " + minutes;
    }
  }

  final public static class Attendee {
    @SerializedName("id")
    private final String id;

    @SerializedName("name")
    private final String name;

    @SerializedName("emailAddress")
    private final String emailAddress;

    @SerializedName("isOrganiser")
    private final boolean isOrganiser;

    public Attendee(String name, String emailAddress, boolean isOrganiser) {
      this(null, name, emailAddress, isOrganiser);
    }
    public Attendee(String id, String name, String emailAddress, boolean isOrganiser) {
      this.id = id;
      this.name = name;
      this.emailAddress = emailAddress;
      this.isOrganiser = isOrganiser;
    }

    public String getId() {
      return id;
    }

    public String getName() {
      return name;
    }

    public String getEmailAddress() {
      return emailAddress;
    }

    public boolean isOrganiser() {
      return isOrganiser;
    }

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;
      Attendee attendee = (Attendee) o;
      return isOrganiser == attendee.isOrganiser &&
              name.equals(attendee.name) &&
              emailAddress.equals(attendee.emailAddress);
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    public int hashCode() {
      return Objects.hash(name, emailAddress, isOrganiser);
    }

    @Override
    public String toString() {
      return "Attendee{" +
              "id='" + id + '\'' +
              ", name='" + name + '\'' +
              ", emailAddress='" + emailAddress + '\'' +
              ", isOrganiser=" + isOrganiser +
              '}';
    }
  }
}
