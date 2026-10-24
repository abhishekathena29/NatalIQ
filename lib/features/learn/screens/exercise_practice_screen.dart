import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/learn/data/exercises_data.dart';
import 'package:natal_iq/features/learn/models/exercise.dart';

/// Guided, step-by-step practice flow for one exercise — lets a user "play
/// through" the steps one at a time rather than just reading a list.
class ExercisePracticeScreen extends StatefulWidget {
  final String exerciseId;
  const ExercisePracticeScreen({super.key, required this.exerciseId});

  @override
  State<ExercisePracticeScreen> createState() => _ExercisePracticeScreenState();
}

class _ExercisePracticeScreenState extends State<ExercisePracticeScreen> {
  int _stepIndex = 0;
  bool _finished = false;

  Exercise? get _exercise {
    for (final e in kExercises) {
      if (e.id == widget.exerciseId) return e;
    }
    return null;
  }

  void _next(Exercise exercise) {
    if (_stepIndex < exercise.steps.length - 1) {
      setState(() => _stepIndex++);
    } else {
      setState(() => _finished = true);
    }
  }

  void _back() {
    if (_stepIndex > 0) setState(() => _stepIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;
    return MobileShell(
      title: exercise?.title ?? 'Exercise',
      subtitle: exercise == null
          ? null
          : (_finished ? 'Complete' : 'Step ${_stepIndex + 1} of ${exercise.steps.length}'),
      child: exercise == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: _finished ? _CompletionCard(exercise: exercise) : _StepCard(
                  exercise: exercise,
                  stepIndex: _stepIndex,
                  onBack: _stepIndex > 0 ? _back : null,
                  onNext: () => _next(exercise),
                ),
            ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final Exercise exercise;
  final int stepIndex;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _StepCard({required this.exercise, required this.stepIndex, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isLast = stepIndex == exercise.steps.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (stepIndex + 1) / exercise.steps.length,
            minHeight: 6,
            backgroundColor: AppColors.muted,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ToneIconTile(icon: exercise.icon, tone: AppTone.sage, size: 64, iconSize: 30),
        ),
        const SizedBox(height: 20),
        Text(
          exercise.steps[stepIndex],
          textAlign: TextAlign.center,
          style: displayFont(fontSize: 19, height: 1.5),
        ),
        if (stepIndex == 0) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.peach.withValues(alpha: 0.4),
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.x2l),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.triangleAlert, size: 14, color: AppColors.peachForeground),
                    const SizedBox(width: 6),
                    Text('Before you start', style: sansFont(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.peachForeground)),
                  ],
                ),
                const SizedBox(height: 8),
                for (final caution in exercise.cautions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('•  $caution', style: sansFont(fontSize: 12, color: AppColors.peachForeground, height: 1.4)),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            if (onBack != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.x2l)),
                  ),
                  child: Text('Back', style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: onBack != null ? 1 : 2,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.x2l)),
                ),
                child: Text(isLast ? 'Finish' : 'Next', style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final Exercise exercise;
  const _CompletionCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
            child: const Icon(LucideIcons.check, size: 34, color: AppColors.sageForeground),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text('Nice work!', style: displayFont(fontSize: 22, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            "You've finished ${exercise.title.toLowerCase()}.",
            textAlign: TextAlign.center,
            style: sansFont(fontSize: 13, color: AppColors.mutedForeground),
          ),
        ),
        const SizedBox(height: 24),
        SectionLabel('Why it helps'),
        const SizedBox(height: 10),
        for (final benefit in exercise.benefits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.heart, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(benefit, style: sansFont(fontSize: 13, height: 1.4))),
              ],
            ),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.x2l)),
            ),
            child: Text('Done', style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
