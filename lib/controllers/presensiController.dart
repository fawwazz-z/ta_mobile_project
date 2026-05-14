import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';
import '../controllers/verifikasiController.dart';
import '../routes/colors.dart';

const double _schoolLat = -6.8080000;
const double _schoolLng = 110.8315000;
const double _radiusMeters = 999900.0;

class PresensiController extends GetxController {
  CameraController? cameraController;

  var isCameraReady = false.obs;
  var isTakingPhoto = false.obs;
  var capturedImagePath = ''.obs;

  var isLoadingLocation = true.obs;
  var alamat = ''.obs;
  var koordinat = ''.obs;
  var currentLat = 0.0.obs;
  var currentLng = 0.0.obs;
  var jarakMeter = 0.0.obs;
  var dalamRadius = false.obs;
  var locationError = ''.obs;

  var isSubmitting = false.obs;

  bool get isCheckIn {
    if (Get.isRegistered<HomeController>()) {
      return !Get.find<HomeController>().sudahCheckIn;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    initCamera();
    _getLocation();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      cameraController = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await cameraController!.initialize();
      isCameraReady.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka kamera: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> ambilFoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;
    if (!dalamRadius.value) {
      Get.snackbar(
        'Diluar Radius',
        'Anda harus berada dalam radius sekolah untuk presensi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    isTakingPhoto.value = true;
    final file = await cameraController!.takePicture();
    capturedImagePath.value = file.path;
    isTakingPhoto.value = false;
  }

  void ambilUlang() {
    capturedImagePath.value = '';
  }

  void lanjutKeVerifikasi() {
    if (Get.isRegistered<VerifikasiController>()) {
      Get.delete<VerifikasiController>();
    }

    final verCtrl = Get.put(VerifikasiController());

    verCtrl.fotoPath.value = capturedImagePath.value;
    verCtrl.alamat.value = alamat.value;
    verCtrl.koordinat.value = koordinat.value;
    verCtrl.jarakMeter.value = jarakMeter.value;
    verCtrl.dalamRadius.value = dalamRadius.value;
    verCtrl.currentLat.value = currentLat.value;
    verCtrl.currentLng.value = currentLng.value;

    Get.toNamed(AppRoutes.verifikasipage);
  }

  Future<void> retryLocation() => _getLocation();

  Future<void> _getLocation() async {
    isLoadingLocation.value = true;
    locationError.value = '';
    try {
      await _fetchGPS();
    } catch (e) {
      locationError.value = 'Gagal mendapatkan lokasi: $e';
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> _fetchGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('GPS tidak aktif');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen');
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLat.value = pos.latitude;
    currentLng.value = pos.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    Placemark place = placemarks.first;
    alamat.value =
        '${place.street}, ${place.subLocality}, ${place.locality}, '
        '${place.administrativeArea} ${place.postalCode}';
    koordinat.value =
        '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';

    double jarak = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      _schoolLat,
      _schoolLng,
    );
    jarakMeter.value = jarak;
    dalamRadius.value = jarak <= _radiusMeters;
  }

  Future<void> submitPresensi() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      final token = await AuthService.getToken();
      final endpoint = isCheckIn
          ? '${AppStatic.base_url}/attendance/check-in'
          : '${AppStatic.base_url}/attendance/check-out';

      final request = http.MultipartRequest('POST', Uri.parse(endpoint))
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['latitude'] = currentLat.value.toString()
        ..fields['longitude'] = currentLng.value.toString();

      if (capturedImagePath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', capturedImagePath.value),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      handleApiResponse(response, isCheckIn: isCheckIn);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat terhubung ke server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void handleApiResponse(http.Response response, {required bool isCheckIn}) {
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as Map<String, dynamic>?;

      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        if (isCheckIn && data != null) {
          final rawTime = data['check_in_time'] as String? ?? '';
          homeCtrl.presensiMasuk.value = _formatTime(rawTime);
          homeCtrl.jamMasukDisplay.value = _formatTime(rawTime);
        } else if (!isCheckIn && data != null) {
          final rawTime = data['check_out_time'] as String? ?? '';
          homeCtrl.presensiPulang.value = _formatTime(rawTime); // set checkout
          homeCtrl.jamPulangDisplay.value = _formatTime(rawTime);
        }
      }

      if (Get.isRegistered<RiwayatController>()) {
        Get.find<RiwayatController>().fetchHistory();
      }

      Get.snackbar(
        isCheckIn ? 'Check-in Berhasil' : 'Check-out Berhasil',
        body['message'] ??
            (isCheckIn ? 'Check-in berhasil' : 'Check-out berhasil'),
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed(AppRoutes.mainPage);
      });
    } else if (response.statusCode == 401) {
      AuthService.clearToken();
      Get.offAllNamed('/loginPage');
    } else {
      final msg = body['message'] ?? 'Terjadi kesalahan';
      Get.snackbar(
        'Gagal',
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '--:--';
    if (raw.contains('T')) {
      final dt = DateTime.tryParse(raw);
      if (dt != null) {
        return '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
      }
    }
    final parts = raw.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return raw;
  }
}
