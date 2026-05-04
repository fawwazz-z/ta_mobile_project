import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/refleksiController.dart';

class RefleksiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefleksiController>(() => RefleksiController());
  }
}