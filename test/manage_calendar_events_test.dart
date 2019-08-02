import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

void main() {
  const MethodChannel channel = MethodChannel('manage_calendar_events');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CalendarPlugin.platformVersion, '42');
  });
}
