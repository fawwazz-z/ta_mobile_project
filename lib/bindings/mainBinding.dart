import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/controllers/mainController.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => RiwayatController());
  }
}
