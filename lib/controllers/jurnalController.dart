import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/services/authService.dart';

class JurnalHistoryModel {
  final int id;
  final int journalId;
  final String date;
  final String subjectName;
  final String classroomName;
  final int classroomId;
  final String day;
  final String startTime;
  final String endTime;
  final bool isJournalFilled;

  const JurnalHistoryModel({
    required this.id,
    required this.journalId,
    required this.date,
    required this.subjectName,
    required this.classroomName,
    required this.classroomId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isJournalFilled,
  });

  factory JurnalHistoryModel.fromJson(Map<String, dynamic> j) {
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

    return JurnalHistoryModel(
      id: (j['id'] as num).toInt(),
      journalId: (j['journal_id'] as num?)?.toInt() ?? 0,
      date: j['date'] as String? ?? '',
      subjectName: subject?['name'] as String? ?? 'Mata Pelajaran',
      classroomName: classroom?['name'] as String? ?? 'Kelas',
      classroomId: (classroom?['id'] as num?)?.toInt() ?? 0,
      day: j['day'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      isJournalFilled: j['is_journal_filled'] as bool? ?? false,
    );
  }
}

class JurnalController extends GetxController {
  var isLoading = false.obs;
  var jurnalList = <JurnalHistoryModel>[].obs;
  var errorMsg = ''.obs;

  // Month & Year State
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  final List<String> _monthNames = [
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
      '${_monthNames[selectedMonth.value - 1]} ${selectedYear.value}';

  void previousMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value--;
    } else {
      selectedMonth.value--;
    }
    fetchJurnalHistory();
  }

  void nextMonth() {
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value++;
    } else {
      selectedMonth.value++;
    }
    fetchJurnalHistory();
  }

  @override
  void onInit() {
    super.onInit();
    fetchJurnalHistory();
  }

  /// GET /api/journals/history?month={month}&year={year}
  Future<void> fetchJurnalHistory() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final token = await AuthService.getToken();
      final url =
          '${AppStatic.base_url}/journals/history'
          '?month=${selectedMonth.value}&year=${selectedYear.value}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List raw = body['data'] ?? [];
        jurnalList.value = raw
            .map((e) => JurnalHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat jurnal';
      }
    } catch (e) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() => fetchJurnalHistory();

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
