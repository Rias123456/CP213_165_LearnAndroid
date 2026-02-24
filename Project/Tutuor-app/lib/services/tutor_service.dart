import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/error_handler.dart';
import 'storage_service.dart';

class TutorService {
  TutorService({
    StorageService? storageService,
  }) : _storageService = storageService ?? StorageService();

  final StorageService _storageService;

  Future<String?> registerTutor({
    required Map<String, dynamic> data,
    required Uint8List imageBytes,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final payload = {
        ...data,
        'profileImageBase64': base64Image,
        'subjects': <Map<String, dynamic>>[],
        'schedule': {
          'saturday': [],
          'sunday': [],
          'monday': [],
          'tuesday': [],
          'wednesday': [],
          'thursday': [],
          'friday': [],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      return await _storageService.createTutor(payload);
    } catch (e) {
      throw Exception(getFirestoreErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>?> loginTutor(String email, String password) {
    return _storageService.loginTutorByEmail(email, password);
  }

  Future<Map<String, dynamic>?> getTutorById(String tutorId) {
    return _storageService.getTutorById(tutorId);
  }

  Future<bool> updateTutor(String tutorId, Map<String, dynamic> data) async {
    try {
      return await _storageService.updateTutor(tutorId, data);
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTutor(String tutorId) {
    return _storageService.deleteTutor(tutorId);
  }
}
