import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/widgets.dart' show IconData;

import 'package:natal_iq/core/theme/app_theme.dart';

class JournalInsight {
  final String headline;
  final String body;
  final IconData icon;
  final AppTone tone;

  const JournalInsight({
    required this.headline,
    required this.body,
    this.icon = LucideIcons.sparkles,
    this.tone = AppTone.sage,
  });
}
