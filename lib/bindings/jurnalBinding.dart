import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jurnalController.dart';

class JurnalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JurnalController>(() => JurnalController());
  }
}
