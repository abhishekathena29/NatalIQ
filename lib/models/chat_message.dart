enum ChatRole { user, assistant }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String text;

  const ChatMessage({required this.id, required this.role, required this.text});

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: (json['role'] as String) == 'user' ? ChatRole.user : ChatRole.assistant,
        text: json['text'] as String,
      );
}

class ChatThread {
  final String id;
  final String title;
  final int updatedAt;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.messages,
  });

  ChatThread copyWith({String? title, int? updatedAt, List<ChatMessage>? messages}) {
    return ChatThread(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] as String,
        title: json['title'] as String,
        updatedAt: json['updatedAt'] as int,
        messages: (json['messages'] as List)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
