import 'package:get/get.dart';
import 'package:ta_mobile_project/bindings/editProfileBinding.dart';
import 'package:ta_mobile_project/bindings/jurnalBinding.dart';
import 'package:ta_mobile_project/bindings/loginBinding.dart';
import 'package:ta_mobile_project/bindings/mainBinding.dart';
import 'package:ta_mobile_project/bindings/presensiBinding.dart';
import 'package:ta_mobile_project/bindings/presensiSiswa_Binding.dart';
import 'package:ta_mobile_project/bindings/refleksiBinding.dart';
import 'package:ta_mobile_project/bindings/verifikasiBinding.dart';
import 'package:ta_mobile_project/pages/EditProfilePage.dart';
import 'package:ta_mobile_project/pages/RefleksiPage.dart';
import 'package:ta_mobile_project/pages/jurnalPage.dart';
import 'package:ta_mobile_project/pages/loginPage.dart';
import 'package:ta_mobile_project/pages/mainPage.dart';
import 'package:ta_mobile_project/pages/presensiPage.dart';
import 'package:ta_mobile_project/pages/presensiSiswaPage.dart';
import 'package:ta_mobile_project/pages/verifikasiPage.dart';
import 'package:ta_mobile_project/routes/route.dart';

class AppPage {
  static final pages = [
    GetPage(
      name:    AppRoutes.loginPage,
      page:    () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name:    AppRoutes.mainPage,
      page:    () => MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name:    AppRoutes.jurnalPage,
      page:    () => const JurnalPage(),
      binding: JurnalBinding(),
    ),
    GetPage(
      name:    AppRoutes.presensiSiswa,
      page:    () => const PresensiSiswaPages(),
      binding: PresensiSiswaBinding(),
    ),
    GetPage(
      name:    AppRoutes.editprofile,
      page:    () => const EditProfilPages(),
      binding: EditProfileBinding(),
    ),
    // ── Presensi wajah (kamera) ──
    GetPage(
      name:    AppRoutes.presensipage,
      page:    () => PresensiPage(),
      binding: PresensiBinding(),
    ),
    // ── Verifikasi lokasi ──
    GetPage(
      name:    AppRoutes.verifikasipage,
      page:    () => VerifikasiPage(),
      binding: VerifikasiBinding(),
    ),
    // ── Refleksi mengajar ──
    GetPage(
      name:    AppRoutes.refleksipage,
      page:    () => RefleksiPage(),
      binding: RefleksiBinding(),
    ),
  ];
}