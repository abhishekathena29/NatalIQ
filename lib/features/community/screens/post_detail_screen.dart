import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/common.dart';
import 'package:natal_iq/features/community/models/community_comment.dart';
import 'package:natal_iq/features/community/models/community_post.dart';
import 'package:natal_iq/features/community/services/community_service.dart';
import 'package:natal_iq/features/community/widgets/comment_tile.dart';
import 'package:natal_iq/features/community/widgets/like_button.dart';

/// Post + 2-level comment thread, with a sticky bottom composer. Follows the
/// same custom-Scaffold layout as `chat_thread_screen.dart` rather than
/// `MobileShell` since it needs a footer pinned outside the scroll view.
class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _replyToCommentId;
  String? _replyToAuthor;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startReply(CommunityComment comment) {
    setState(() {
      _replyToCommentId = comment.id;
      _replyToAuthor = comment.authorName;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToAuthor = null;
    });
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await CommunityService.addComment(
        postId: widget.postId,
        body: body,
        parentCommentId: _replyToCommentId,
      );
      _controller.clear();
      if (mounted) {
        setState(() {
          _replyToCommentId = null;
          _replyToAuthor = null;
        });
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: appGradientWarm),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.6),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildBody(context)),
                  _buildComposer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background.withValues(alpha: 0.95), AppColors.background.withValues(alpha: 0.7)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => context.canPop() ? context.pop() : context.go('/community'),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.arrowLeft, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Text('Post', style: displayFont(fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<CommunityPost?>(
      stream: CommunityService.watchPost(widget.postId),
      builder: (context, postSnapshot) {
        final post = postSnapshot.data;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            if (post != null) _PostBody(post: post),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppColors.border, height: 1),
            ),
            StreamBuilder<List<CommunityComment>>(
              stream: CommunityService.watchComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final comments = snapshot.data ?? const <CommunityComment>[];
                if (comments.isEmpty) {
                  return Text(
                    'No replies yet. Be the first to respond.',
                    style: sansFont(fontSize: 13, color: AppColors.mutedForeground),
                  );
                }
                final topLevel = comments.where((c) => !c.isReply).toList();
                final repliesByParent = <String, List<CommunityComment>>{};
                for (final c in comments.where((c) => c.isReply)) {
                  repliesByParent.putIfAbsent(c.parentCommentId!, () => []).add(c);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final comment in topLevel) ...[
                      CommentTile(comment: comment, onReply: () => _startReply(comment)),
                      for (final reply in repliesByParent[comment.id] ?? const [])
                        CommentTile(comment: reply),
                    ],
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [AppColors.background, AppColors.background.withValues(alpha: 0.95), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.x3l),
            boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 20, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_replyToAuthor != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Replying to $_replyToAuthor',
                          style: sansFont(fontSize: 11, color: AppColors.mutedForeground),
                        ),
                      ),
                      InkWell(
                        onTap: _cancelReply,
                        child: const Icon(Icons.close, size: 14, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      style: sansFont(fontSize: 14),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: _replyToAuthor != null ? 'Write a reply…' : 'Write a comment…',
                        hintStyle: sansFont(fontSize: 14, color: AppColors.mutedForeground),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(left: 8),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: _sending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryForeground),
                            )
                          : const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.primaryForeground),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  final CommunityPost post;
  const _PostBody({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InitialAvatar(
              letter: post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
              tone: AppTone.peach,
              size: 36,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.authorName, style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                if (post.week != null)
                  Text('Week ${post.week}', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(post.body, style: sansFont(fontSize: 15, height: 1.5)),
        const SizedBox(height: 14),
        Row(
          children: [
            LikeButton(postId: post.id, likeCount: post.likeCount),
            const SizedBox(width: 16),
            const Icon(LucideIcons.messageSquare, size: 14, color: AppColors.mutedForeground),
            const SizedBox(width: 4),
            Text('${post.commentCount}', style: sansFont(fontSize: 12, color: AppColors.mutedForeground)),
          ],
        ),
      ],
    );
  }
}
