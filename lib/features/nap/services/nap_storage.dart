import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:natal_iq/features/nap/models/nap_session.dart';

/// Local persistence for finished nap sessions, mirroring [JournalStorage]'s
/// shared_preferences-backed list store. The in-progress session (if any)
/// lives separately in [NapTimerService], not here.
class NapStorage {
  NapStorage._();
  static const _key = 'aanya.nap.sessions.v1';
  static const _uuid = Uuid();

  static Future<List<NapSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final parsed = jsonDecode(raw) as List;
      final sessions = parsed.map((e) => NapSession.fromJson(e as Map<String, dynamic>)).toList();
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveSessions(List<NapSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(sessions.map((e) => e.toJson()).toList()));
  }

  static Future<void> addSession(NapSession session) async {
    final all = await loadSessions();
    all.insert(0, session);
    await _saveSessions(all);
  }

  static Future<void> deleteSession(String id) async {
    final all = await loadSessions();
    all.removeWhere((e) => e.id == id);
    await _saveSessions(all);
  }

  static String newSessionId() => _uuid.v4();
}
