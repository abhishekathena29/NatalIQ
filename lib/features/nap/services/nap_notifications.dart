import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around flutter_local_notifications for the single
/// "Still napping?" check-in reminder — not a general notification system.
class NapNotifications {
  NapNotifications._();
  static final NapNotifications instance = NapNotifications._();

  static const _reminderId = 9001;
  static const _reminderDelay = Duration(hours: 2);

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(settings: const InitializationSettings(android: androidInit, iOS: iosInit));
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _ready = true;
  }

  Future<void> scheduleStillNappingReminder(DateTime startedAt) async {
    await _ensureReady();
    final fireAt = tz.TZDateTime.from(startedAt.add(_reminderDelay), tz.local);
    if (fireAt.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Still napping?',
      body: "It's been a couple of hours — just checking in on your nap.",
      scheduledDate: fireAt,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nap_reminders',
          'Nap reminders',
          channelDescription: 'A gentle check-in when a nap has run long',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder() => _plugin.cancel(id: _reminderId);
}
