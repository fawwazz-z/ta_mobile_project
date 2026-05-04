import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class SiswaModel {
  final int    id;
  final String nama;
  final String nis;
  String       status; // hadir | izin | sakit | alpa

  SiswaModel({
    required this.id,
    required this.nama,
    required this.nis,
    this.status = '',
  });

  factory SiswaModel.fromJson(Map<String, dynamic> j) {
    return SiswaModel(
      id:   (j['id'] as num).toInt(),
      nama: j['name'] as String? ?? j['nama'] as String? ?? '-',
      nis:  j['nis']  as String? ?? '-',
      // Status bisa sudah terisi jika presensi sudah ada
      status: j['status'] as String? ?? '',
    );
  }
}

class PresensiSiswaController extends GetxController {
  var isLoading = false.obs;
  var isSaving  = false.obs;
  var siswaList = <SiswaModel>[].obs;
  var errorMsg  = ''.obs;

  // Data dari argument navigasi
  late final int    scheduleId;   // teaching_schedule_id
  late final String kelasNama;
  late final String mapelNama;
  late final String jamMulai;
  late final String jamSelesai;

  @override
  void onInit() {
    super.onInit();
    final args    = Get.arguments as Map<String, dynamic>? ?? {};
    scheduleId    = args['schedule_id'] as int?    ?? 0;
    kelasNama     = args['kelas']       as String? ?? 'Kelas';
    mapelNama     = args['mapel']       as String? ?? '';
    jamMulai      = args['start_time']  as String? ?? '';
    jamSelesai    = args['end_time']    as String? ?? '';
    fetchSiswa();
  }

  /// GET /api/schedules/{schedule_id}/students
  /// Response: { success, classroom, data: [{id, classroom_id, name, nis, ...}] }
  Future<void> fetchSiswa() async {
    try {
      isLoading.value = true;
      errorMsg.value  = '';

      final token    = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
            'https://kelompok14.rplrus.com/api/schedules/$scheduleId/students'),
        headers: {
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List raw = body is List ? body : (body['data'] ?? []);
        siswaList.value = raw
            .map((e) => SiswaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat data siswa';
      }
    } catch (_) {
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
  /// Body: { teaching_schedule_id, material, attendances: [{student_id, status}] }
  Future<void> simpanPresensi({required String material}) async {
    final belumDiisi = siswaList.where((s) => s.status.isEmpty).toList();
    if (belumDiisi.isNotEmpty) {
      Get.snackbar('Perhatian', 'Semua siswa harus diisi statusnya',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final token    = await AuthService.getToken();

      final payload = {
        'teaching_schedule_id': scheduleId,
        'material': material,
        'attendances': siswaList
            .map((s) => {
                  'student_id': s.id,
                  'status':     s.status.toLowerCase(), // hadir|izin|sakit|alpa
                })
            .toList(),
      };

      final response = await http.post(
        Uri.parse('https://kelompok14.rplrus.com/api/journals/attendance'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigasi ke halaman refleksi, kirim schedule_id
        Get.toNamed(
          AppRoutes.refleksipage,
          arguments: {
            'schedule_id': scheduleId,
            'kelas':       kelasNama,
            'mapel':       mapelNama,
          },
        );
        Get.snackbar('Berhasil', 'Presensi berhasil disimpan',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Gagal', data['message'] ?? 'Gagal menyimpan presensi',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  void _handleUnauthorized() {
    AuthService.clearToken();
    Get.offAllNamed('/loginPage');
    Get.snackbar('Sesi Berakhir', 'Silakan login kembali',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}