import 'package:get/get.dart';
import 'package:ta_mobile_project/bindings/loginBinding.dart';
import 'package:ta_mobile_project/pages/loginPage.dart';
import 'package:ta_mobile_project/pages/mainPage.dart';
import 'package:ta_mobile_project/routes/route.dart';

class AppPage {
  static final pages = [
    GetPage(
      name: AppRoutes.loginPage,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(name: AppRoutes.mainPage, page: () => MainPage()),
  ];
}
