import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';
import 'package:ta_mobile_project/pages/fragment/homeFragment.dart';
import 'package:ta_mobile_project/pages/fragment/jadwalFragment.dart';
import 'package:ta_mobile_project/pages/fragment/profileFragment.dart';
import 'package:ta_mobile_project/pages/fragment/riwayatFragment.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;
  late List<Widget> fragments;

  @override
  void onInit() {
    super.onInit();

    // Pastikan RiwayatController sudah ada sebelum RiwayatFragment dibuat,
    // agar Get.find<RiwayatController>() di dalam fragment tidak error.
    if (!Get.isRegistered<RiwayatController>()) {
      Get.put(RiwayatController());
    }

    fragments = [
      HomeFragment(),
      RiwayatFragment(),
      JadwalFragment(),
      ProfileFragment(),
    ];
  }

  void changeIndex(int index) {
    selectedIndex.value = index;

    // Refresh riwayat setiap kali tab Riwayat dibuka (index 1)
    if (index == 1) {
      Get.find<RiwayatController>().fetchHistory();
    }
  }
}