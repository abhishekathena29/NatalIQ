import 'package:flutter/material.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/features/community/models/community_comment.dart';

/// Single comment or reply row. Replies (comment.isReply) are indented and
/// never offer their own "Reply" action, capping threads at 2 levels.
class CommentTile extends StatelessWidget {
  final CommunityComment comment;
  final VoidCallback? onReply;

  const CommentTile({super.key, required this.comment, this.onReply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: comment.isReply ? 40 : 0, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialAvatar(
            letter: comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?',
            tone: comment.isReply ? AppTone.sage : AppTone.blush,
            size: comment.isReply ? 26 : 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.authorName, style: sansFont(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(comment.body, style: sansFont(fontSize: 13, height: 1.4)),
                if (!comment.isReply && onReply != null) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onReply,
                    child: Text(
                      'Reply',
                      style: sansFont(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
