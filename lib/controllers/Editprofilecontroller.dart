import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/controllers/profileController.dart';
import 'package:ta_mobile_project/services/authService.dart';

class EditProfileController extends GetxController {
  late TextEditingController namaController;
  late TextEditingController nipController;
  late TextEditingController emailController;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Isi field dari data yang sudah tersimpan di ProfileController
    final profileCtrl = Get.find<ProfileController>();
    namaController  = TextEditingController(text: profileCtrl.userName.value == '-' ? '' : profileCtrl.userName.value);
    nipController   = TextEditingController(text: '');
    emailController = TextEditingController(text: profileCtrl.userEmail.value == '-' ? '' : profileCtrl.userEmail.value);
  }

  Future<void> simpanPerubahan() async {
    final nama  = namaController.text.trim();
    final email = emailController.text.trim();

    if (nama.isEmpty) {
      Get.snackbar('Peringatan', 'Nama tidak boleh kosong',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final token  = await AuthService.getToken() ?? '';
      final userId = await AuthService.getUserId();

      // Panggil API update profil
      final response = await http.put(
        Uri.parse('https://kelompok14.rplrus.com/api/users/$userId'),
        headers: {
          'Content-Type' : 'application/json',
          'Accept'       : 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name' : nama,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan ke SharedPreferences
        await AuthService.saveUserData(
          name  : nama,
          email : email,
          role  : await AuthService.getUserRole()  ?? '',
          userId: userId ?? 0,
        );

        // ── Sync ProfileController ────────────────────────────────────────
        if (Get.isRegistered<ProfileController>()) {
          final pc = Get.find<ProfileController>();
          pc.userName.value  = nama;
          pc.userEmail.value = email;
        }

        // ── Sync HomeController (nama di header home) ─────────────────────
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().teacherName.value = nama;
        }

        Get.back();
        Get.snackbar(
          'Berhasil',
          'Profil berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Jika API belum siap, tetap update lokal
        await AuthService.saveUserData(
          name  : nama,
          email : email,
          role  : await AuthService.getUserRole()  ?? '',
          userId: userId ?? 0,
        );

        if (Get.isRegistered<ProfileController>()) {
          final pc = Get.find<ProfileController>();
          pc.userName.value  = nama;
          pc.userEmail.value = email;
        }

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().teacherName.value = nama;
        }

        Get.back();
        Get.snackbar(
          'Berhasil',
          'Profil diperbarui secara lokal',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil, cek koneksi internet',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
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