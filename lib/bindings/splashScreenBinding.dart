import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/SplashScreenController.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}