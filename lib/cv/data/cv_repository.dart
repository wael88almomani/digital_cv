import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cv_document.dart';
import '../models/cv_user.dart';

class CvRepository {
  CvRepository(this._firestore);

  final FirebaseFirestore _firestore;

  // ============ Legacy User Methods (for backward compatibility) ============

  Stream<CvUser?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return CvUser.fromMap(snapshot.id, data);
    });
  }

  Future<void> saveUser(CvUser user) {
    return _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(uid).update(data);
  }

  // ============ Multi-CV Document Methods ============

  /// Watch all CVs for a specific user
  Stream<List<CvDocument>> watchUserCvs(String userId) {
    return _firestore
        .collection('cvs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final cvs = snapshot.docs.map((doc) {
            return CvDocument.fromMap(doc.id, doc.data());
          }).toList();
          // Sort by createdAt descending (newest first)
          cvs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return cvs;
        });
  }

  /// Watch only the active CV for a user
  Stream<CvDocument?> watchActiveCv(String userId) {
    return _firestore
        .collection('cvs')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return CvDocument.fromMap(doc.id, doc.data());
        });
  }

  /// Get a single CV by ID
  Future<CvDocument?> getCvById(String cvId) async {
    final doc = await _firestore.collection('cvs').doc(cvId).get();
    if (!doc.exists) return null;
    return CvDocument.fromMap(doc.id, doc.data()!);
  }

  /// Create a new CV document
  Future<String> createCv(CvDocument cv) async {
    final docRef = await _firestore.collection('cvs').add(cv.toMap());
    return docRef.id;
  }

  /// Save/update a CV document
  Future<void> saveCv(CvDocument cv) {
    final updated = cv.copyWith(updatedAt: DateTime.now());
    return _firestore.collection('cvs').doc(cv.id).set(updated.toMap());
  }

  /// Update specific fields of a CV
  Future<void> updateCv(String cvId, Map<String, dynamic> data) {
    data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    return _firestore.collection('cvs').doc(cvId).update(data);
  }

  /// Delete a CV document
  Future<void> deleteCv(String cvId) {
    return _firestore.collection('cvs').doc(cvId).delete();
  }

  /// Set a CV as active and deactivate all others for the same user
  Future<void> setActiveCv(String userId, String cvId) async {
    final batch = _firestore.batch();

    // Find all CVs for this user
    final snapshot = await _firestore
        .collection('cvs')
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isActive': doc.id == cvId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await batch.commit();
  }

  /// Get count of CVs for a user
  Future<int> getCvCount(String userId) async {
    final snapshot = await _firestore
        .collection('cvs')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.length;
  }
}
