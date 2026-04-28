import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/pages/fragment/homePage.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;

  // Daftar Fragment sebagai Widget
  final List<Widget> fragments = [
    const HomePage(), // Konten beranda yang kamu buat sebelumnya
    const Center(child: Text("Riwayat Fragment")),
    const Center(child: Text("Jadwal Fragment")),
    const Center(child: Text("Profil Fragment")),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
