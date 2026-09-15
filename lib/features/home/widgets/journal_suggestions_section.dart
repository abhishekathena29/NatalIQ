import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/features/journal/models/journal_insight.dart';
import 'package:natal_iq/features/journal/services/journal_insights.dart';
import 'package:natal_iq/features/journal/services/journal_storage.dart';

/// Combines the "Today for you" Aanya suggestion with the journal entry
/// point into one scannable block, shown right under the home hero card —
/// replaces what used to be two separate cards further down the page.
class JournalSuggestionsSection extends StatefulWidget {
  const JournalSuggestionsSection({super.key});

  @override
  State<JournalSuggestionsSection> createState() => _JournalSuggestionsSectionState();
}

class _JournalSuggestionsSectionState extends State<JournalSuggestionsSection> {
  JournalInsight? _journalInsight;

  @override
  void initState() {
    super.initState();
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    final entries = await JournalStorage.loadEntries();
    if (!mounted || entries.isEmpty) return;
    final insight = JournalInsightsEngine.weeklyReflection(entries) ?? JournalInsightsEngine.forEntry(entries.first);
    setState(() => _journalInsight = insight);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              const SectionLabel('Today for you'),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.x2l),
            onTap: () => context.go('/chat'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.peach.withValues(alpha: 0.6),
                    AppColors.blush.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ASK AANYA', style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Text('"Is it safe to eat papaya during pregnancy?"', style: displayFont(fontSize: 19, height: 1.3)),
                  const SizedBox(height: 12),
                  Text('Tap to start', style: sansFont(fontSize: 11, color: AppColors.foreground.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.x2l),
            onTap: () => context.push('/journal'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadowCard, blurRadius: 12, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  ToneIconTile(icon: _journalInsight?.icon ?? LucideIcons.bookHeart, tone: _journalInsight?.tone ?? AppTone.sage),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Journal', style: sansFont(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          _journalInsight?.headline ?? "Write down today's thoughts and feelings",
                          style: sansFont(fontSize: 12, color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
