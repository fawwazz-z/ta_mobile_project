import 'package:get/get.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    final loggedIn = await AuthService.isLoggedIn();

    if (loggedIn) {
      Get.offNamed(AppRoutes.mainPage);
    } else {
      Get.offNamed(AppRoutes.loginPage);
    }
  }
}
