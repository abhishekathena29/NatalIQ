import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/features/community/models/community_comment.dart';
import 'package:natal_iq/features/community/models/community_post.dart';

/// Firestore-backed community posts, 2-level comment threads, and likes.
/// Mirrors [AuthService]'s `users/{uid}` convention: top-level collections,
/// doc-per-entity, plain toJson/fromDoc models.
class CommunityService {
  CommunityService._();

  static FirebaseFirestore? _firestoreOverride;
  static FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  @visibleForTesting
  static void debugOverrideFirestore(FirebaseFirestore firestore) {
    _firestoreOverride = firestore;
  }

  static CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');

  static Stream<CommunityPost?> watchPost(String postId) {
    return _posts.doc(postId).snapshots().map((d) => d.exists ? CommunityPost.fromDoc(d) : null);
  }

  static Stream<List<CommunityPost>> watchPosts({int limit = 30}) {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(CommunityPost.fromDoc).toList());
  }

  static Future<String> createPost({required String body}) async {
    final uid = AuthService.instance.uid;
    if (uid == null) throw StateError('Must be logged in to post.');
    final onboarding = AuthService.instance.onboarding;
    final post = CommunityPost(
      id: '',
      authorUid: uid,
      authorName: AuthService.instance.displayName,
      body: body.trim(),
      week: onboarding?.pregnancyWeek,
      createdAt: DateTime.now(),
      likeCount: 0,
      commentCount: 0,
    );
    final doc = await _posts.add(post.toJson());
    return doc.id;
  }

  static Stream<List<CommunityComment>> watchComments(String postId) {
    return _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => CommunityComment.fromDoc(d, postId)).toList());
  }

  static Future<void> addComment({
    required String postId,
    required String body,
    String? parentCommentId,
  }) async {
    final uid = AuthService.instance.uid;
    if (uid == null) throw StateError('Must be logged in to comment.');
    final comment = CommunityComment(
      id: '',
      postId: postId,
      authorUid: uid,
      authorName: AuthService.instance.displayName,
      body: body.trim(),
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );
    final postRef = _posts.doc(postId);
    await postRef.collection('comments').add(comment.toJson());
    await postRef.update({'commentCount': FieldValue.increment(1)});
  }

  static Stream<bool> watchIsLiked(String postId) {
    final uid = AuthService.instance.uid;
    if (uid == null) return Stream.value(false);
    return _posts.doc(postId).collection('likes').doc(uid).snapshots().map((d) => d.exists);
  }

  /// Toggles the current user's like on [postId], keeping `likeCount` in
  /// sync. Returns the new liked state.
  static Future<bool> toggleLike(String postId) async {
    final uid = AuthService.instance.uid;
    if (uid == null) throw StateError('Must be logged in to like a post.');
    final postRef = _posts.doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    return _firestore.runTransaction<bool>((tx) async {
      final likeSnap = await tx.get(likeRef);
      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likeCount': FieldValue.increment(-1)});
        return false;
      } else {
        tx.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likeCount': FieldValue.increment(1)});
        return true;
      }
    });
  }
}
