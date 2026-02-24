import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tutorIdKey = 'loggedInTutorId';

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTutorSession(String tutorId) async {
    final prefs = await _getPrefs();
    if (prefs == null) {
      return;
    }
    await prefs.setString(_tutorIdKey, tutorId);
  }

  Future<String?> getSavedTutorId() async {
    final prefs = await _getPrefs();
    if (prefs == null) {
      return null;
    }
    return prefs.getString(_tutorIdKey);
  }

  Future<void> clearTutorSession() async {
    final prefs = await _getPrefs();
    if (prefs == null) {
      return;
    }
    await prefs.remove(_tutorIdKey);
  }
}
