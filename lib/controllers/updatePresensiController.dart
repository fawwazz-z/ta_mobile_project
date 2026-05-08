import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/services/authService.dart';

class SiswaUpdateModel {
  final int id;
  final String nama;
  final String nis;
  String status;

  SiswaUpdateModel({
    required this.id,
    required this.nama,
    required this.nis,
    required this.status,
  });
}

class UpdatePresensiController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var siswaList = <SiswaUpdateModel>[].obs;
  var errorMsg = ''.obs;
  var materi = ''.obs;
  var journalId = 0.obs;
  var refleksi = ''.obs;

  late final int classroomId;
  late final int scheduleId;
  late final String kelasNama;
  late final String mapelNama;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    scheduleId = args['schedule_id'] as int? ?? 0;
    kelasNama = args['kelas'] as String? ?? 'Kelas';
    mapelNama = args['mapel'] as String? ?? '';
    classroomId = args['classroom_id'] as int? ?? 0;

    fetchDetailJurnal();
  }

  /// GET /api/journals/{scheduleId}/detail
  Future<void> fetchDetailJurnal() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final token = await AuthService.getToken();
      final url = '${AppStatic.base_url}/journals/$scheduleId/detail';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final data = body['data'];

          journalId.value = data['id'] ?? 0;
          materi.value = data['material'] ?? '';
          refleksi.value = data['reflection'] ?? '';

          final List attendances = data['attendances'] ?? [];

          siswaList.value = attendances.map((a) {
            final student = a['student'];
            return SiswaUpdateModel(
              id: student['id'] as int? ?? 0,
              nama: student['name'] as String? ?? '-',
              nis: student['nis'] as String? ?? '-',
              status: a['status'] as String? ?? '',
            );
          }).toList();

          if (siswaList.isEmpty) {
            errorMsg.value = 'Data siswa tidak ditemukan';
          }
        } else {
          errorMsg.value = 'Gagal memuat data presensi';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value =
            'Gagal memuat data presensi (Code: ${response.statusCode})';
      }
    } catch (e) {
      print("ERROR fetchDetailJurnal: $e");
      errorMsg.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setStatus(int siswaId, String status) {
    final idx = siswaList.indexWhere((s) => s.id == siswaId);
    if (idx != -1) {
      siswaList[idx].status = status;
      siswaList.refresh();
    }
  }

  /// PUT /api/journals/{journalId}/update
  Future<void> updatePresensi({required String material}) async {
    final belumDiisi = siswaList.where((s) => s.status.isEmpty).toList();

    if (belumDiisi.isNotEmpty) {
      Get.snackbar(
        'Perhatian',
        'Semua siswa harus diisi statusnya',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (material.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Materi pembelajaran harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;
      final token = await AuthService.getToken();

      final payload = {
        'material': material,
        'attendances': siswaList
            .map((s) => {'student_id': s.id, 'status': s.status.toLowerCase()})
            .toList(),
      };

      final response = await http.put(
        Uri.parse('${AppStatic.base_url}/journals/${journalId.value}/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Update statistik ke HomeController
        final hadir = siswaList.where((s) => s.status == 'hadir').length;
        final izin = siswaList.where((s) => s.status == 'izin').length;
        final sakit = siswaList.where((s) => s.status == 'sakit').length;
        final alpa = siswaList.where((s) => s.status == 'alpa').length;

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().updateStatistikPresensi(
            hadir: hadir,
            izin: izin,
            sakit: sakit,
            alpa: alpa,
          );
          Get.find<HomeController>().refreshData();
        }

        Get.snackbar(
          'Berhasil',
          'Presensi berhasil diupdate',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );

        // Kembali ke home
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/mainPage');
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal mengupdate presensi',
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
