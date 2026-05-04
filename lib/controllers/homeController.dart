import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/services/authService.dart';

/// Model untuk satu slot jadwal mengajar
class JadwalHariIniModel {
  final int    id;
  final String subjectName;  // dari relasi subject
  final String classroomName; // dari relasi classroom
  final String day;
  final String startTime;
  final String endTime;

  const JadwalHariIniModel({
    required this.id,
    required this.subjectName,
    required this.classroomName,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory JadwalHariIniModel.fromJson(Map<String, dynamic> j) {
    // API: {id, user_id, subject_id, classroom_id, day, start_time, end_time, ...}
    // Relasi subject/classroom mungkin di-load as nested object atau hanya id
    final subject   = j['subject']   as Map<String, dynamic>?;
    final classroom = j['classroom'] as Map<String, dynamic>?;

    return JadwalHariIniModel(
      id:            (j['id'] as num).toInt(),
      subjectName:   subject?['name']   as String? ?? j['subject_name']   as String? ?? 'Mata Pelajaran',
      classroomName: classroom?['name'] as String? ?? j['classroom_name'] as String? ?? 'Kelas',
      day:           j['day']        as String? ?? '',
      startTime:     j['start_time'] as String? ?? '--:--',
      endTime:       j['end_time']   as String? ?? '--:--',
    );
  }
}

class HomeController extends GetxController {
  var teacherName    = ''.obs;
  var teacherRole    = ''.obs;
  var isLoadingUser  = false.obs;
  var isLoadingJadwal = false.obs;
  var jadwalHariIni  = <JadwalHariIniModel>[].obs;
  var errorJadwal    = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromLocal();
    fetchJadwalHariIni();
  }

  /// Ambil nama & role dari SharedPreferences (sudah disimpan saat login)
  Future<void> _loadUserFromLocal() async {
    final name = await AuthService.getUserName();
    final role = await AuthService.getUserRole();
    teacherName.value = name ?? 'Guru';
    teacherRole.value = role ?? '';
  }

  /// GET /api/schedules/today  — jadwal mengajar hari ini
  Future<void> fetchJadwalHariIni() async {
    try {
      isLoadingJadwal.value = true;
      errorJadwal.value     = '';

      final token    = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('https://kelompok14.rplrus.com/api/schedules/today'),
        headers: {
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Response: {success: true, data: [...]}
        final List raw = body is List ? body : (body['data'] ?? []);
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

  void refreshData() => fetchJadwalHariIni();

  void _handleUnauthorized() {
    AuthService.clearToken();
    Get.offAllNamed('/loginPage');
    Get.snackbar('Sesi Berakhir', 'Silakan login kembali',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}