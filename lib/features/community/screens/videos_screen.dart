import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  static const _videos = [
    (title: 'Prenatal yoga: 10-min gentle flow', tag: 'Yoga', time: '10 min', tone: AppTone.sage),
    (title: 'Breathing for calm mornings', tag: 'Mindfulness', time: '6 min', tone: AppTone.peach),
    (title: 'What happens in the 3rd trimester', tag: 'Explainer', time: '8 min', tone: AppTone.blush),
    (title: 'Foods to include this week', tag: 'Nutrition', time: '5 min', tone: AppTone.sage),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Videos',
      subtitle: 'Gentle practice for every day',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _videos.map((v) {
            final gradient = v.tone == AppTone.sage
                ? appGradientSage
                : v.tone == AppTone.blush
                    ? appGradientBlush
                    : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.x2l),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 128,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        color: gradient == null ? v.tone.background : null,
                      ),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.card.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 20, offset: Offset(0, 4))],
                        ),
                        child: const Icon(LucideIcons.play, size: 20, color: AppColors.primary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.tag.toUpperCase(), style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1.1)),
                          const SizedBox(height: 2),
                          Text(v.title, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.clock, size: 12, color: AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(v.time, style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
