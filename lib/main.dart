import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 1. Ditambahkan
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routes/pages.dart';
import 'routes/route.dart';
import 'services/fcm_service.dart';

// 2. Handler untuk notifikasi saat aplikasi ditutup/background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 3. Set handler background & inisialisasi FcmService
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FcmService.initialize();

  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Presensi Guru',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashPage,
      getPages: AppPage.pages,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6B1A1A),
      ),
    );
  }
}