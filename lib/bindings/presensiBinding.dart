import 'package:get/get.dart';
import '../controllers/presensiController.dart';

class PresensiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresensiController>(() => PresensiController());
  }
}
