import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:natal_iq/features/chat/models/chat_message.dart';

/// Local persistence for chat threads, mirroring `src/lib/chat-storage.ts`'s
/// localStorage-backed thread store.
class ChatStorage {
  ChatStorage._();
  static const _key = 'aanya.chat.threads.v1';
  static const _uuid = Uuid();

  static Future<List<ChatThread>> loadThreads() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final parsed = jsonDecode(raw) as List;
      final threads = parsed
          .map((t) => ChatThread.fromJson(t as Map<String, dynamic>))
          .toList();
      threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return threads;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveThreads(List<ChatThread> threads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(threads.map((t) => t.toJson()).toList()));
  }

  static Future<void> upsertThread(ChatThread thread) async {
    final all = await loadThreads();
    final idx = all.indexWhere((t) => t.id == thread.id);
    if (idx >= 0) {
      all[idx] = thread;
    } else {
      all.insert(0, thread);
    }
    await _saveThreads(all);
  }

  static Future<ChatThread?> getThread(String id) async {
    final all = await loadThreads();
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  static String newThreadId() => _uuid.v4();

  static String deriveTitle(List<ChatMessage> messages) {
    final firstUser = messages.where((m) => m.role == ChatRole.user).toList();
    if (firstUser.isEmpty) return 'New conversation';
    final text = firstUser.first.text.trim();
    if (text.isEmpty) return 'New conversation';
    return text.length > 42 ? '${text.substring(0, 42)}…' : text;
  }
}
