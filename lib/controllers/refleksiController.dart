import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/services/authService.dart';

class RefleksiController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var refleksiText = ''.obs;
  var journalId = 0.obs;

  late final int scheduleId;
  late final String kelasNama;
  late final String mapelNama;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    scheduleId = args['schedule_id'] as int? ?? 0;
    kelasNama = args['kelas'] as String? ?? 'Kelas';
    mapelNama = args['mapel'] as String? ?? 'Mata Pelajaran';

    if (args['journal_id'] != null) {
      journalId.value = args['journal_id'] as int;
    } else {
      fetchJournalId();
    }

    if (args['reflection'] != null) {
      refleksiText.value = args['reflection'] as String;
    } else {
      fetchExistingRefleksi();
    }
  }

  Future<void> fetchJournalId() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/journals/$scheduleId/detail'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          journalId.value = body['data']['id'] ?? 0;
        }
      }
    } catch (e) {
      print("Error fetch journal id: $e");
    }
  }

  Future<void> fetchExistingRefleksi() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/journals/$scheduleId/detail'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final reflection = body['data']['reflection'] ?? '';
          if (reflection.isNotEmpty) {
            refleksiText.value = reflection;
          }
        }
      }
    } catch (e) {
      print("Error fetch refleksi: $e");
    }
  }

  Future<void> simpanRefleksi() async {
    if (refleksiText.value.trim().isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Refleksi pembelajaran tidak boleh kosong',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (journalId.value == 0) {
      Get.snackbar(
        'Error',
        'Data jurnal tidak ditemukan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;
      final token = await AuthService.getToken();

      final payload = {'reflection': refleksiText.value.trim()};

      final response = await http.post(
        Uri.parse(
          '${AppStatic.base_url}/journals/${journalId.value}/reflection',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().updateReflectionStatus(scheduleId, true);
          Get.find<HomeController>().refreshData();
        }

        Get.snackbar(
          'Berhasil',
          'Refleksi berhasil disimpan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/mainPage');
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal menyimpan refleksi',
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
      isSaving.value = false;
    }
  }

  Future<void> updateRefleksi() async {
    if (refleksiText.value.trim().isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Refleksi pembelajaran tidak boleh kosong',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (journalId.value == 0) {
      Get.snackbar(
        'Error',
        'Data jurnal tidak ditemukan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;
      final token = await AuthService.getToken();

      final payload = {'reflection': refleksiText.value.trim()};

      final response = await http.put(
        Uri.parse(
          '${AppStatic.base_url}/journals/${journalId.value}/reflection',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().updateReflectionStatus(scheduleId, true);
          Get.find<HomeController>().refreshData();
        }

        Get.snackbar(
          'Berhasil',
          'Refleksi berhasil diupdate',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/mainPage');
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal mengupdate refleksi',
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
      isSaving.value = false;
    }
  }

  void _handleUnauthorized() {
    AuthService.clearToken();
    Get.offAllNamed('/loginPage');
    Get.snackbar(
      'Sesi Berakhir',
      'Silakan login kembali',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
