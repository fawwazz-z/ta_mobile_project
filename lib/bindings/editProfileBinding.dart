import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/Editprofilecontroller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}