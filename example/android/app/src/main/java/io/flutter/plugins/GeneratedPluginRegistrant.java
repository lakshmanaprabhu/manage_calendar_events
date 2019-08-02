package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import in.fantastic.manage_calendar_events.ManageCalendarEventsPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    ManageCalendarEventsPlugin.registerWith(registry.registrarFor("in.fantastic.manage_calendar_events.ManageCalendarEventsPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
