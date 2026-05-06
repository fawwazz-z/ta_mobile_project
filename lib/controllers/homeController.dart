import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/services/authService.dart';

class JadwalHariIniModel {
  final int id;
  final String subjectName;
  final String classroomName;
  final int classroomId;
  final String day;
  final String startTime;
  final String endTime;

  const JadwalHariIniModel({
    required this.id,
    required this.subjectName,
    required this.classroomName,
    required this.classroomId,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory JadwalHariIniModel.fromJson(Map<String, dynamic> j) {
    final subject = j['subject'] as Map<String, dynamic>?;
    final classroom = j['classroom'] as Map<String, dynamic>?;

    return JadwalHariIniModel(
      id: (j['id'] as num).toInt(),
      subjectName:
          subject?['name'] as String? ??
          j['subject_name'] as String? ??
          'Mata Pelajaran',
      classroomName:
          classroom?['name'] as String? ??
          j['classroom_name'] as String? ??
          'Kelas',
      classroomId: (j['classroom_id'] as num?)?.toInt() ?? 0,
      day: j['day'] as String? ?? '',
      startTime: j['start_time'] as String? ?? '--:--',
      endTime: j['end_time'] as String? ?? '--:--',
    );
  }
}

class HomeController extends GetxController {
  var teacherName = ''.obs;
  var teacherRole = ''.obs;
  var isLoadingUser = false.obs;
  var isLoadingJadwal = false.obs;
  var jadwalHariIni = <JadwalHariIniModel>[].obs;
  var errorJadwal = ''.obs;

  var totalSiswa = 0.obs;
  var totalHadir = 0.obs;
  var totalIzin = 0.obs;
  var totalSakit = 0.obs;
  var totalAlpa = 0.obs;
  var sudahPresensi = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromLocal();
    fetchJadwalHariIni();
  }

  Future<void> _loadUserFromLocal() async {
    final name = await AuthService.getUserName();
    final role = await AuthService.getUserRole();
    teacherName.value = name ?? 'Guru';
    teacherRole.value = role ?? '';
  }

  /// GET /api/journals/schedules — jadwal mengajar hari ini
  Future<void> fetchJadwalHariIni() async {
    try {
      isLoadingJadwal.value = true;
      errorJadwal.value = '';

      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/journals/schedules'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List raw = body['data'] ?? [];
        jadwalHariIni.value = raw
            .map((e) => JadwalHariIniModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorJadwal.value = 'Gagal memuat jadwal';
      }
    } catch (_) {
      errorJadwal.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoadingJadwal.value = false;
    }
  }

  void updateStatistikPresensi({
    required int hadir,
    required int izin,
    required int sakit,
    required int alpa,
  }) {
    totalHadir.value = hadir;
    totalIzin.value = izin;
    totalSakit.value = sakit;
    totalAlpa.value = alpa;
    totalSiswa.value = hadir + izin + sakit + alpa;
    sudahPresensi.value = true;
  }

  double get persenHadir =>
      totalSiswa.value == 0 ? 0 : (totalHadir.value / totalSiswa.value) * 100;

  int get totalIzinSakit => totalIzin.value + totalSakit.value;

  void refreshData() => fetchJadwalHariIni();

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
