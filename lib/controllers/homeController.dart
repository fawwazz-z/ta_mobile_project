import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';

class JadwalHariIniModel {
  final int id;
  final int journalId;
  final String subjectName;
  final String classroomName;
  final int classroomId;
  final String day;
  final String startTime;
  final String endTime;
  final bool isJournalFilled;
  final bool hasReflection;

  const JadwalHariIniModel({
    required this.id,
    required this.journalId,
    required this.subjectName,
    required this.classroomName,
    required this.classroomId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isJournalFilled,
    required this.hasReflection,
  });

  factory JadwalHariIniModel.fromJson(Map<String, dynamic> j) {
    final subject = j['subject'] as Map<String, dynamic>?;
    final classroom = j['classroom'] as Map<String, dynamic>?;
    final lessonHour = j['lesson_hour'] as Map<String, dynamic>?;

    String startTime = '--:--';
    String endTime = '--:--';

    if (lessonHour != null) {
      startTime =
          (lessonHour['start_time'] as String?)?.substring(0, 5) ?? '--:--';
      endTime = (lessonHour['end_time'] as String?)?.substring(0, 5) ?? '--:--';
    }

    return JadwalHariIniModel(
      id: (j['id'] as num).toInt(),
      journalId: (j['journal_id'] as num?)?.toInt() ?? 0,
      subjectName: subject?['name'] as String? ?? 'Mata Pelajaran',
      classroomName: classroom?['name'] as String? ?? 'Kelas',
      classroomId: (classroom?['id'] as num?)?.toInt() ?? 0,
      day: j['day'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      isJournalFilled: j['is_journal_filled'] as bool? ?? false,
      hasReflection: j['has_reflection'] as bool? ?? false,
    );
  }
}

class HomeController extends GetxController {
  // Jam sekolah (batas waktu)
  var jamMasukSekolah = '07:00'.obs;
  var jamPulangSekolah = '17:00'.obs;

  // Jam presensi aktual guru
  var jamMasukDisplay = '--:--'.obs;
  var jamPulangDisplay = '--:--'.obs;

  // Data user
  var teacherName = ''.obs;
  var teacherRole = ''.obs;
  var isLoadingUser = false.obs;

  // Jadwal
  var isLoadingJadwal = false.obs;
  var jadwalHariIni = <JadwalHariIniModel>[].obs;
  var errorJadwal = ''.obs;

  // Status refleksi per schedule
  var refleksiStatus = <int, bool>{}.obs;

  // Statistik presensi siswa
  var totalSiswa = 0.obs;
  var totalHadir = 0.obs;
  var totalIzin = 0.obs;
  var totalSakit = 0.obs;
  var totalAlpa = 0.obs;
  var sudahPresensi = false.obs;

  // Status presensi guru hari ini
  var presensiMasuk = ''.obs;
  var presensiPulang = ''.obs;

  bool get sudahCheckIn => presensiMasuk.value.isNotEmpty;
  bool get sudahCheckOut => presensiPulang.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromLocal();
    fetchAttendanceHariIni();
    fetchJadwalHariIni();
  }

  Future<void> _loadUserFromLocal() async {
    final name = await AuthService.getUserName();
    final role = await AuthService.getUserRole();
    teacherName.value = name ?? 'Guru';
    teacherRole.value = role ?? '';
  }

