import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/learn/models/learn_module.dart';
import 'package:natal_iq/features/learn/services/learn_content_service.dart';

const _takeawayPrefixes = [
  'Gentle takeaway:',
  'Quick takeaway:',
  'The myth:',
  'The fact:',
  'Why people believe it:',
  'What is more accurate:',
  'Keep it kind:',
];

/// Full content for a single lesson: body paragraphs, key points, any extra
/// callouts (examples, "try this now" prompts), and sources.
class LearnLessonScreen extends StatelessWidget {
  final String moduleId;
  final String lessonId;
  const LearnLessonScreen({super.key, required this.moduleId, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LearnModule?>(
      future: LearnContentService.loadModule(moduleId),
      builder: (context, snapshot) {
        final module = snapshot.data;
        LearnLesson? lesson;
        if (module != null) {
          for (final l in module.lessons) {
            if (l.id == lessonId) {
              lesson = l;
              break;
            }
          }
        }

        return MobileShell(
          title: lesson?.title ?? 'Lesson',
          subtitle: module?.title,
          child: lesson == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final para in lesson.body) ...[
                        _LessonParagraph(text: para),
                        const SizedBox(height: 12),
                      ],
                      if (lesson.keyPoints.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _Callout(
                          icon: LucideIcons.lightbulb,
                          tone: AppTone.sage,
                          heading: 'What this means for you',
                          items: lesson.keyPoints,
                        ),
                        const SizedBox(height: 16),
                      ],
                      for (final extra in lesson.extras) ...[
                        _Callout(
                          icon: LucideIcons.sparkles,
                          tone: AppTone.peach,
                          heading: extra.heading,
                          items: extra.items,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (lesson.sources.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SectionLabel('Sources reviewed'),
                        const SizedBox(height: 8),
                        for (final source in lesson.sources)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              source,
                              style: sansFont(fontSize: 11, color: AppColors.mutedForeground, height: 1.4),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _LessonParagraph extends StatelessWidget {
  final String text;
  const _LessonParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
    for (final prefix in _takeawayPrefixes) {
      if (text.startsWith(prefix)) {
        final rest = text.substring(prefix.length);
        return RichText(
          text: TextSpan(
            style: sansFont(fontSize: 14, height: 1.6, color: AppColors.foreground),
            children: [
              TextSpan(text: prefix, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.6)),
              TextSpan(text: rest),
            ],
          ),
        );
      }
    }
    if (text.startsWith('• ')) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text('•  ${text.substring(2)}', style: sansFont(fontSize: 14, height: 1.6)),
      );
    }
    return Text(text, style: sansFont(fontSize: 14, height: 1.6));
  }
}

class _Callout extends StatelessWidget {
  final IconData icon;
  final AppTone tone;
  final String heading;
  final List<String> items;

  const _Callout({required this.icon, required this.tone, required this.heading, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppRadius.x2l),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tone.foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading,
                  style: sansFont(fontSize: 13, fontWeight: FontWeight.w700, color: tone.foreground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '•  $item',
                style: sansFont(fontSize: 13, height: 1.5, color: tone.foreground),
              ),
            ),
        ],
      ),
    );
  }
}
