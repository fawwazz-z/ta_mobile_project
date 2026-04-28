import 'package:get/get.dart';

class HomeController extends GetxController {
  // Contoh data reaktif di home
  var teacherName = "Guru Bahasa Indonesia".obs;
  var hadirPercent = "98%".obs;

  void refreshData() {
    // Logika ambil data dari API atau database
    print("Data Home Diperbarui");
  }
}
