import 'package:cloud_firestore/cloud_firestore.dart';

/// Id used for posts created before communities existed, and as the
/// always-present default community new users land in.
const kGeneralCommunityId = 'general';

class CommunityPost {
  final String id;
  final String communityId;
  final String authorUid;
  final String authorName;
  final String body;
  final int? week;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;

  const CommunityPost({
    required this.id,
    required this.communityId,
    required this.authorUid,
    required this.authorName,
    required this.body,
    required this.week,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
  });

  factory CommunityPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return CommunityPost(
      id: doc.id,
      communityId: data['communityId'] as String? ?? kGeneralCommunityId,
      authorUid: data['authorUid'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Member',
      body: data['body'] as String? ?? '',
      week: data['week'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'communityId': communityId,
        'authorUid': authorUid,
        'authorName': authorName,
        'body': body,
        'week': week,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': likeCount,
        'commentCount': commentCount,
      };
}
