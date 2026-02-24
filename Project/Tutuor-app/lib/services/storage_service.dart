import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  StorageService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tutorCollection =>
      _firestore.collection('tutors');

  Future<List<Map<String, dynamic>>> getAllTutors() async {
    try {
      final snapshot = await _tutorCollection
          .orderBy('updatedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTutorById(String tutorId) async {
    try {
      final snapshot = await _tutorCollection.doc(tutorId).get();
      if (!snapshot.exists) return null;
      return {'id': snapshot.id, ...snapshot.data()!};
    } catch (e) {
      return null;
    }
  }

  Future<String?> createTutor(Map<String, dynamic> data) async {
    try {
      final doc = await _tutorCollection.add(data);
      await doc.update({'tutorId': doc.id});
      return doc.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTutor(String tutorId, Map<String, dynamic> data) async {
    try {
      await _tutorCollection.doc(tutorId).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTutor(String tutorId) async {
    try {
      await _tutorCollection.doc(tutorId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginTutorByEmail(
    String email,
    String password,
  ) async {
    try {
      final snapshot = await _tutorCollection
          .where('email', isEqualTo: email.trim())
          .where('password', isEqualTo: password)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    } catch (e) {
      return null;
    }
  }
}
