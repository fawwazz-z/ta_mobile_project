import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/loginController.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
