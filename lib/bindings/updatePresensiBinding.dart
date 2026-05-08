import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/updatePresensiController.dart';

class UpdatePresensiBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => UpdatePresensiController());
  }
}
