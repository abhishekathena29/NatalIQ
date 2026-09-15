import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/router/nav_helpers.dart';
import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/features/home/widgets/journal_suggestions_section.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _quickTiles = [
    (path: '/chat', label: 'Ask Aanya', icon: LucideIcons.messageCircleHeart, tone: AppTone.blush),
    (path: '/quiz', label: 'Symptom check', icon: LucideIcons.clipboardList, tone: AppTone.peach),
    (path: '/track', label: "Today's log", icon: LucideIcons.heartPulse, tone: AppTone.sage),
    (path: '/nap', label: 'Nap timer', icon: LucideIcons.moon, tone: AppTone.peach),
    (path: '/learn', label: 'Learn', icon: LucideIcons.bookOpen, tone: AppTone.blush),
  ];

  static const _modules = [
    (path: '/doctors', label: 'Doctors & experts', icon: LucideIcons.stethoscope, note: 'Verified advice'),
    (path: '/community', label: 'Community', icon: LucideIcons.users, note: 'Peer support'),
    (path: '/videos', label: 'Videos & yoga', icon: LucideIcons.video, note: 'Gentle practice'),
    (path: '/reminders', label: 'Reminders', icon: LucideIcons.bell, note: 'Meds & water'),
    (path: '/caregiver', label: 'Caregiver mode', icon: LucideIcons.handHeart, note: 'For family'),
  ];

  static const _communityPreview = [
    (author: 'Anita', week: 32, body: 'First time feeling hiccups in the belly — such a magical moment 💗', likes: 42, replies: 12),
    (author: 'Meera', week: 24, body: 'Anyone else struggling with heartburn? What worked for you?', likes: 18, replies: 6),
    (author: 'Kavya', week: 12, body: 'Iron supplements + nausea — any tips?', likes: 9, replies: 4),
  ];

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String _trimester(int week) {
    if (week <= 13) return 'FIRST TRIMESTER';
    if (week <= 27) return 'SECOND TRIMESTER';
    return 'THIRD TRIMESTER';
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = AuthService.instance.onboarding;
    final name = onboarding?.name.trim().isNotEmpty == true ? onboarding!.name.trim() : 'there';
    final week = onboarding?.pregnancyWeek ?? 22;
    const totalWeeks = 40;
    final progress = week / totalWeeks;

    return MobileShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(_greeting()),
                    const SizedBox(height: 2),
                    Text(name, style: displayFont(fontSize: 30, fontWeight: FontWeight.w600)),
                  ],
                ),
                InitialAvatar(letter: name[0].toUpperCase(), tone: AppTone.blush, size: 44),
              ],
            ),
          ),

          // Hero card.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowCard, blurRadius: 12, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/hero_mother.jpg',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEEK $week · ${_trimester(week)}',
                            style: sansFont(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your baby is the size of a papaya',
                            style: displayFont(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tiny eyebrows are forming this week. Keep hydrated and take gentle walks.',
                            style: sansFont(
                              fontSize: 13,
                              color: AppColors.mutedForeground,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Week $week', style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground)),
                              Text('Due in ${totalWeeks - week} weeks', style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 8,
                              color: AppColors.muted,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.blush, AppColors.primary],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Journal + today's suggestion, right under the hero card.
          const JournalSuggestionsSection(),

          // Quick tiles.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: _quickTiles.map((t) {
                return AppCard(
                  onTap: () => navigateTo(context, t.path),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ToneIconTile(icon: t.icon, tone: t.tone),
                      const SizedBox(height: 10),
                      Text(t.label, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Tap to open', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Community preview.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionLabel('From the community'),
                      GestureDetector(
                        onTap: () => context.go('/community'),
                        child: Text('See all', style: sansFont(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 20),
                    itemCount: _communityPreview.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final p = _communityPreview[i];
                      return SizedBox(
                        width: 260,
                        child: AppCard(
                          onTap: () => context.go('/community'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InitialAvatar(letter: p.author[0], tone: AppTone.peach, size: 32),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.author, style: sansFont(fontSize: 13, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text('Week ${p.week}', style: sansFont(fontSize: 10, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  p.body,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: sansFont(fontSize: 13, height: 1.4),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(LucideIcons.heart, size: 12, color: AppColors.mutedForeground),
                                  const SizedBox(width: 4),
                                  Text('${p.likes}', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                                  const SizedBox(width: 12),
                                  const Icon(LucideIcons.messageSquare, size: 12, color: AppColors.mutedForeground),
                                  const SizedBox(width: 4),
                                  Text('${p.replies}', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Care circle.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Your care circle'),
                const SizedBox(height: 12),
                ..._modules.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () => navigateTo(context, m.path),
                      child: Row(
                        children: [
                          ToneIconTile(icon: m.icon, tone: AppTone.sage),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.label, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                                Text(m.note, style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text(
              'Aanya offers guidance, not diagnosis. Always consult your doctor for medical decisions.',
              textAlign: TextAlign.center,
              style: sansFont(fontSize: 11, color: AppColors.mutedForeground, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
