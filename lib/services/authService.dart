import 'package:shared_preferences/shared_preferences.dart';
import 'fcm_service.dart'; // 1. Import FcmService

class AuthService {
  static const _keyToken = 'auth_token';
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyRole = 'user_role';
  static const _keyUserId = 'user_id';

  // ─── TOKEN ───────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ─── USER DATA ───────────────────────────────────────────────────────────
  static Future<void> saveUserData({
    required String name,
    required String email,
    required String role,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRole, role);
    await prefs.setInt(_keyUserId, userId);
  }

  static Future<String?> getUserName() async =>
      (await SharedPreferences.getInstance()).getString(_keyName);

  static Future<String?> getUserEmail() async =>
      (await SharedPreferences.getInstance()).getString(_keyEmail);

  static Future<String?> getUserRole() async =>
      (await SharedPreferences.getInstance()).getString(_keyRole);

  static Future<int?> getUserId() async =>
      (await SharedPreferences.getInstance()).getInt(_keyUserId);

  // ─── CLEAR / LOGOUT ───────────────────────────────────────────────────────
  static Future<void> clearToken() async {
    // 2. Hapus FCM token dari server Laravel dulu sebelum hapus data di HP
    try {
      await FcmService.unregisterToken();
    } catch (e) {
      print('Gagal unregister FCM Token saat logout: $e');
    }

    // 3. Hapus sesi lokal di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}