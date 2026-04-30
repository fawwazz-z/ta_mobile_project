import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/services/authService.dart';

class SiswaModel {
  final int    id;
  final String nama;
  final String nis;
  String       status; // HADIR | IZIN | SAKIT | ALPA

  SiswaModel({
    required this.id,
    required this.nama,
    required this.nis,
    this.status = '',
  });

  factory SiswaModel.fromJson(Map<String, dynamic> j) {
    return SiswaModel(
      id:     j['id']   as int,
      nama:   j['nama'] ?? j['name'] ?? '-',
      nis:    j['nis']  ?? '-',
      status: j['status'] ?? '',
    );
  }
}

class PresensiSiswaController extends GetxController {
  var isLoading  = false.obs;
  var isSaving   = false.obs;
  var siswaList  = <SiswaModel>[].obs;
  var errorMsg   = ''.obs;

  // data jurnal yang di-pass via Get.arguments
  late final int    jurnalId;
  late final String kelasNama;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    jurnalId  = args['jurnal_id'] as int? ?? 0;
    kelasNama = args['kelas']     as String? ?? 'Kelas';
    fetchSiswa();
  }

  Future<void> fetchSiswa() async {
    try {
      isLoading.value = true;
      errorMsg.value  = '';

      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('https://kelompok14.rplrus.com/api/jurnal/$jurnalId/siswa'),
        headers: {
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List raw = body is List ? body : (body['data'] ?? []);
        siswaList.value =
            raw.map((e) => SiswaModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat data siswa';
      }
    } catch (_) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
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

  Future<void> simpanPresensi() async {
    final belumDiisi = siswaList.where((s) => s.status.isEmpty).toList();
    if (belumDiisi.isNotEmpty) {
      Get.snackbar('Perhatian', 'Semua siswa harus diisi statusnya',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final token = await AuthService.getToken();

      final payload = {
        'jurnal_id': jurnalId,
        'presensi': siswaList
            .map((s) => {'siswa_id': s.id, 'status': s.status})
            .toList(),
      };

      final response = await http.post(
        Uri.parse('https://kelompok14.rplrus.com/api/presensi'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar('Berhasil', 'Presensi berhasil disimpan',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Gagal', data['message'] ?? 'Gagal menyimpan presensi',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  void _handleUnauthorized() {
    AuthService.clearToken();
    Get.offAllNamed('/loginPage');
    Get.snackbar('Sesi Berakhir', 'Silakan login kembali',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}