import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';

class RiwayatBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<RiwayatController>(() => RiwayatController());
  }
}
