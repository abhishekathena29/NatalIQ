import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/mobile_shell.dart';
import 'package:natal_iq/features/community/models/community.dart';
import 'package:natal_iq/features/community/models/community_post.dart';
import 'package:natal_iq/features/community/services/community_service.dart';
import 'package:natal_iq/features/community/widgets/join_button.dart';
import 'package:natal_iq/features/community/widgets/post_card.dart';

/// One community's own post feed, with a join/leave header and a compose FAB.
class CommunityFeedScreen extends StatelessWidget {
  final String communityId;
  const CommunityFeedScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Community?>(
      stream: CommunityService.watchCommunity(communityId),
      builder: (context, communitySnapshot) {
        final community = communitySnapshot.data;
        return MobileShell(
          title: community?.name ?? 'Community',
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/community/$communityId/compose'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            child: const Icon(LucideIcons.plus),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (community != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (community.description.isNotEmpty)
                              Text(
                                community.description,
                                style: sansFont(fontSize: 13, color: AppColors.mutedForeground, height: 1.4),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              '${community.memberCount} ${community.memberCount == 1 ? 'member' : 'members'}',
                              style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      JoinButton(communityId: communityId),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                ],
                StreamBuilder<List<CommunityPost>>(
                  stream: CommunityService.watchPosts(communityId: communityId),
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
                                  onTap: () => context.push('/community/$communityId/post/${p.id}'),
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
      },
    );
  }
}
