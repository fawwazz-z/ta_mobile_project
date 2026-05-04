import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/controllers/jadwalController.dart';
import 'package:ta_mobile_project/controllers/mainController.dart';
import 'package:ta_mobile_project/controllers/profileController.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => RiwayatController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => JadwalController());  // ← Untuk JadwalFragment
    Get.put(MainController());
  }
}