  // ── Fetch attendance hari ini ──────────────────────────────────────────────
  Future<void> fetchAttendanceHariIni() async {
    try {
      final token = await AuthService.getToken() ?? '';
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/attendance/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final List data = body['data'] ?? [];

        // Tanggal hari ini dalam lokal (WIB)
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        Map<String, dynamic>? todayRecord;
        for (final item in data) {
          final record = item as Map<String, dynamic>;
          final dateRaw = record['attendance_date'] as String? ?? '';

          if (dateRaw.isEmpty) continue;

          // Parse UTC lalu convert ke lokal untuk perbandingan tanggal
          final dt = DateTime.tryParse(dateRaw)?.toLocal();
          if (dt == null) continue;

          final recordDate = DateTime(dt.year, dt.month, dt.day);

          // check_in_time juga dalam UTC, pakai itu sebagai acuan tanggal lokal
          // karena attendance_date bisa berbeda 1 hari akibat timezone
          final checkInRaw = record['check_in_time'] as String? ?? '';
          DateTime? checkInLocal;
          if (checkInRaw.isNotEmpty && checkInRaw != 'null') {
            checkInLocal = DateTime.tryParse(checkInRaw)?.toLocal();
          }

          // Cocokkan dengan hari ini:
          // - via attendance_date yang sudah dikonversi ke lokal, ATAU
          // - via check_in_time yang sudah dikonversi ke lokal
          final matchByDate = recordDate == today;
          final matchByCheckIn =
              checkInLocal != null &&
              DateTime(
                    checkInLocal.year,
                    checkInLocal.month,
                    checkInLocal.day,
                  ) ==
                  today;

          if (matchByDate || matchByCheckIn) {
            todayRecord = record;
            break;
          }
        }

        if (todayRecord != null) {
          final checkInRaw = todayRecord['check_in_time'] as String? ?? '';
          final checkOutRaw = todayRecord['check_out_time'] as String? ?? '';

          if (checkInRaw.isNotEmpty && checkInRaw != 'null') {
            final formatted = _formatTime(checkInRaw);
            presensiMasuk.value = formatted;
            jamMasukDisplay.value = formatted;
          } else {
            presensiMasuk.value = '';
            jamMasukDisplay.value = '--:--';
          }

          if (checkOutRaw.isNotEmpty && checkOutRaw != 'null') {
            final formatted = _formatTime(checkOutRaw);
            presensiPulang.value = formatted;
            jamPulangDisplay.value = formatted;
          } else {
            presensiPulang.value = '';
            jamPulangDisplay.value = '--:--';
          }
        } else {
          presensiMasuk.value = '';
          presensiPulang.value = '';
          jamMasukDisplay.value = '--:--';
          jamPulangDisplay.value = '--:--';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (_) {
      // Gagal diam-diam
    }
  }

  // ── Jadwal hari ini ────────────────────────────────────────────────────────
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
        } catch (_) {
          refleksiStatus[jadwal.id] = false;
        }
      } else {
        refleksiStatus[jadwal.id] = false;
      }
    }
  }

  bool getReflectionStatus(int scheduleId) =>
      refleksiStatus[scheduleId] ?? false;

  void updateReflectionStatus(int scheduleId, bool hasReflection) =>
      refleksiStatus[scheduleId] = hasReflection;

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

  Future<void> refreshData() async {
    await Future.wait([fetchAttendanceHariIni(), fetchJadwalHariIni()]);
  }

  // ── Validasi Waktu Presensi ────────────────────────────────────────────────
  void handlePresensiClick() {
    final now = DateTime.now();

    // 1. Sudah Selesai Presensi Masuk & Pulang
    if (sudahCheckIn && sudahCheckOut) {
      _showWarningDialog(
        'Presensi Selesai',
        'Anda telah menyelesaikan presensi masuk dan pulang untuk hari ini.',
      );
      return;
    }

    // 2. Belum Presensi Masuk (Shift Pagi: 07:00 - 09:00)
    if (!sudahCheckIn) {
      final startCheckIn = _parseTimeToToday(
        jamMasukSekolah.value.isNotEmpty ? jamMasukSekolah.value : '07:00',
      );
      final endCheckIn = _parseTimeToToday('09:00');

      if (now.isBefore(startCheckIn)) {
        _showWarningDialog(
          'Belum Waktunya Presensi',
          'Presensi masuk belum dibuka. Silakan kembali pada pukul ${jamMasukSekolah.value} WIB.',
        );
        return;
      }

      if (now.isAfter(endCheckIn)) {
        _showWarningDialog(
          'Waktu Presensi Berakhir',
          'Batas waktu presensi masuk (09:00 WIB) telah berakhir.',
        );
        return;
      }

      Get.toNamed(AppRoutes.presensipage);
      return;
    }

    // 3. Sudah Check-In, Belum Check-Out (Shift Pagi: 17:00 - 19:00)
    if (sudahCheckIn && !sudahCheckOut) {
      final startCheckOut = _parseTimeToToday(
        jamPulangSekolah.value.isNotEmpty ? jamPulangSekolah.value : '17:00',
      );
      final endCheckOut = _parseTimeToToday('19:00');

      if (now.isBefore(startCheckOut)) {
        _showWarningDialog(
          'Belum Waktunya Pulang',
          'Presensi pulang belum dibuka. Silakan kembali pada pukul ${jamPulangSekolah.value} WIB.',
        );
        return;
      }

      if (now.isAfter(endCheckOut)) {
        _showWarningDialog(
          'Waktu Presensi Berakhir',
          'Batas waktu presensi pulang (19:00 WIB) telah berakhir.',
        );
        return;
      }

      Get.toNamed(AppRoutes.presensipage);
      return;
    }
  }

  DateTime _parseTimeToToday(String timeStr) {
    final now = DateTime.now();
    final clean = timeStr.trim();
    final parts = clean.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
    return now;
  }

  void _showWarningDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Format waktu UTC → lokal HH:mm
  String _formatTime(String raw) {
    if (raw.isEmpty || raw == 'null') return '--:--';
    // ISO format dari API selalu UTC, convert ke lokal
    if (raw.contains('T')) {
      final dt = DateTime.tryParse(raw)?.toLocal();
      if (dt != null) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }
    final parts = raw.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return raw;
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