import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final namaController  = TextEditingController(text: 'Ahmad Fauzi, S.Pd.');
  final nipController   = TextEditingController(text: '19850312 201001 1 004');
  final emailController = TextEditingController(text: 'ahmad.fauzi@dikbud.go.id');

  var isLoading = false.obs;

  Future<void> simpanPerubahan() async {
    try {
      isLoading.value = true;

      // TODO: panggil API PUT/PATCH update profil di sini
      // final token = await AuthService.getToken();
      // final response = await http.put(...)

      await Future.delayed(const Duration(milliseconds: 500)); // simulasi

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetPassword() {
    Get.snackbar(
      'Info',
      'Fitur reset password akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber,
      colorText: Colors.black,
    );
  }

  @override
  void onClose() {
    namaController.dispose();
    nipController.dispose();
    emailController.dispose();
    super.onClose();
  }
}