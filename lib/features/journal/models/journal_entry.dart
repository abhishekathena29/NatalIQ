enum JournalMood { happy, calm, tired, anxious, sad }

extension JournalMoodX on JournalMood {
  String get emoji => switch (this) {
        JournalMood.happy => '😊',
        JournalMood.calm => '😌',
        JournalMood.tired => '😴',
        JournalMood.anxious => '😟',
        JournalMood.sad => '😢',
      };

  String get label => switch (this) {
        JournalMood.happy => 'Happy',
        JournalMood.calm => 'Calm',
        JournalMood.tired => 'Tired',
        JournalMood.anxious => 'Anxious',
        JournalMood.sad => 'Sad',
      };
}

class JournalEntry {
  final String id;
  final String title;
  final String body;
  final JournalMood? mood;
  final int createdAt;
  final int updatedAt;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({String? title, String? body, JournalMood? mood, int? updatedAt}) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      mood: mood ?? this.mood,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'mood': mood?.name,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        mood: (json['mood'] as String?) != null
            ? JournalMood.values.firstWhere((m) => m.name == json['mood'], orElse: () => JournalMood.calm)
            : null,
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int,
      );
}
