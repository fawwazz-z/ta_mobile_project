import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class SiswaModel {
  final int id;
  final String nama;
  final String nis;
  String status; // hadir | izin | sakit | alpa

  SiswaModel({
    required this.id,
    required this.nama,
    required this.nis,
    this.status = '',
  });

  factory SiswaModel.fromJson(Map<String, dynamic> j) {
    return SiswaModel(
      id: (j['id'] as num).toInt(),
      nama: j['name'] as String? ?? j['nama'] as String? ?? '-',
      nis: j['nis'] as String? ?? '-',
      status: j['status'] as String? ?? '',
    );
  }
}

class PresensiSiswaController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var siswaList = <SiswaModel>[].obs;
  var errorMsg = ''.obs;

  late final int classroomId;
  late final int scheduleId;
  late final String kelasNama;
  late final String mapelNama;
  late final String jamMulai;
  late final String jamSelesai;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    scheduleId = args['schedule_id'] as int? ?? 0;
    kelasNama = args['kelas'] as String? ?? 'Kelas';
    mapelNama = args['mapel'] as String? ?? '';
    jamMulai = args['start_time'] as String? ?? '';
    jamSelesai = args['end_time'] as String? ?? '';
    classroomId = args['classroom_id'] as int? ?? 0;

    fetchSiswa();
  }

  /// GET /api/journals/students/{classroom_id}
  Future<void> fetchSiswa() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final token = await AuthService.getToken();
      final url = '${AppStatic.base_url}/journals/students/$classroomId';

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
          final List raw = body['data'] ?? [];
          siswaList.value = raw
              .map((e) => SiswaModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          errorMsg.value = 'Data siswa tidak ditemukan';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value =
            'Gagal memuat data siswa (Code: ${response.statusCode})';
      }
    } catch (e) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
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

  /// POST /api/journals/attendance
  Future<void> simpanPresensi({required String material}) async {
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
        'teaching_schedule_id': scheduleId,
        'material': material,
        'attendances': siswaList
            .map((s) => {'student_id': s.id, 'status': s.status.toLowerCase()})
            .toList(),
      };

      final response = await http.post(
        Uri.parse('${AppStatic.base_url}/journals/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Hitung statistik
        final hadir = siswaList.where((s) => s.status == 'hadir').length;
        final izin = siswaList.where((s) => s.status == 'izin').length;
        final sakit = siswaList.where((s) => s.status == 'sakit').length;
        final alpa = siswaList.where((s) => s.status == 'alpa').length;

        // Update statistik ke HomeController
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().updateStatistikPresensi(
            hadir: hadir,
            izin: izin,
            sakit: sakit,
            alpa: alpa,
          );
          // Update status refleksi
          Get.find<HomeController>().updateReflectionStatus(scheduleId, false);
          // Refresh jadwal di home
          Get.find<HomeController>().refreshData();
        }

        // Tampilkan snackbar sukses
        Get.snackbar(
          'Berhasil',
          'Presensi berhasil disimpan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // LANGSUNG KEMBALI KE HOME (tanpa ke refleksi)
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(AppRoutes.mainPage); // Kembali ke halaman home
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal menyimpan presensi',
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
