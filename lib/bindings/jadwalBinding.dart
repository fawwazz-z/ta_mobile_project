import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jadwalController.dart';

class JadwalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalController>(() => JadwalController());
  }
}