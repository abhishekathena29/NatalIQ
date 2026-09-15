import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:natal_iq/features/chat/models/chat_message.dart';
import 'package:natal_iq/features/chat/services/aanya_ai.dart';

const _systemPrompt =
    "You are Aanya, a warm, encouraging pregnancy and postpartum companion "
    "inside the natal_iq app. Keep replies short (2-4 sentences), gentle, "
    "and non-diagnostic — you offer guidance, not medical diagnosis. For "
    "anything severe, urgent, or outside general wellness advice, encourage "
    "the user to contact their doctor.";

/// Groq-backed replies for Aanya. The API key and model are stored in
/// Firestore (`config/aanya`) rather than hardcoded, per product decision —
/// fetched once per session and cached. Falls back to the local [AanyaAi]
/// canned responses whenever the config is missing or the request fails, so
/// the chat never hard-errors.
class GroqAiService {
  GroqAiService._();

  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  static ({String apiKey, String model})? _cachedConfig;

  static Future<({String apiKey, String model})?> _loadConfig() async {
    if (_cachedConfig != null) return _cachedConfig;
    try {
      final doc = await FirebaseFirestore.instance.collection('config').doc('aanya').get();
      final data = doc.data();
      final apiKey = data?['groqApiKey'] as String?;
      final model = data?['groqModel'] as String?;
      if (apiKey == null || apiKey.isEmpty || model == null || model.isEmpty) return null;
      _cachedConfig = (apiKey: apiKey, model: model);
      return _cachedConfig;
    } catch (_) {
      return null;
    }
  }

  static Future<String> reply(List<ChatMessage> history) async {
    final fallbackPrompt = history.isNotEmpty ? history.last.text : '';
    final config = await _loadConfig();
    if (config == null) return AanyaAi.reply(fallbackPrompt);

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer ${config.apiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': config.model,
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                ...history.map((m) => {
                      'role': m.role == ChatRole.user ? 'user' : 'assistant',
                      'content': m.text,
                    }),
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return await AanyaAi.reply(fallbackPrompt);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return await AanyaAi.reply(fallbackPrompt);
      final message = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      final trimmed = content?.trim();
      if (trimmed == null || trimmed.isEmpty) return await AanyaAi.reply(fallbackPrompt);
      return trimmed;
    } catch (_) {
      return AanyaAi.reply(fallbackPrompt);
    }
  }
}
