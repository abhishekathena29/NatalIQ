import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/features/community/models/community_post.dart';
import 'package:natal_iq/features/community/widgets/like_button.dart';

/// Shared post-card UI used by the full Community list and Home's
/// horizontal "From the community" preview.
class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final int bodyMaxLines;

  const PostCard({super.key, required this.post, this.onTap, this.bodyMaxLines = 2});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InitialAvatar(
                letter: post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                tone: AppTone.peach,
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sansFont(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    if (post.week != null) ...[
                      const SizedBox(height: 2),
                      Text('Week ${post.week}', style: sansFont(fontSize: 10, color: AppColors.mutedForeground)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.body,
            maxLines: bodyMaxLines,
            overflow: TextOverflow.ellipsis,
            style: sansFont(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              LikeButton(postId: post.id, likeCount: post.likeCount, iconSize: 12),
              const SizedBox(width: 12),
              const Icon(LucideIcons.messageSquare, size: 12, color: AppColors.mutedForeground),
              const SizedBox(width: 4),
              Text('${post.commentCount}', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}
