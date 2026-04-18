import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService(
    this._auth, {
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ── Soft-delete (90-day grace period) ──────────────────────────────────────

  static const int _deletionGraceDays = 90;

  /// Schedules account deletion after 90 days.
  /// Stores [scheduledDeletionAt] in the user Firestore document, then signs out.
  Future<void> requestAccountDeletion() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final deletionDate = DateTime.now().add(
      const Duration(days: _deletionGraceDays),
    );

    await _firestore.collection('users').doc(user.uid).set({
      'scheduledDeletionAt': deletionDate.millisecondsSinceEpoch,
      'deletionRequestedAt': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));

    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Cancels a pending deletion request.
  Future<void> cancelAccountDeletion() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'scheduledDeletionAt': FieldValue.delete(),
      'deletionRequestedAt': FieldValue.delete(),
    });
  }

  /// Checks if the signed-in user has a pending deletion.
  /// Returns the [DateTime] of scheduled deletion, or null if none.
  Future<DateTime?> getPendingDeletionDate() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final ts = doc.data()?['scheduledDeletionAt'];
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts as int);
  }

  /// If the grace period has expired, permanently deletes the account.
  /// Returns true if account was deleted, false if still within grace period.
  Future<bool> processExpiredDeletion() async {
    final deletionDate = await getPendingDeletionDate();
    if (deletionDate == null) return false;
    if (DateTime.now().isBefore(deletionDate)) return false;

    // Grace period over — permanently delete
    await _permanentlyDeleteAccount();
    return true;
  }

  Future<void> _permanentlyDeleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final cvSnapshot = await _firestore
        .collection('cvs')
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in cvSnapshot.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('users').doc(uid).delete();
    await _googleSignIn.signOut();
    await user.delete();
  }

  /// Hard delete — immediate (kept for admin/internal use).
  Future<void> deleteAccount() async {
    await _permanentlyDeleteAccount();
  }
}
