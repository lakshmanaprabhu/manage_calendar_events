#import "ManageCalendarEventsPlugin.h"
#import <manage_calendar_events/manage_calendar_events-Swift.h>

@implementation ManageCalendarEventsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftManageCalendarEventsPlugin registerWithRegistrar:registrar];
}
@end
