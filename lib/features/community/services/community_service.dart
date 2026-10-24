import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/features/community/models/community.dart';
import 'package:natal_iq/features/community/models/community_comment.dart';
import 'package:natal_iq/features/community/models/community_post.dart';

/// Firestore-backed communities (join/leave, create), posts, 2-level comment
/// threads, and likes. Mirrors [AuthService]'s `users/{uid}` convention:
/// top-level collections, doc-per-entity, plain toJson/fromDoc models.
class CommunityService {
  CommunityService._();

  static FirebaseFirestore? _firestoreOverride;
  static FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  @visibleForTesting
  static void debugOverrideFirestore(FirebaseFirestore firestore) {
    _firestoreOverride = firestore;
  }

  static CollectionReference<Map<String, dynamic>> get _communities => _firestore.collection('communities');
  static CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');

  // ---- Communities ----------------------------------------------------

  /// Creates the default "General" community the first time it's needed, so
  /// posts made before multi-community support (or without picking one)
  /// always have somewhere to live. Safe to call repeatedly.
  static Future<void> ensureGeneralCommunityExists() async {
    final uid = AuthService.instance.uid;
    if (uid == null) return;
    final ref = _communities.doc(kGeneralCommunityId);
    final doc = await ref.get();
    if (doc.exists) return;
    await ref.set({
      'name': 'General',
      'description': 'Open discussion for everyone — the original Natal IQ community.',
      'creatorUid': uid,
      'creatorName': 'Natal IQ',
      'memberCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Community>> watchCommunities() {
    return _communities
        .orderBy('memberCount', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Community.fromDoc).toList());
  }

  static Stream<Community?> watchCommunity(String communityId) {
    return _communities.doc(communityId).snapshots().map((d) => d.exists ? Community.fromDoc(d) : null);
  }

  static Future<String> createCommunity({required String name, required String description}) async {
    final uid = AuthService.instance.uid;
    if (uid == null) throw StateError('Must be logged in to create a community.');
    final community = Community(
      id: '',
      name: name.trim(),
      description: description.trim(),
      creatorUid: uid,
      creatorName: AuthService.instance.displayName,
      memberCount: 1,
      createdAt: DateTime.now(),
    );
    final doc = await _communities.add(community.toJson());
    await doc.collection('members').doc(uid).set({'joinedAt': FieldValue.serverTimestamp()});
    return doc.id;
  }

  static Stream<bool> watchIsMember(String communityId) {
    final uid = AuthService.instance.uid;
    if (uid == null) return Stream.value(false);
    return _communities.doc(communityId).collection('members').doc(uid).snapshots().map((d) => d.exists);
  }

  /// Toggles the current user's membership in [communityId], keeping
  /// `memberCount` in sync. Returns the new membership state.
  static Future<bool> toggleMembership(String communityId) async {
    final uid = AuthService.instance.uid;
    if (uid == null) throw StateError('Must be logged in to join a community.');
    final communityRef = _communities.doc(communityId);
    final memberRef = communityRef.collection('members').doc(uid);

    return _firestore.runTransaction<bool>((tx) async {
      final memberSnap = await tx.get(memberRef);
      if (memberSnap.exists) {
        tx.delete(memberRef);
        tx.update(communityRef, {'memberCount': FieldValue.increment(-1)});
        return false;
      } else {
        tx.set(memberRef, {'joinedAt': FieldValue.serverTimestamp()});
        tx.update(communityRef, {'memberCount': FieldValue.increment(1)});
        return true;
      }
    });
  }

  // ---- Posts ------------------------------------------------------------

  static Stream<CommunityPost?> watchPost(String postId) {
    return _posts.doc(postId).snapshots().map((d) => d.exists ? CommunityPost.fromDoc(d) : null);
  }

  /// All posts, optionally scoped to one community. Scoped queries need a
  /// Firestore composite index on (communityId asc, createdAt desc) — the
  /// first run will log a console link to create it.
  static Stream<List<CommunityPost>> watchPosts({String? communityId, int limit = 30}) {
    Query<Map<String, dynamic>> query = _posts;
    if (communityId != null) {
      query = query.where('communityId', isEqualTo: communityId);
    }
    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(CommunityPost.fromDoc).toList());
  }

  static Future<String> createPost({required String communityId, required String body}) async {
    final uid = AuthService.instance.uid;
    if (uid == null) throw StateError('Must be logged in to post.');
    final onboarding = AuthService.instance.onboarding;
    final post = CommunityPost(
      id: '',
      communityId: communityId,
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
