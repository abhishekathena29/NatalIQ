import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import 'package:natal_iq/features/chat/models/chat_message.dart';
import 'package:natal_iq/features/chat/services/chat_storage.dart';
import 'package:natal_iq/features/chat/services/groq_ai_service.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/shimmer_text.dart';

const _uuid = Uuid();

const _suggestions = [
  'What foods should I avoid this trimester?',
  'Is mild cramping in week 22 normal?',
  'How much water should I drink daily?',
  'Gentle exercises safe for me right now?',
];

/// Port of `src/routes/chat.$threadId.tsx`. Replies come from
/// `GroqAiService`, which calls Groq's chat completions API using a key/model
/// fetched from Firestore, falling back to a small local stand-in
/// (`AanyaAi`) if that's unavailable — the screen, persistence, and
/// turn-taking flow otherwise match the original 1:1.
class ChatThreadScreen extends StatefulWidget {
  final String threadId;
  final String? seedQuestion;

  const ChatThreadScreen({super.key, required this.threadId, this.seedQuestion});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

enum _Status { ready, submitted, streaming }

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _messages = <ChatMessage>[];
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  final _scrollController = ScrollController();
  _Status _status = _Status.ready;
  bool _error = false;
  bool _loadedFromStorage = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ChatThreadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId) {
      _messages.clear();
      _loadedFromStorage = false;
      _load();
    }
  }

  Future<void> _load() async {
    final existing = await ChatStorage.getThread(widget.threadId);
    if (!mounted) return;
    setState(() {
      _messages.addAll(existing?.messages ?? const []);
      _loadedFromStorage = true;
    });
    if (_messages.isEmpty && widget.seedQuestion != null && widget.seedQuestion!.trim().isNotEmpty) {
      _send(widget.seedQuestion!.trim());
    }
    _inputFocus.requestFocus();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isLoading => _status == _Status.submitted || _status == _Status.streaming;

  Future<void> _persist() async {
    final existing = await ChatStorage.getThread(widget.threadId);
    await ChatStorage.upsertThread(ChatThread(
      id: widget.threadId,
      title: existing?.title != null && existing!.title != 'New conversation'
          ? existing.title
          : ChatStorage.deriveTitle(_messages),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      messages: List.of(_messages),
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    setState(() {
      _error = false;
      _messages.add(ChatMessage(id: _uuid.v4(), role: ChatRole.user, text: text.trim()));
      _status = _Status.submitted;
    });
    await _persist();
    _scrollToBottom();

    try {
      final reply = await GroqAiService.reply(_messages);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(id: _uuid.v4(), role: ChatRole.assistant, text: reply));
        _status = _Status.ready;
      });
      await _persist();
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _status = _Status.ready;
      });
    }
  }

  void _handleSubmit() {
    final text = _inputController.text;
    _inputController.clear();
    _send(text);
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
              onTap: () => context.canPop() ? context.pop() : context.go('/'),
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
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.blush, shape: BoxShape.circle),
              child: const Icon(LucideIcons.messageCircleHeart, size: 16, color: AppColors.blushForeground),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Aanya', style: sansFont(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('Guidance, not diagnosis', style: sansFont(fontSize: 11, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!_loadedFromStorage) return const SizedBox.shrink();
    if (_messages.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: _messages.length + (_status == _Status.submitted ? 1 : 0) + (_error ? 1 : 0),
      itemBuilder: (context, i) {
        if (i < _messages.length) return _MessageBubble(message: _messages[i]);
        if (_status == _Status.submitted && i == _messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ShimmerText('Aanya is thinking…', style: sansFont(fontSize: 14, color: AppColors.mutedForeground)),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('Something went wrong. Please try again.', style: sansFont(fontSize: 12, color: AppColors.destructive)),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(AppRadius.x2l),
                boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 20, offset: Offset(0, 4))],
              ),
              child: const Icon(LucideIcons.messageCircleHeart, size: 32, color: AppColors.blushForeground),
            ),
            const SizedBox(height: 24),
            Text("Hello, I'm Aanya", style: displayFont(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              "Your gentle pregnancy companion. Ask me anything — I'm here to listen.",
              textAlign: TextAlign.center,
              style: sansFont(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
            ),
            const SizedBox(height: 24),
            SectionLabelSmall('Try asking'),
            const SizedBox(height: 8),
            ..._suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.x2l),
                    onTap: () => _send(s),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.x2l),
                      ),
                      child: Text(s, textAlign: TextAlign.left, style: sansFont(fontSize: 14)),
                    ),
                  ),
                )),
          ],
        ),
      ),
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
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.x3l),
            boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 20, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                enabled: !_isLoading,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: sansFont(fontSize: 14),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Ask Aanya…',
                  hintStyle: sansFont(fontSize: 14, color: AppColors.mutedForeground),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder(
                valueListenable: _inputController,
                builder: (context, value, _) {
                  final canSubmit = value.text.trim().isNotEmpty && !_isLoading;
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: canSubmit ? _handleSubmit : null,
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: canSubmit ? AppColors.primary : AppColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mutedForeground),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              size: 16,
                              color: canSubmit ? AppColors.primaryForeground : AppColors.mutedForeground,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionLabelSmall extends StatelessWidget {
  final String text;
  const SectionLabelSmall(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: sansFont(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.mutedForeground, letterSpacing: 1.1),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: isUser ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10) : EdgeInsets.zero,
              decoration: isUser
                  ? BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(6),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    )
                  : null,
              child: Text(
                message.text,
                style: sansFont(
                  fontSize: 14,
                  height: 1.5,
                  color: isUser ? AppColors.primaryForeground : AppColors.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
