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
  final bool isJournalFilled;
  final bool hasReflection; // TAMBAHKAN field ini

  const JadwalHariIniModel({
    required this.id,
    required this.subjectName,
    required this.classroomName,
    required this.classroomId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isJournalFilled,
    required this.hasReflection, // TAMBAHKAN
  });

  factory JadwalHariIniModel.fromJson(Map<String, dynamic> j) {
    // Ambil dari nested object
    final subject = j['subject'] as Map<String, dynamic>?;
    final classroom = j['classroom'] as Map<String, dynamic>?;
    final lessonHour = j['lesson_hour'] as Map<String, dynamic>?;

    // Extract start_time & end_time dari lesson_hour
    String startTime = '--:--';
    String endTime = '--:--';

    if (lessonHour != null) {
      startTime =
          (lessonHour['start_time'] as String?)?.substring(0, 5) ?? '--:--';
      endTime = (lessonHour['end_time'] as String?)?.substring(0, 5) ?? '--:--';
    }

    return JadwalHariIniModel(
      id: (j['id'] as num).toInt(),
      subjectName: subject?['name'] as String? ?? 'Mata Pelajaran',
      classroomName: classroom?['name'] as String? ?? 'Kelas',
      classroomId: (classroom?['id'] as num?)?.toInt() ?? 0,
      day: j['day'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      isJournalFilled: j['is_journal_filled'] as bool? ?? false,
      hasReflection:
          j['has_reflection'] as bool? ??
          false, // TAMBAHKAN - ambil dari API jika ada
    );
  }
}

class HomeController extends GetxController {
  // ── Jam sekolah (dari AttendanceSetting) ──────────────────────────────────
  var jamMasukSekolah = '07:15'.obs;
  var jamPulangSekolah = '15:00'.obs;

  // ── Jam presensi aktual guru (dari API response) ───────────────────────────
  var jamMasukDisplay = '--:--'.obs; // check_in_time
  var jamPulangDisplay = '--:--'.obs; // check_out_time

  // ── Data user ─────────────────────────────────────────────────────────────
  var teacherName = ''.obs;
  var teacherRole = ''.obs;
  var isLoadingUser = false.obs;

  // ── Jadwal ─────────────────────────────────────────────────────────────────
  var isLoadingJadwal = false.obs;
  var jadwalHariIni = <JadwalHariIniModel>[].obs;
  var errorJadwal = ''.obs;

  // ── Status refleksi per schedule (cache) ───────────────────────────────────
  var refleksiStatus = <int, bool>{}.obs;

  // ── Statistik presensi siswa ───────────────────────────────────────────────
  var totalSiswa = 0.obs;
  var totalHadir = 0.obs;
  var totalIzin = 0.obs;
  var totalSakit = 0.obs;
  var totalAlpa = 0.obs;
  var sudahPresensi = false.obs;

  // ── Status presensi guru ───────────────────────────────────────────────────
  var presensiMasuk = ''.obs;
  bool get sudahCheckIn => presensiMasuk.value.isNotEmpty;

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

        // Setelah dapat jadwal, fetch status refleksi untuk masing-masing schedule
        await _fetchAllReflectionStatus();
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

  /// Fetch status refleksi untuk semua jadwal yang sudah diisi presensi
  Future<void> _fetchAllReflectionStatus() async {
    final token = await AuthService.getToken();

    for (var jadwal in jadwalHariIni) {
      if (jadwal.isJournalFilled) {
        try {
          final response = await http.get(
            Uri.parse('${AppStatic.base_url}/journals/${jadwal.id}/detail'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            final reflection = body['data']?['reflection'] ?? '';
            refleksiStatus[jadwal.id] = reflection.isNotEmpty;
          }
        } catch (e) {
          print("Error fetch reflection status for schedule ${jadwal.id}: $e");
          refleksiStatus[jadwal.id] = false;
        }
      } else {
        refleksiStatus[jadwal.id] = false;
      }
    }
  }

  /// Get reflection status untuk schedule tertentu
  bool getReflectionStatus(int scheduleId) {
    return refleksiStatus[scheduleId] ?? false;
  }

  /// Update reflection status setelah menyimpan refleksi
  void updateReflectionStatus(int scheduleId, bool hasReflection) {
    refleksiStatus[scheduleId] = hasReflection;
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
