import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:natal_iq/features/learn/models/learn_module.dart';

/// Loads the Learn section's lesson content from the bundled JSON asset
/// (generated from the Natal IQ App Research document), caching it in memory
/// for the life of the app.
class LearnContentService {
  LearnContentService._();

  static List<LearnModule>? _cached;

  static Future<List<LearnModule>> loadModules() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/data/learn_content.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cached = decoded.map((e) => LearnModule.fromJson(e as Map<String, dynamic>)).toList();
    return _cached!;
  }

  static Future<LearnModule?> loadModule(String moduleId) async {
    final modules = await loadModules();
    for (final m in modules) {
      if (m.id == moduleId) return m;
    }
    return null;
  }
}
