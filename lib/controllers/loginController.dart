import 'dart:convert'; // Wajib untuk jsonEncode & jsonDecode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // Import dengan alias 'http'

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var obscurePassword = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  void forgotPassword() {
    // Logika ketika tombol Lupa Kata Sandi ditekan
    Get.snackbar(
      'Informasi', 
      'Fitur lupa kata sandi akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber,
      colorText: Colors.black
    );
  }

  void loginWithBelajarId() {
    // Logika login menggunakan akun belajar.id
    print("Mencoba login dengan Belajar.id");
    Get.snackbar(
      'Info', 
      'Login Belajar.id sedang dikembangkan',
      snackPosition: SnackPosition.BOTTOM
    );
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Email dan Password harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Endpoint URL
      final url = Uri.parse('https://kelompok14.rplrus.com/api/login');

      // Melakukan request POST
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Memberitahu server bahwa kita mengirim JSON
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
          "device_name": "Flutter",
        }),
      );

      // Decode response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Berhasil (Sesuaikan key 'token' dengan respon asli API kamu)
        String token = responseData['token'];
        print('Login Berhasil, Token: $token');

        Get.snackbar('Sukses', 'Selamat Datang!',
            backgroundColor: Colors.green, colorText: Colors.white);
        
        // Navigasi ke home
        // Get.offAllNamed(Routes.HOME);
      } else {
        // Gagal (Status code 401, 400, 422, dll)
        String message = responseData['message'] ?? "Email atau Password salah";
        Get.snackbar('Login Gagal', message,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      // Error jaringan atau server mati
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