import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:natal_iq/core/theme/app_theme.dart';

/// A small fixed palette so community cards get visual variety without
/// asking the creator to pick an icon/colour.
const _tones = [AppTone.blush, AppTone.peach, AppTone.sage];

AppTone toneForCommunity(String id) => _tones[id.hashCode.abs() % _tones.length];

class Community {
  final String id;
  final String name;
  final String description;
  final String creatorUid;
  final String creatorName;
  final int memberCount;
  final DateTime createdAt;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorUid,
    required this.creatorName,
    required this.memberCount,
    required this.createdAt,
  });

  factory Community.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Community(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      description: data['description'] as String? ?? '',
      creatorUid: data['creatorUid'] as String? ?? '',
      creatorName: data['creatorName'] as String? ?? 'Member',
      memberCount: data['memberCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'creatorUid': creatorUid,
        'creatorName': creatorName,
        'memberCount': memberCount,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
