import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/services/authService.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class AttendanceRecord {
  final int id;
  final int userId;
  final String attendanceDate;
  final String checkInTime;
  final String checkOutTime;
  final String checkInStatus;
  final String checkOutStatus;
  final String notes;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInStatus,
    required this.checkOutStatus,
    required this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      attendanceDate: json['attendance_date'] ?? '',
      checkInTime: json['check_in_time'] ?? '',
      checkOutTime: json['check_out_time'] ?? '',
      checkInStatus: json['check_in_status'] ?? '',
      checkOutStatus: json['check_out_status'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(attendanceDate).toLocal();
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return attendanceDate;
    }
  }

  String get formattedCheckIn {
    if (checkInTime.isEmpty || checkInTime == 'null') return '--:--';
    try {
      final dt = DateTime.parse(checkInTime).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return checkInTime.length >= 5
          ? checkInTime.substring(0, 5)
          : checkInTime;
    }
  }

  String get formattedCheckOut {
    if (checkOutTime.isEmpty || checkOutTime == 'null') return '--:--';
    try {
      final dt = DateTime.parse(checkOutTime).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return checkOutTime.length >= 5
          ? checkOutTime.substring(0, 5)
          : checkOutTime;
    }
  }

  String get displayStatus {
    final s = checkInStatus.toLowerCase();
    if (s == 'on_time') return 'Hadir';
    if (s == 'late') return 'Terlambat';
    if (s == 'sick') return 'Sakit';
    if (s == 'permission') return 'Izin';
    if (s == 'absent') return 'Absen';
    return checkInStatus.isEmpty ? 'Hadir' : checkInStatus;
  }

  int get month {
    try {
      return DateTime.parse(attendanceDate).toLocal().month;
    } catch (_) {
      return 0;
    }
  }

  int get year {
    try {
      return DateTime.parse(attendanceDate).toLocal().year;
    } catch (_) {
      return 0;
    }
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────
class RiwayatController extends GetxController {
  final RxList<AttendanceRecord> allRecords = <AttendanceRecord>[].obs;
  final RxList<AttendanceRecord> filteredRecords = <AttendanceRecord>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxString searchQuery = ''.obs;

  static const _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String get selectedMonthLabel =>
      '${_monthNames[selectedMonth.value]} ${selectedYear.value}';

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    ever(searchQuery, (_) => _applyFilter());
    ever(selectedMonth, (_) => _applyFilter());
    ever(selectedYear, (_) => _applyFilter());
  }

  // ── Fetch dari API ──────────────────────────────────────────────────────────
  Future<void> fetchHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Pakai AuthService._keyToken = 'auth_token'
      final token = await AuthService.getToken() ?? '';

      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/attendance/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          final data = (body['data'] as List<dynamic>?) ?? [];
          allRecords.value = data
              .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
              .toList();

          // Urutkan terbaru di atas
          allRecords.sort((a, b) {
            try {
              return DateTime.parse(
                b.attendanceDate,
              ).compareTo(DateTime.parse(a.attendanceDate));
            } catch (_) {
              return 0;
            }
          });

          _applyFilter();
        } else {
          errorMessage.value = body['message'] ?? 'Gagal memuat data';
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Sesi habis, silakan login ulang';
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (_) {
      errorMessage.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Filter bulan + search ───────────────────────────────────────────────────
  void _applyFilter() {
    var result = allRecords
        .where(
          (r) => r.month == selectedMonth.value && r.year == selectedYear.value,
        )
        .toList();

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (r) =>
                r.formattedDate.toLowerCase().contains(q) ||
                r.displayStatus.toLowerCase().contains(q) ||
                r.formattedCheckIn.contains(q) ||
                r.formattedCheckOut.contains(q),
          )
          .toList();
    }

    filteredRecords.value = result;
  }

  // ── Navigasi bulan ──────────────────────────────────────────────────────────
  void previousMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value = selectedYear.value - 1;
    } else {
      selectedMonth.value = selectedMonth.value - 1;
    }
  }

  void nextMonth() {
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value = selectedYear.value + 1;
    } else {
      selectedMonth.value = selectedMonth.value + 1;
    }
  }

  // ── Search ──────────────────────────────────────────────────────────────────
  void onSearchChanged(String v) => searchQuery.value = v;
  void clearSearch() => searchQuery.value = '';
}
