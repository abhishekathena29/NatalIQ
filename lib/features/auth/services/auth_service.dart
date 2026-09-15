import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:natal_iq/features/auth/models/onboarding_info.dart';

/// Thrown by [AuthService] with a message that's already safe to show
/// directly in the login/signup forms.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Firebase-backed auth + onboarding state. Auth itself lives in
/// FirebaseAuth; onboarding answers are mirrored to Firestore (`users/{uid}`)
/// so they survive reinstalls, with a shared_preferences cache so the UI has
/// something to show before the first Firestore read completes.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kOnboardingCache = 'aanya.onboarding.cache.v1';

  fb.FirebaseAuth? _authOverride;
  FirebaseFirestore? _firestoreOverride;
  fb.User? _user;
  OnboardingInfo? _onboarding;
  StreamSubscription<fb.User?>? _authSub;

  // Resolved lazily (not as eager field initializers) so a test can call
  // [debugOverrideBackends] before Firebase is ever touched.
  fb.FirebaseAuth get _auth => _authOverride ?? fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  /// Swaps in fakes so tests don't need a real Firebase backend. Call before
  /// [init].
  @visibleForTesting
  void debugOverrideBackends({fb.FirebaseAuth? auth, FirebaseFirestore? firestore}) {
    if (auth != null) _authOverride = auth;
    if (firestore != null) _firestoreOverride = firestore;
  }

  bool get isLoggedIn => _user != null;
  String? get email => _user?.email;
  OnboardingInfo? get onboarding => _onboarding;
  bool get hasOnboarded => _onboarding != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kOnboardingCache);
    if (cached != null) {
      try {
        _onboarding = OnboardingInfo.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }

    _user = _auth.currentUser;
    if (_user != null) await _loadOnboarding(_user!.uid);

    _authSub = _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _loadOnboarding(user.uid);
      } else {
        _onboarding = null;
        await prefs.remove(_kOnboardingCache);
      }
      notifyListeners();
    });
  }

  Future<void> _loadOnboarding(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        _onboarding = OnboardingInfo.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kOnboardingCache, jsonEncode(_onboarding!.toJson()));
      }
    } catch (_) {
      // Firestore unreachable — keep whatever was already cached locally.
    }
  }

  String _friendlyError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  Future<void> logIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_friendlyError(e));
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_friendlyError(e));
    }
  }

  Future<void> completeOnboarding(OnboardingInfo info) async {
    final uid = _user?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set(info.toJson());
    _onboarding = info;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOnboardingCache, jsonEncode(info.toJson()));
    notifyListeners();
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
