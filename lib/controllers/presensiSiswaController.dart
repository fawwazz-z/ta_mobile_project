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
  String status;

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

    print('=== PresensiSiswaController onInit ===');
    print('classroomId: $classroomId');
    print('scheduleId: $scheduleId');

    fetchSiswa();
  }

  Future<void> fetchSiswa() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final token = await AuthService.getToken();
      final url = '${AppStatic.base_url}/journals/students/$scheduleId';

      print('Fetching siswa dari: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List raw = body['data'] ?? [];
          // ✅ Default status hadir jika kosong
          siswaList.value = raw.map((e) {
            final siswa = SiswaModel.fromJson(e as Map<String, dynamic>);
            if (siswa.status.isEmpty) siswa.status = 'hadir';
            return siswa;
          }).toList();
          print('Jumlah siswa: ${siswaList.length}');
        } else {
          errorMsg.value = 'Data siswa tidak ditemukan';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat data siswa (Code: ${response.statusCode})';
      }
    } catch (e) {
      print('Error fetchSiswa: $e');
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

  Future<void> simpanPresensi({required String material}) async {
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
          Get.find<HomeController>().updateReflectionStatus(scheduleId, false);
          Get.find<HomeController>().refreshData();
        }

        Get.snackbar(
          'Berhasil',
          'Presensi berhasil disimpan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(AppRoutes.mainPage);
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