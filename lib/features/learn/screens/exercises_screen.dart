import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/learn/data/exercises_data.dart';

/// List of gentle, general prenatal exercises. Tapping one opens a guided,
/// step-by-step practice screen.
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Exercises',
      subtitle: 'Gentle movement, practised safely',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.4),
                border: Border.all(color: AppColors.sage),
                borderRadius: BorderRadius.circular(AppRadius.x2l),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.sageForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'General wellness guidance, not medical advice. Check with your doctor before starting or continuing any exercise routine.',
                      style: sansFont(fontSize: 12, color: AppColors.sageForeground),
                    ),
                  ),
                ],
              ),
            ),
            for (final exercise in kExercises)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () => context.push('/learn/exercises/${exercise.id}'),
                  child: Row(
                    children: [
                      ToneIconTile(icon: exercise.icon, tone: AppTone.sage),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exercise.title, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              '${exercise.durationLabel} · ${exercise.trimesterNote}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sansFont(fontSize: 11, color: AppColors.mutedForeground),
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
      ),
    );
  }
}
