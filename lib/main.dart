import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/pages.dart';
import 'routes/route.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Presensi Guru',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.loginPage,   // ← harus loginPage, bukan mainPage
      getPages: AppPage.pages,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6B1A1A),
      ),
    );
  }
}