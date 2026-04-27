import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/pages.dart';
import 'routes/route.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Presensi Guru',
      debugShowCheckedModeBanner: false,
      // Mengambil initial route dari class Routes
      initialRoute: AppRoutes.loginPage, 
      // Mengambil daftar halaman dari AppPages
      getPages: AppPage.pages,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6B1A1A),
      ),
    );
  }
}