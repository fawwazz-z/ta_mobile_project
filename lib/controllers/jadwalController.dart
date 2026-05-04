import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/services/authService.dart';

class JadwalModel {
  final int    id;
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
    final subject   = j['subject']   as Map<String, dynamic>?;
    final classroom = j['classroom'] as Map<String, dynamic>?;
    return JadwalModel(
      id:            (j['id'] as num).toInt(),
      subjectName:   subject?['name']   as String? ?? j['subject_name']   as String? ?? 'Mata Pelajaran',
      classroomName: classroom?['name'] as String? ?? j['classroom_name'] as String? ?? 'Kelas',
      day:           j['day']        as String? ?? '',
      startTime:     j['start_time'] as String? ?? '--:--',
      endTime:       j['end_time']   as String? ?? '--:--',
    );
  }
}

class JadwalController extends GetxController {
  var isLoading  = false.obs;
  var jadwalList = <JadwalModel>[].obs;
  var errorMsg   = ''.obs;

  // Group by day for display
  final List<String> dayOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  @override
  void onInit() {
    super.onInit();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    try {
      isLoading.value = true;
      errorMsg.value  = '';

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
        final List raw = body is List ? body : (body['data'] ?? []);
        jadwalList.value = raw
            .map((e) => JadwalModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat jadwal';
      }
    } catch (_) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  List<JadwalModel> getByDay(String day) =>
      jadwalList.where((j) => j.day.toLowerCase() == day.toLowerCase()).toList();

  void _handleUnauthorized() {
    AuthService.clearToken();
    Get.offAllNamed('/loginPage');
    Get.snackbar('Sesi Berakhir', 'Silakan login kembali',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}