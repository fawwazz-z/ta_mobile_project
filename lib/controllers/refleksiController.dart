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

    print("=== REFLEKSI DEBUG ===");
    print("scheduleId: $scheduleId");
    print("journalId dari args: ${args['journal_id']}");

    // Jika ada journal_id dari arguments, langsung gunakan
    if (args['journal_id'] != null && args['journal_id'] != 0) {
      journalId.value = args['journal_id'] as int;
      fetchExistingRefleksiByJournalId();
    } else {
      // Fallback: cari journal_id berdasarkan schedule_id
      print("Journal ID tidak ditemukan, fetch dari API...");
      fetchJournalIdAndRefleksi();
    }
  }

  /// Ambil journal_id dan refleksi berdasarkan schedule_id
  Future<void> fetchJournalIdAndRefleksi() async {
    try {
      isLoading.value = true;
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/journals/$scheduleId/detail'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Fetch Journal Response Status: ${response.statusCode}");
      print("Fetch Journal Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'];
          journalId.value = data['id'] ?? 0;
          final reflection = data['reflection'] ?? '';
          if (reflection.isNotEmpty) {
            refleksiText.value = reflection;
            print("Refleksi ditemukan: $reflection");
          } else {
            print("Refleksi kosong");
          }
        } else {
          print("Gagal mendapatkan journal");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetch journal id: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Ambil refleksi langsung berdasarkan journal_id
  Future<void> fetchExistingRefleksiByJournalId() async {
    if (journalId.value == 0) return;

    try {
      isLoading.value = true;
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/journals/journal/${journalId.value}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Fetch Refleksi By JournalId Response: ${response.statusCode}");
      print("Fetch Refleksi By JournalId Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Handle response dengan atau tanpa wrapper 'data'
        final data = body['data'] ?? body;
        final reflection = data['reflection'] ?? '';

        print("Refleksi dari API: '$reflection'");

        if (reflection.isNotEmpty) {
          refleksiText.value = reflection;
          print("Refleksi Text diupdate menjadi: ${refleksiText.value}");
        } else {
          print("Refleksi kosong dari API");
          refleksiText.value = '';
        }
      } else if (response.statusCode == 404) {
        print("Journal tidak ditemukan (404)");
        refleksiText.value = '';
      } else {
        print("Error: ${response.statusCode}");
        refleksiText.value = '';
      }
    } catch (e) {
      print("Error fetch refleksi: $e");
      refleksiText.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  /// POST /api/journals/{journalId}/reflection
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
        'Data jurnal tidak ditemukan. Silakan refresh dan coba lagi.',
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

      print("Simpan Refleksi Response: ${response.statusCode}");
      print("Simpan Refleksi Body: ${response.body}");

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
      print("Error simpan refleksi: $e");
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

  /// PUT /api/journals/{journalId}/reflection
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
        'Data jurnal tidak ditemukan. Silakan refresh dan coba lagi.',
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

      print("Update Refleksi Response: ${response.statusCode}");
      print("Update Refleksi Body: ${response.body}");

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
      print("Error update refleksi: $e");
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
