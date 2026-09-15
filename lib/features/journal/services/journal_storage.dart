import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:natal_iq/features/journal/models/journal_entry.dart';

/// Local persistence for journal entries, mirroring [ChatStorage]'s
/// shared_preferences-backed list store.
class JournalStorage {
  JournalStorage._();
  static const _key = 'aanya.journal.entries.v1';
  static const _uuid = Uuid();

  static Future<List<JournalEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final parsed = jsonDecode(raw) as List;
      final entries = parsed.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
      entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return entries;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  static Future<void> upsertEntry(JournalEntry entry) async {
    final all = await loadEntries();
    final idx = all.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      all[idx] = entry;
    } else {
      all.insert(0, entry);
    }
    await _saveEntries(all);
  }

  static Future<JournalEntry?> getEntry(String id) async {
    final all = await loadEntries();
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  static Future<void> deleteEntry(String id) async {
    final all = await loadEntries();
    all.removeWhere((e) => e.id == id);
    await _saveEntries(all);
  }

  static String newEntryId() => _uuid.v4();
}
