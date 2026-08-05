import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/colors.dart'; 

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Mengambil Base URL dari AppStatic
  static String baseUrl = AppStatic.base_url;

  // ---------- 1. Inisialisasi Service Notifikasi ----------
  static Future<void> initialize() async {
    // Setup Local Notification (Banner saat app terbuka di foreground)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Request Izin Notifikasi (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Status izin notifikasi: ${settings.authorizationStatus}');

    // Ambil Token FCM & Kirim ke Backend
    String? token = await _fcm.getToken();
    print('FCM Token Perangkat: $token');
    await registerToken(token);

    // Listeners
    // A. Saat aplikasi terbuka di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // B. Saat notifikasi di-klik di background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageClick(message);
    });

    // C. Saat FCM Token di-refresh otomatis oleh Firebase
    _fcm.onTokenRefresh.listen((newToken) {
      registerToken(newToken);
    });
  }

  // ---------- 2. Kirim FCM Token ke Backend Laravel ----------
  static Future<void> registerToken(String? token) async {
    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token') ?? prefs.getString('auth_token');

    if (authToken == null) {
      print('User belum login, register token FCM ditunda.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm/register'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_name': Platform.isAndroid ? 'Android Device' : 'iOS Device',
          'device_platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM Token berhasil didaftarkan ke Laravel');
      } else {
        print('Gagal mendaftarkan FCM token: ${response.body}');
      }
    } catch (e) {
      print('Error saat register FCM token: $e');
    }
  }

  // ---------- 3. Tampilkan Banner Notifikasi Lokal ----------
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'class_reminder_channel',
      'Pengingat Kelas',
      channelDescription: 'Notifikasi pengingat jadwal mengajar guru',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.hashCode,
      message.notification?.title ?? 'Pengingat Kelas',
      message.notification?.body ?? 'Jadwal mengajar akan segera dimulai.',
      details,
      payload: jsonEncode(message.data),
    );
  }

  // ---------- 4. Handler Saat Notifikasi Di-klik ----------
  static void _handleMessageClick(RemoteMessage message) {
    Map<String, dynamic> data = message.data;
    print('Notifikasi diklik dengan payload: $data');
  }

  // ---------- 5. Hapus FCM Token saat Logout ----------
  static Future<void> unregisterToken() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token') ?? prefs.getString('auth_token');
    final fcmToken = await _fcm.getToken();

    if (authToken == null || fcmToken == null) return;

    try {
      await http.delete(
        Uri.parse('$baseUrl/fcm/unregister'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
      print('FCM Token berhasil dihapus dari backend');
    } catch (e) {
      print('Error hapus FCM token: $e');
    }
  }
}