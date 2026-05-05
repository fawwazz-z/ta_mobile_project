import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routes/pages.dart';
import 'routes/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      initialRoute: AppRoutes.splashPage,   // ← ubah dari loginPage ke splashPage
      getPages: AppPage.pages,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6B1A1A),
      ),
    );
  }
}