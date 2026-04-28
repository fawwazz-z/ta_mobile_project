import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/pages/fragment/homeFragment.dart';
import 'package:ta_mobile_project/pages/fragment/jadwalFragment.dart';
import 'package:ta_mobile_project/pages/fragment/profileFragment.dart';
import 'package:ta_mobile_project/pages/fragment/riwayatFragment.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;

  // Daftar Fragment sebagai Widget
  final List<Widget> fragments = [
    HomeFragment(), // Konten beranda yang kamu buat sebelumnya
    RiwayatFragment(),
    JadwalFragment(),
    ProfileFragment(),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
