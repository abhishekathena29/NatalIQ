class NapSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String? note;

  const NapSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.note,
  });

  bool get isRunning => endTime == null;

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);

  NapSession copyWith({DateTime? endTime, String? note}) => NapSession(
        id: id,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime?.millisecondsSinceEpoch,
        'note': note,
      };

  factory NapSession.fromJson(Map<String, dynamic> json) => NapSession(
        id: json['id'] as String,
        startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
        endTime: json['endTime'] == null ? null : DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
        note: json['note'] as String?,
      );
}
