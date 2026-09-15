import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:natal_iq/features/chat/models/chat_message.dart';
import 'package:natal_iq/features/chat/services/chat_storage.dart';
import 'package:natal_iq/core/theme/app_theme.dart';

/// Port of `src/routes/chat.index.tsx` — creates a fresh thread and replaces
/// the route with `/chat/:threadId`, showing a brief "Opening chat…" beat.
class ChatEntryScreen extends StatefulWidget {
  const ChatEntryScreen({super.key});

  @override
  State<ChatEntryScreen> createState() => _ChatEntryScreenState();
}

class _ChatEntryScreenState extends State<ChatEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _createAndGo());
  }

  Future<void> _createAndGo() async {
    final id = ChatStorage.newThreadId();
    await ChatStorage.upsertThread(ChatThread(
      id: id,
      title: 'New conversation',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      messages: const [],
    ));
    if (mounted) context.pushReplacement('/chat/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('Opening chat…', style: sansFont(fontSize: 14, color: AppColors.mutedForeground)),
      ),
    );
  }
}
