/// A labelled block within a lesson besides the main body — e.g. "Example: a
/// flexible protein day" or "Try this now: the 60-second reset" — rendered as
/// its own callout with a bullet list.
class LearnExtra {
  final String heading;
  final List<String> items;

  const LearnExtra({required this.heading, required this.items});

  factory LearnExtra.fromJson(Map<String, dynamic> json) => LearnExtra(
        heading: json['heading'] as String,
        items: (json['items'] as List).cast<String>(),
      );
}

class LearnLesson {
  final String id;
  final int number;
  final String title;
  final List<String> body;
  final List<String> keyPoints;
  final List<String> sources;
  final List<LearnExtra> extras;

  const LearnLesson({
    required this.id,
    required this.number,
    required this.title,
    required this.body,
    required this.keyPoints,
    required this.sources,
    required this.extras,
  });

  factory LearnLesson.fromJson(Map<String, dynamic> json) => LearnLesson(
        id: json['id'] as String,
        number: json['number'] as int,
        title: json['title'] as String,
        body: (json['body'] as List).cast<String>(),
        keyPoints: (json['keyPoints'] as List).cast<String>(),
        sources: (json['sources'] as List).cast<String>(),
        extras: (json['extras'] as List)
            .map((e) => LearnExtra.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LearnModule {
  final String id;
  final String title;
  final List<LearnLesson> lessons;

  const LearnModule({required this.id, required this.title, required this.lessons});

  factory LearnModule.fromJson(Map<String, dynamic> json) => LearnModule(
        id: json['id'] as String,
        title: json['title'] as String,
        lessons: (json['lessons'] as List)
            .map((e) => LearnLesson.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
