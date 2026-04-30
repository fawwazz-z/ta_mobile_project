import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;

  // Navigasi ke halaman Edit Profil
  void goToEditProfil() {
    Get.toNamed(AppRoutes.editprofile);
  }

  // Logout dengan konfirmasi dialog
  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3D2B1F),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.brown.shade500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;
      final token = await AuthService.getToken();

      // Hit endpoint logout untuk invalidate token di server
      await http.post(
        Uri.parse('https://kelompok14.rplrus.com/api/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      // Jika gagal koneksi, tetap lanjutkan logout lokal
    } finally {
      isLoading.value = false;
    }

    // Hapus token lokal lalu kembali ke halaman login
    await AuthService.clearToken();
    Get.offAllNamed(AppRoutes.loginPage);
  }
}