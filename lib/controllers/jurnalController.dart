import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ta_mobile_project/services/authService.dart';

class JurnalModel {
  final int    id;
  final String kelas;
  final String mapel;
  final String waktu;
  final String idKode;

  const JurnalModel({
    required this.id,
    required this.kelas,
    required this.mapel,
    required this.waktu,
    required this.idKode,
  });

  factory JurnalModel.fromJson(Map<String, dynamic> j) {
    return JurnalModel(
      id:     j['id'] as int,
      kelas:  j['kelas']         ?? j['nama_kelas']      ?? '-',
      mapel:  j['mata_pelajaran'] ?? j['mapel']           ?? '-',
      waktu:  j['waktu']         ?? j['jam']              ?? '-',
      idKode: 'ID: J-${j['id']}',
    );
  }
}

class JurnalController extends GetxController {
  var isLoading = false.obs;
  var jurnalList = <JurnalModel>[].obs;
  var errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJurnal();
  }

  Future<void> fetchJurnal() async {
    try {
      isLoading.value = true;
      errorMsg.value  = '';

      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('https://kelompok14.rplrus.com/api/jurnal'),
        headers: {
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // handle both {data:[]} and [] response shapes
        final List raw = body is List ? body : (body['data'] ?? []);
        jurnalList.value =
            raw.map((e) => JurnalModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        errorMsg.value = 'Gagal memuat jurnal';
      }
    } catch (_) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  void _handleUnauthorized() {
    AuthService.clearToken();
    Get.offAllNamed('/loginPage');
    Get.snackbar('Sesi Berakhir', 'Silakan login kembali',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}