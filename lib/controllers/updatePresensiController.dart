import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/services/authService.dart';

class SiswaUpdateModel {
  final int id;
  final String nama;
  final String nis;
  String status;

  SiswaUpdateModel({
    required this.id,
    required this.nama,
    required this.nis,
    required this.status,
  });
}

class UpdatePresensiController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var siswaList = <SiswaUpdateModel>[].obs;
  var errorMsg = ''.obs;
  var materi = ''.obs;
  var journalId = 0.obs;
  var refleksi = ''.obs;

  late final int classroomId;
  late final int scheduleId;
  late final int journalIdFromArgs; // Untuk menerima journal_id dari arguments
  late final String kelasNama;
  late final String mapelNama;
  late final String jamMulai;
  late final String jamSelesai;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    // Ambil semua parameter
    scheduleId = args['schedule_id'] as int? ?? 0;
    journalIdFromArgs = args['journal_id'] as int? ?? 0; // 🔥 Dari JurnalPage
    kelasNama = args['kelas'] as String? ?? 'Kelas';
    mapelNama = args['mapel'] as String? ?? '';
    jamMulai = args['start_time'] as String? ?? '';
    jamSelesai = args['end_time'] as String? ?? '';
    classroomId = args['classroom_id'] as int? ?? 0;

    print("=== UPDATE PRESENSI DEBUG ===");
    print("scheduleId: $scheduleId");
    print("journalIdFromArgs: $journalIdFromArgs");
    print("kelasNama: $kelasNama");
    print("mapelNama: $mapelNama");

    fetchDetailJurnal();
  }

  /// GET detail jurnal - Mendukung 2 skenario:
  /// 1. Jika ada journal_id → panggil /journals/journal/{journalId} (Endpoint BARU)
  /// 2. Jika tidak ada → panggil /journals/{scheduleId}/detail
  Future<void> fetchDetailJurnal() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      final token = await AuthService.getToken();
      late final String url;

      // 🔥 PRIORITAS: Gunakan journal_id jika ada (untuk data history)
      if (journalIdFromArgs != 0) {
        // SKENARIO 1: Data lama (history) - ENDPOINT BARU
        url = '${AppStatic.base_url}/journals/journal/$journalIdFromArgs';
        print("Menggunakan URL (dengan journal_id): $url");
      } else if (scheduleId != 0) {
        // SKENARIO 2: Data baru (belum diisi) - endpoint lama
        url = '${AppStatic.base_url}/journals/$scheduleId/detail';
        print("Menggunakan URL (dengan schedule_id): $url");
      } else {
        errorMsg.value = 'Data tidak valid (schedule_id dan journal_id kosong)';
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Handle response dengan wrapper 'success'
        Map<String, dynamic> data;
        if (body['success'] == true && body['data'] != null) {
          data = body['data'] as Map<String, dynamic>;
        } else if (body['id'] != null) {
          data = body;
        } else {
          errorMsg.value = 'Format response tidak dikenali';
          return;
        }

        journalId.value = data['id'] ?? 0;
        materi.value = data['material'] ?? '';
        refleksi.value = data['reflection'] ?? '';

        // Ambil attendances (bisa di 'attendances' atau langsung)
        List attendances = [];
        if (data['attendances'] != null) {
          attendances = data['attendances'] as List;
        }

        print("Jumlah attendances: ${attendances.length}");

        siswaList.value = attendances.map((a) {
          // Student data bisa di 'student' atau langsung
          Map<String, dynamic> studentData;
          if (a['student'] != null) {
            studentData = a['student'] as Map<String, dynamic>;
          } else {
            studentData = a;
          }

          return SiswaUpdateModel(
            id: studentData['id'] as int? ?? 0,
            nama:
                studentData['name'] as String? ??
                studentData['nama'] as String? ??
                '-',
            nis: studentData['nis'] as String? ?? '-',
            status: a['status'] as String? ?? '',
          );
        }).toList();

        if (siswaList.isEmpty) {
          errorMsg.value = 'Data siswa tidak ditemukan';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else if (response.statusCode == 404) {
        errorMsg.value =
            'Data presensi tidak ditemukan. Pastikan jurnal sudah dibuat.';
      } else {
        errorMsg.value =
            'Gagal memuat data presensi (Code: ${response.statusCode})';
      }
    } catch (e, stacktrace) {
      print("ERROR fetchDetailJurnal: $e");
      print("STACKTRACE: $stacktrace");
      errorMsg.value = 'Terjadi kesalahan: $e';
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

  /// PUT /api/journals/{journalId}/update
  Future<void> updatePresensi({required String material}) async {
    final belumDiisi = siswaList.where((s) => s.status.isEmpty).toList();

    if (belumDiisi.isNotEmpty) {
      Get.snackbar(
        'Perhatian',
        'Semua siswa harus diisi statusnya',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (material.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Materi pembelajaran harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (journalId.value == 0) {
      Get.snackbar(
        'Error',
        'ID Jurnal tidak ditemukan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;
      final token = await AuthService.getToken();

      final payload = {
        'material': material,
        'attendances': siswaList
            .map((s) => {'student_id': s.id, 'status': s.status.toLowerCase()})
            .toList(),
      };

      print("Update Payload: ${jsonEncode(payload)}");
      print(
        "Update URL: ${AppStatic.base_url}/journals/${journalId.value}/update",
      );

      final response = await http.put(
        Uri.parse('${AppStatic.base_url}/journals/${journalId.value}/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      print("Update Response Status: ${response.statusCode}");
      print("Update Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final hadir = siswaList.where((s) => s.status == 'hadir').length;
        final izin = siswaList.where((s) => s.status == 'izin').length;
        final sakit = siswaList.where((s) => s.status == 'sakit').length;
        final alpa = siswaList.where((s) => s.status == 'alpa').length;

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().updateStatistikPresensi(
            hadir: hadir,
            izin: izin,
            sakit: sakit,
            alpa: alpa,
          );
          Get.find<HomeController>().refreshData();
        }

        Get.snackbar(
          'Berhasil',
          'Presensi berhasil diupdate',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/home');
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'Gagal',
          'Data jurnal tidak ditemukan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        try {
          final data = jsonDecode(response.body);
          Get.snackbar(
            'Gagal',
            data['message'] ?? 'Gagal mengupdate presensi',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (_) {
          Get.snackbar(
            'Gagal',
            'Gagal mengupdate presensi',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print("ERROR update: $e");
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
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
