import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/community/models/community_post.dart';
import 'package:natal_iq/features/community/services/community_service.dart';
import 'package:natal_iq/features/community/widgets/post_card.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      title: 'Community',
      subtitle: 'Kind, moderated, safe',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/community/compose'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        child: const Icon(LucideIcons.plus),
      ),
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
                      'Be kind — this is a peer support space, not medical advice.',
                      style: sansFont(fontSize: 12, color: AppColors.sageForeground),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<CommunityPost>>(
              stream: CommunityService.watchPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final posts = snapshot.data ?? const <CommunityPost>[];
                if (posts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No posts yet. Be the first to share something.',
                        textAlign: TextAlign.center,
                        style: sansFont(fontSize: 13, color: AppColors.mutedForeground),
                      ),
                    ),
                  );
                }
                return Column(
                  children: posts
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PostCard(
                              post: p,
                              bodyMaxLines: 6,
                              onTap: () => context.push('/community/${p.id}'),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
