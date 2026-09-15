import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/features/journal/models/journal_entry.dart';
import 'package:natal_iq/features/journal/models/journal_insight.dart';

/// Local, on-device reflection engine for journal entries — the same
/// no-network, keyword-driven posture as [AanyaAi], just applied to
/// journaling instead of chat. No API key, no backend, works offline.
class JournalInsightsEngine {
  JournalInsightsEngine._();

  static const _fallback = JournalInsight(
    headline: 'Thank you for writing this down',
    body: 'Putting feelings into words is its own kind of self-care. Come back whenever you need to.',
  );

  static final List<(List<String>, JournalInsight)> _keywordInsights = [
    (
      ['tired', 'exhaust', 'fatigue', 'sleepy', 'no energy'],
      const JournalInsight(
        headline: "It's okay to rest",
        body: 'Fatigue is common and your body is working hard. Try a short nap or an early night — rest really is medicine right now.',
        icon: LucideIcons.moon,
        tone: AppTone.blush,
      ),
    ),
    (
      ['anxious', 'worry', 'scared', 'nervous', 'stress'],
      const JournalInsight(
        headline: "You're not alone in feeling this",
        body: 'A little worry is normal, but if it keeps weighing on you, talking it through — with Aanya or your doctor — can help.',
        icon: LucideIcons.heartHandshake,
        tone: AppTone.peach,
      ),
    ),
    (
      ['pain', 'cramp', 'ache', 'hurts'],
      const JournalInsight(
        headline: "Keep an eye on that",
        body: "Mild, occasional discomfort can be normal, but if it's severe or doesn't ease with rest, please check in with your doctor.",
        icon: LucideIcons.stethoscope,
        tone: AppTone.blush,
      ),
    ),
    (
      ['happy', 'excited', 'joy', 'grateful', 'love'],
      const JournalInsight(
        headline: 'Hold on to this feeling',
        body: 'Moments like this are worth savoring. Consider sharing it with your care circle — good news is meant to be shared.',
        icon: LucideIcons.sparkles,
        tone: AppTone.sage,
      ),
    ),
    (
      ['sad', 'down', 'cry', 'lonely', 'overwhelm'],
      const JournalInsight(
        headline: 'Be gentle with yourself today',
        body: "Some days are heavier than others, and that's okay. If this feeling lingers, please reach out to someone you trust or your doctor.",
        icon: LucideIcons.heart,
        tone: AppTone.blush,
      ),
    ),
  ];

  static final Map<JournalMood, JournalInsight> _moodInsights = {
    JournalMood.happy: const JournalInsight(headline: 'Lovely to hear', body: 'Moments of joy add up — thank you for capturing this one.', icon: LucideIcons.sparkles, tone: AppTone.sage),
    JournalMood.calm: const JournalInsight(headline: 'A calm moment, noted', body: 'Peaceful days are worth remembering too. Keep doing what grounds you.', icon: LucideIcons.leaf, tone: AppTone.sage),
    JournalMood.tired: const JournalInsight(headline: "It's okay to rest", body: 'Listen to your body today — a short nap or an early night can go a long way.', icon: LucideIcons.moon, tone: AppTone.blush),
    JournalMood.anxious: const JournalInsight(headline: "You're not alone in feeling this", body: 'If the worry keeps building, talking it through with Aanya or your doctor can help.', icon: LucideIcons.heartHandshake, tone: AppTone.peach),
    JournalMood.sad: const JournalInsight(headline: 'Be gentle with yourself today', body: "It's okay to have heavier days. Reach out to someone you trust if you need to.", icon: LucideIcons.heart, tone: AppTone.blush),
  };

  /// Reflection for a single just-saved entry: keyword match first (more
  /// specific), falling back to the entry's chosen mood, then a generic note.
  static JournalInsight forEntry(JournalEntry entry) {
    final text = '${entry.title} ${entry.body}'.toLowerCase();
    for (final (keywords, insight) in _keywordInsights) {
      if (keywords.any(text.contains)) return insight;
    }
    if (entry.mood != null) return _moodInsights[entry.mood]!;
    return _fallback;
  }

  /// Looks back over recent entries (already sorted newest-first by
  /// [JournalStorage]) for a mood trend. Returns null when there isn't
  /// enough history yet to say anything meaningful.
  static JournalInsight? weeklyReflection(List<JournalEntry> recentEntries) {
    final withMood = recentEntries.take(7).where((e) => e.mood != null).toList();
    if (withMood.length < 2) return null;

    final counts = <JournalMood, int>{};
    for (final e in withMood) {
      counts[e.mood!] = (counts[e.mood!] ?? 0) + 1;
    }
    final dominant = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final dominantShare = dominant.value / withMood.length;
    if (dominantShare < 0.5) {
      return const JournalInsight(
        headline: "This week's mix",
        body: "Your moods have been varied this week — that's completely normal. Keep checking in with yourself.",
        icon: LucideIcons.calendarHeart,
        tone: AppTone.sage,
      );
    }

    switch (dominant.key) {
      case JournalMood.anxious:
      case JournalMood.sad:
        return JournalInsight(
          headline: "You've had a heavier week",
          body: "You've noted feeling ${dominant.key.label.toLowerCase()} in most of your recent entries. Consider a chat with Aanya, a short walk, or reaching out to your doctor.",
          icon: LucideIcons.heartHandshake,
          tone: AppTone.peach,
        );
      case JournalMood.tired:
        return const JournalInsight(
          headline: 'A tiring stretch',
          body: "You've mentioned feeling tired often this week. Try to protect time for rest where you can.",
          icon: LucideIcons.moon,
          tone: AppTone.blush,
        );
      case JournalMood.happy:
      case JournalMood.calm:
        return JournalInsight(
          headline: 'A good week overall',
          body: "You've mostly felt ${dominant.key.label.toLowerCase()} lately — lovely to see. Keep noticing what's working for you.",
          icon: LucideIcons.sparkles,
          tone: AppTone.sage,
        );
    }
  }
}
