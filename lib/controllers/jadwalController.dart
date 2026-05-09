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
  final int session;

  const JadwalModel({
    required this.id,
    required this.subjectName,
    required this.classroomName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.session,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> j, String day) {
    return JadwalModel(
      id: (j['id'] as num).toInt(),
      subjectName: j['subject'] as String? ?? 'Mata Pelajaran',
      classroomName: j['classroom'] as String? ?? 'Kelas',
      day: _normalizeDay(day),
      startTime: _formatTime(j['start_time'] as String? ?? '--:--'),
      endTime: _formatTime(j['end_time'] as String? ?? '--:--'),
      session: (j['session'] as num?)?.toInt() ?? 0,
    );
  }

  static String _normalizeDay(String rawDay) {
    const map = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };
    return map[rawDay] ?? rawDay;
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

  // Urutan hari dari Senin sampai Sabtu (Minggu opsional)
  final List<String> dayOrder = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  // Mapping hari Inggris ke Indonesia
  final Map<String, String> _dayMapping = {
    'Monday': 'Senin',
    'Tuesday': 'Selasa',
    'Wednesday': 'Rabu',
    'Thursday': 'Kamis',
    'Friday': 'Jumat',
    'Saturday': 'Sabtu',
    'Sunday': 'Minggu',
  };

  @override
  void onInit() {
    super.onInit();
    fetchJadwal();
  }

  /// GET /api/journals/schedules/all
  Future<void> fetchJadwal() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/journals/schedules/all'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Jadwal Response Status: ${response.statusCode}");
      print("Jadwal Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final Map<String, dynamic> data = body['data'];
          final List<JadwalModel> tempList = [];

          // Iterasi setiap hari yang ada di response
          data.forEach((dayEn, schedules) {
            final dayId = _dayMapping[dayEn] ?? dayEn;
            // Hanya tampilkan hari yang ada di dayOrder (Senin-Sabtu)
            if (dayOrder.contains(dayId)) {
              final List schedulesList = schedules as List;
              for (var schedule in schedulesList) {
                tempList.add(JadwalModel.fromJson(schedule, dayEn));
              }
            }
          });

          jadwalList.value = tempList;

          if (jadwalList.isEmpty) {
            errorMsg.value = '';
          }
        } else {
          errorMsg.value = body['message'] ?? 'Gagal memuat jadwal';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat jadwal (${response.statusCode})';
      }
    } catch (e, stacktrace) {
      print("Error fetchJadwal: $e");
      print("Stacktrace: $stacktrace");
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  /// Get jadwal berdasarkan hari (dalam Bahasa Indonesia)
  List<JadwalModel> getByDay(String day) {
    return jadwalList
        .where((j) => j.day.toLowerCase() == day.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool get hasJadwal => jadwalList.isNotEmpty;

  void refreshData() => fetchJadwal();

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
