import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/services/authService.dart';

class JadwalModel {
  final int id;
  final String subjectName;
  final String classroomName;
  final String day;
  final String startTime;
  final String endTime;

  const JadwalModel({
    required this.id,
    required this.subjectName,
    required this.classroomName,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> j) {
    final subject = j['subject'] as Map<String, dynamic>?;
    final classroom = j['classroom'] as Map<String, dynamic>?;
    final rawDay = j['day'] as String? ?? '';
    final day = _normalizeDay(rawDay);

    return JadwalModel(
      id: (j['id'] as num).toInt(),
      subjectName:
          subject?['name'] as String? ??
          j['subject_name'] as String? ??
          j['mapel'] as String? ??
          'Mata Pelajaran',
      classroomName:
          classroom?['name'] as String? ??
          j['classroom_name'] as String? ??
          j['kelas'] as String? ??
          'Kelas',
      day: day,
      startTime: _formatTime(j['start_time'] as String? ?? '--:--'),
      endTime: _formatTime(j['end_time'] as String? ?? '--:--'),
    );
  }

  /// Konversi nama hari dari bahasa Inggris → Indonesia jika perlu
  static String _normalizeDay(String raw) {
    const map = {
      'monday': 'Senin',
      'tuesday': 'Selasa',
      'wednesday': 'Rabu',
      'thursday': 'Kamis',
      'friday': 'Jumat',
      'saturday': 'Sabtu',
      'sunday': 'Minggu',
      // jika sudah dalam bahasa Indonesia, kembalikan apa adanya
      'senin': 'Senin',
      'selasa': 'Selasa',
      'rabu': 'Rabu',
      'kamis': 'Kamis',
      'jumat': 'Jumat',
      'sabtu': 'Sabtu',
      'minggu': 'Minggu',
    };
    return map[raw.toLowerCase()] ?? raw;
  }

  static String _formatTime(String t) {
    if (t.length >= 5) return t.substring(0, 5);
    return t;
  }
}

class JadwalController extends GetxController {
  var isLoading = false.obs;
  var jadwalList = <JadwalModel>[].obs;
  var errorMsg = ''.obs;

  final List<String> dayOrder = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchJadwal();
  }

  /// GET /api/schedules  — semua jadwal mengajar (mingguan)
  /// Fallback ke /api/schedules/today jika endpoint semua tidak tersedia
  Future<void> fetchJadwal() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final token = await AuthService.getToken();
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(
        Uri.parse('${AppStatic.base_url}/schedules'),
        headers: headers,
      );

      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http.get(
          Uri.parse('${AppStatic.base_url}/schedules/today'),
          headers: headers,
        );
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Handle berbagai bentuk response:
        // { success, data: [...] }  atau langsung [...]
        List raw;
        if (body is List) {
          raw = body;
        } else if (body is Map) {
          raw = (body['data'] as List?) ?? [];
        } else {
          raw = [];
        }

        jadwalList.value = raw
            .map((e) => JadwalModel.fromJson(e as Map<String, dynamic>))
            .toList();

        if (jadwalList.isEmpty) {
          errorMsg.value = '';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat jadwal (${response.statusCode})';
      }
    } catch (e) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  List<JadwalModel> getByDay(String day) =>
      jadwalList.where((j) => j.day.toLowerCase() == day.toLowerCase()).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime)); // urutkan by jam

  bool get hasJadwal => jadwalList.isNotEmpty;

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
