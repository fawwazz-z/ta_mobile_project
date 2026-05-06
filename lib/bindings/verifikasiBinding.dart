import 'package:get/get.dart';
import '../controllers/verifikasiController.dart';

class VerifikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifikasiController>(() => VerifikasiController());
  }
}
