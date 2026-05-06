import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/profileController.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
