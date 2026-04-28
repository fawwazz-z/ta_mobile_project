import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
