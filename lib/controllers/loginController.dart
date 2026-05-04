import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class LoginController extends GetxController {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  var obscurePassword = true.obs;
  var isLoading       = false.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void forgotPassword() {
    Get.snackbar(
      'Informasi',
      'Fitur lupa kata sandi akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber,
      colorText: Colors.black,
    );
  }

  void loginWithBelajarId() {
    Get.snackbar('Info', 'Login Belajar.id sedang dikembangkan',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Email dan Password harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('https://kelompok14.rplrus.com/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept':        'application/json',
        },
        body: jsonEncode({
          'email':       emailController.text.trim(),
          'password':    passwordController.text,
          'device_name': 'Flutter',
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        await AuthService.saveToken(token);

        // ── Ambil data user dari response ──────────────────────────────
        // Response bisa berupa {token, role, user:{...}}
        final userMap = data['user'] as Map<String, dynamic>?;
        final role    = data['role']  as String? ?? '';

        if (userMap != null) {
          await AuthService.saveUserData(
            name:   userMap['name']  as String? ?? '',
            email:  userMap['email'] as String? ?? '',
            role:   role,
            userId: (userMap['id'] as num?)?.toInt() ?? 0,
          );
        }

        Get.snackbar('Sukses', 'Selamat Datang!',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed(AppRoutes.mainPage);
      } else {
        final msg = data['message'] ?? 'Email atau Password salah';
        Get.snackbar('Login Gagal', msg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}