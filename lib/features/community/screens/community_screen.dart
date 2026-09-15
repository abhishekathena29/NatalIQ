import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static const _posts = [
    (author: 'Meera', week: 24, body: 'Anyone else struggling with heartburn in the second trimester? What worked for you?', likes: 18, replies: 6),
    (author: 'Anita', week: 32, body: 'First time feeling hiccups in the belly — such a magical moment 💗', likes: 42, replies: 12),
    (author: 'Kavya', week: 12, body: 'Doctor recommended iron supplements. Any tips to avoid nausea from them?', likes: 9, replies: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Community',
      subtitle: 'Kind, moderated, safe',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      'All posts are moderated. Medical advice is verified.',
                      style: sansFont(fontSize: 12, color: AppColors.sageForeground),
                    ),
                  ),
                ],
              ),
            ),
            ..._posts.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InitialAvatar(letter: p.author[0], tone: AppTone.peach, size: 36),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.author, style: sansFont(fontSize: 13, fontWeight: FontWeight.w700)),
                                Text('Week ${p.week}', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(p.body, style: sansFont(fontSize: 14, height: 1.5)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(LucideIcons.heart, size: 14, color: AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text('${p.likes}', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                            const SizedBox(width: 16),
                            const Icon(LucideIcons.messageSquare, size: 14, color: AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text('${p.replies}', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
