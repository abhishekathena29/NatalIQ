import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const _trimesters = [
    (n: 1, weeks: '1–13', title: 'First trimester', body: 'Big changes, tiny beginnings.', tone: AppTone.blush),
    (n: 2, weeks: '14–27', title: 'Second trimester', body: 'Energy returns. Feel the flutters.', tone: AppTone.peach),
    (n: 3, weeks: '28–40', title: 'Third trimester', body: 'Preparing to meet your baby.', tone: AppTone.sage),
  ];

  static const _modules = [
    (title: 'Nutrition & diet', icon: LucideIcons.apple, tag: '12 lessons'),
    (title: 'Common conditions', icon: LucideIcons.heartPulse, tag: 'Anemia · GDM · Preeclampsia'),
    (title: 'Baby development', icon: LucideIcons.baby, tag: 'Week by week'),
    (title: 'Mental well-being', icon: LucideIcons.brain, tag: 'Calm & connect'),
    (title: 'Doctor visits', icon: LucideIcons.shield, tag: 'What to expect'),
    (title: 'Myths vs facts', icon: LucideIcons.sparkles, tag: '8 quick reads'),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Learn',
      subtitle: 'Simple, trusted, kind',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: SectionLabel('Trimesters'),
          ),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _trimesters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final t = _trimesters[i];
                return Container(
                  width: 208,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: t.tone.background,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.x2l),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKS ${t.weeks}',
                        style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: t.tone.foreground.withValues(alpha: 0.7), letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(t.title, style: displayFont(fontSize: 17, color: t.tone.foreground)),
                      const SizedBox(height: 6),
                      Text(t.body, style: sansFont(fontSize: 12, color: t.tone.foreground.withValues(alpha: 0.8))),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('Modules', padding: const EdgeInsets.only(bottom: 12)),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: _modules.map((m) {
                    return AppCard(
                      onTap: () => context.go('/chat'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ToneIconTile(icon: m.icon, tone: AppTone.peach),
                          const SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              m.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sansFont(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              m.tag,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: sansFont(fontSize: 11, color: AppColors.mutedForeground),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
