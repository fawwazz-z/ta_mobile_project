import 'package:get/get.dart';
import '../controllers/presensiController.dart';

class VerifikasiController extends GetxController {
  // Data lokasi disalin dari PresensiController via lanjutKeVerifikasi()
  var fotoPath    = ''.obs;
  var alamat      = ''.obs;
  var koordinat   = ''.obs;
  var jarakMeter  = 0.0.obs;
  var dalamRadius = false.obs;
  var currentLat  = 0.0.obs;
  var currentLng  = 0.0.obs;

  // Submit delegasi ke PresensiController karena koordinat & foto ada di sana
  Future<void> selesaikanPresensi() async {
    if (Get.isRegistered<PresensiController>()) {
      await Get.find<PresensiController>().submitPresensi();
    }
  }

  String get statusText =>
      dalamRadius.value ? 'Dalam Radius Sekolah' : 'Di Luar Radius Sekolah';

  String get jarakText => '${jarakMeter.value.toStringAsFixed(0)} Meter';
}