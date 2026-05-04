import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class RefleksiController extends GetxController {
  final refleksiController = TextEditingController();
  var isSaving  = false.obs;

  late final int    scheduleId;
  late final String kelasNama;
  late final String mapelNama;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    scheduleId = args['schedule_id'] as int?    ?? 0;
    kelasNama  = args['kelas']       as String? ?? '';
    mapelNama  = args['mapel']       as String? ?? '';
  }

  /// POST /api/journals/{schedule_id}/reflection  (atau endpoint refleksi)
  /// — sesuaikan path jika berbeda di API docs
  Future<void> simpanRefleksi() async {
    final teks = refleksiController.text.trim();
    if (teks.isEmpty) {
      Get.snackbar('Perhatian', 'Catatan refleksi tidak boleh kosong',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final token    = await AuthService.getToken();

      final response = await http.post(
        Uri.parse(
            'https://kelompok14.rplrus.com/api/journals/$scheduleId/reflection'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reflection': teks}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offAllNamed(AppRoutes.mainPage);
        Get.snackbar('Berhasil', 'Refleksi berhasil disimpan',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Gagal', data['message'] ?? 'Gagal menyimpan refleksi',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  void lewati() => Get.offAllNamed(AppRoutes.mainPage);

  void _handleUnauthorized() {
    AuthService.clearToken();
    Get.offAllNamed('/loginPage');
    Get.snackbar('Sesi Berakhir', 'Silakan login kembali',
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  @override
  void onClose() {
    refleksiController.dispose();
    super.onClose();
  }
}