import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:natal_iq/features/nap/models/nap_session.dart';
import 'package:natal_iq/features/nap/services/nap_notifications.dart';
import 'package:natal_iq/features/nap/services/nap_storage.dart';

/// The App Group shared between the app and the iOS NapWidget extension.
/// Must match the group id configured on both Xcode targets — see
/// ios/NapWidget/README.md.
const napWidgetAppGroupId = 'group.com.example.natalIq.nap';

const _androidWidgetProviderName = 'NapWidgetProvider';
const _iosWidgetName = 'NapWidget';

/// Tracks the in-progress nap (if any), same `ChangeNotifier` singleton shape
/// as [AuthService]. Persists the running session's start time immediately so
/// an app kill mid-nap doesn't lose it, and mirrors status to the Android/iOS
/// home screen widgets via `home_widget` on every change.
class NapTimerService extends ChangeNotifier {
  NapTimerService._();
  static final NapTimerService instance = NapTimerService._();

  static const _kRunningStart = 'aanya.nap.running.startMillis.v1';

  NapSession? _running;

  NapSession? get running => _running;
  bool get isRunning => _running != null;
  Duration get elapsed => _running == null ? Duration.zero : DateTime.now().difference(_running!.startTime);

  Future<void> init() async {
    HomeWidget.setAppGroupId(napWidgetAppGroupId);
    final prefs = await SharedPreferences.getInstance();
    final startMillis = prefs.getInt(_kRunningStart);
    if (startMillis != null) {
      _running = NapSession(id: NapStorage.newSessionId(), startTime: DateTime.fromMillisecondsSinceEpoch(startMillis));
      await _pushWidgetUpdate();
    }
  }

  Future<void> start() async {
    if (_running != null) return;
    final now = DateTime.now();
    _running = NapSession(id: NapStorage.newSessionId(), startTime: now);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRunningStart, now.millisecondsSinceEpoch);
    notifyListeners();
    await _pushWidgetUpdate();
    unawaited(NapNotifications.instance.scheduleStillNappingReminder(now));
  }

  Future<void> stop({String? note}) async {
    final running = _running;
    if (running == null) return;
    final finished = running.copyWith(endTime: DateTime.now(), note: note);
    await NapStorage.addSession(finished);
    _running = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRunningStart);
    notifyListeners();
    await _pushWidgetUpdate();
    unawaited(NapNotifications.instance.cancelReminder());
  }

  Future<void> _pushWidgetUpdate() async {
    await HomeWidget.saveWidgetData<bool>('nap_is_running', isRunning);
    await HomeWidget.saveWidgetData<String>('nap_start_iso', _running?.startTime.toIso8601String());
    await HomeWidget.updateWidget(androidName: _androidWidgetProviderName, iOSName: _iosWidgetName);
  }
}
