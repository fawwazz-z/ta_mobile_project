import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var obscurePassword = true.obs;
  var isLoading = false.obs;
  var isLoadingGoogle = false.obs;

  // GoogleSignIn instance — scopes minimal agar tidak butuh konfigurasi ekstra
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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

  // ─── LOGIN EMAIL / PASSWORD ──────────────────────────────────────────────
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan Password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('${AppStatic.base_url}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'device_name': 'Flutter',
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _saveSession(data);
        Get.snackbar(
          'Sukses',
          'Selamat Datang!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.mainPage);
      } else {
        final msg = data['message'] ?? 'Email atau Password salah';
        Get.snackbar(
          'Login Gagal',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── LOGIN GOOGLE ────────────────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    try {
      isLoadingGoogle.value = true;

      // 1. Minta user pilih akun Google
      await _googleSignIn.signOut(); // reset session
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User membatalkan pilihan
        isLoadingGoogle.value = false;
        return;
      }

      // 2. Ambil auth tokens dari Google
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        Get.snackbar(
          'Error',
          'Gagal mendapatkan token Google',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoadingGoogle.value = false;
        return;
      }

      // 3. Kirim id_token ke backend — endpoint: POST /api/auth/google
      final response = await http.post(
        Uri.parse('${AppStatic.base_url}/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _saveSession(data);
        Get.snackbar(
          'Sukses',
          'Selamat Datang!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.mainPage);
      } else {
        final msg = data['message'] ?? 'Login Google gagal';
        Get.snackbar(
          'Login Gagal',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingGoogle.value = false;
    }
  }

  // ─── HELPER: Simpan sesi dari response login ─────────────────────────────
  // Kedua endpoint (login & google) punya format yang sama:
  // { token, role, user: {id, name, email, ...} }
  Future<void> _saveSession(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final role = data['role'] as String? ?? '';
    final userMap = data['user'] as Map<String, dynamic>?;

    await AuthService.saveToken(token);

    if (userMap != null) {
      await AuthService.saveUserData(
        name: userMap['name'] as String? ?? '',
        email: userMap['email'] as String? ?? '',
        role: role,
        userId: (userMap['id'] as num?)?.toInt() ?? 0,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
