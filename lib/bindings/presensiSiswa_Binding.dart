import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/presensiSiswaController.dart';

class PresensiSiswaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresensiSiswaController>(() => PresensiSiswaController());
  }
}
