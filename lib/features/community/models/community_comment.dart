import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityComment {
  final String id;
  final String postId;
  final String authorUid;
  final String authorName;
  final String body;
  final DateTime createdAt;
  final String? parentCommentId;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorUid,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.parentCommentId,
  });

  bool get isReply => parentCommentId != null;

  factory CommunityComment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, String postId) {
    final data = doc.data() ?? const {};
    return CommunityComment(
      id: doc.id,
      postId: postId,
      authorUid: data['authorUid'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Member',
      body: data['body'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      parentCommentId: data['parentCommentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'authorUid': authorUid,
        'authorName': authorName,
        'body': body,
        'createdAt': FieldValue.serverTimestamp(),
        'parentCommentId': parentCommentId,
      };
}
