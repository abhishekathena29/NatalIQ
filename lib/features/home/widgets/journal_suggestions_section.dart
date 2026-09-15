import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';

/// The "Today for you" Aanya suggestion, shown right under the home hero
/// card. The journal entry point used to live here too — it's now the
/// floating action button on Home instead (see HomeScreen).
class JournalSuggestionsSection extends StatelessWidget {
  const JournalSuggestionsSection({super.key});

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
        ],
      ),
    );
  }
}
