import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/features/community/services/community_service.dart';

/// Heart icon + live like count for a single post, backed by
/// [CommunityService.watchIsLiked]/[CommunityService.toggleLike].
class LikeButton extends StatefulWidget {
  final String postId;
  final int likeCount;
  final double iconSize;

  const LikeButton({super.key, required this.postId, required this.likeCount, this.iconSize = 14});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await CommunityService.toggleLike(widget.postId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: CommunityService.watchIsLiked(widget.postId),
      builder: (context, snapshot) {
        final liked = snapshot.data ?? false;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  liked ? Icons.favorite : LucideIcons.heart,
                  size: widget.iconSize,
                  color: liked ? AppColors.primary : AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.likeCount}',
                  style: sansFont(
                    fontSize: widget.iconSize < 14 ? 11 : 12,
                    color: liked ? AppColors.primary : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
