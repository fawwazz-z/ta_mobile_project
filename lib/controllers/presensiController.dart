import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/services/authService.dart';
import '../controllers/verifikasiController.dart';
import '../routes/colors.dart';

// Variabel dinamis yang akan diisi dari API
double _schoolLat = -6.8080000; // default sementara
double _schoolLng = 110.8315000; // default sementara
double _radiusMeters = 999900.0; // default sementara

class PresensiController extends GetxController {
  CameraController? cameraController;

  var isCameraReady = false.obs;
  var isTakingPhoto = false.obs;
  var capturedImagePath = ''.obs;

  var isLoadingLocation = true.obs;
  var isLoadingProfile = false.obs;
  var alamat = ''.obs;
  var koordinat = ''.obs;
  var currentLat = 0.0.obs;
  var currentLng = 0.0.obs;
  var jarakMeter = 0.0.obs;
  var dalamRadius = false.obs;
  var locationError = ''.obs;

  var isSubmitting = false.obs;

  // Data lokasi sekolah dari API
  var schoolLocationName = ''.obs;
  var schoolAddress = ''.obs;
  var schoolLatitude = 0.0.obs;
  var schoolLongitude = 0.0.obs;
  var schoolRadiusKm = 0.0.obs;

  bool get isCheckIn {
    if (Get.isRegistered<HomeController>()) {
      return !Get.find<HomeController>().sudahCheckIn;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    _loadProfileAndInit();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  /// Load profile dulu, baru init camera dan location
  Future<void> _loadProfileAndInit() async {
    await fetchSchoolLocation();
    await initCamera();
    await _getLocation();
  }

  /// GET /profile - Ambil data lokasi sekolah
  Future<void> fetchSchoolLocation() async {
    try {
      isLoadingProfile.value = true;
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppStatic.base_url}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Profile Response Status: ${response.statusCode}");
      print("Profile Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final data = body['data'];
          final location = data['location'];

          if (location != null) {
            // Update variabel global untuk radius sekolah
            _schoolLat =
                double.tryParse(location['latitude']?.toString() ?? '0') ??
                -6.8080000;
            _schoolLng =
                double.tryParse(location['longitude']?.toString() ?? '0') ??
                110.8315000;
            _radiusMeters =
                (double.tryParse(location['radius_km']?.toString() ?? '0') ??
                    0) *
                1000; // konversi km ke meter

            // Simpan ke observable untuk ditampilkan jika perlu
            schoolLocationName.value = location['name'] ?? 'Sekolah';
            schoolAddress.value = location['address'] ?? '';
            schoolLatitude.value = _schoolLat;
            schoolLongitude.value = _schoolLng;
            schoolRadiusKm.value =
                double.tryParse(location['radius_km']?.toString() ?? '0') ?? 0;

            print("School Location Loaded:");
            print("  Name: ${schoolLocationName.value}");
            print("  Lat: $_schoolLat, Lng: $_schoolLng");
            print(
              "  Radius: ${schoolRadiusKm.value} km ($_radiusMeters meters)",
            );
          } else {
            print("Location data not found in profile response");
          }
        } else {
          print("Failed to load profile: ${body['message']}");
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        print("Failed to load profile: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching school location: $e");
      // Tetap lanjut dengan default location
    } finally {
      isLoadingProfile.value = false;
    }
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

    // Kamera depan (front camera) menyimpan file hasil capture dalam
    // kondisi "raw sensor" yang terbalik (mirror) dibanding apa yang
    // terlihat user di live preview. Balikkan (flip horizontal) hasil
    // foto supaya sama persis dengan yang tampil di preview saat difoto.
    final fixedPath = await _fixMirrorForFrontCamera(file.path);

    capturedImagePath.value = fixedPath;
    isTakingPhoto.value = false;
  }

  /// Flip horizontal file foto jika diambil dari kamera depan, lalu
  /// timpa file yang sama. Jika bukan kamera depan atau proses gagal,
  /// path asli dikembalikan tanpa perubahan.
  Future<String> _fixMirrorForFrontCamera(String path) async {
    try {
      final isFrontCamera =
          cameraController?.description.lensDirection ==
          CameraLensDirection.front;
      if (!isFrontCamera) return path;

      final originalFile = File(path);
      final bytes = await originalFile.readAsBytes();

      final decoded = img.decodeImage(bytes);
      if (decoded == null) return path;

      final flipped = img.flipHorizontal(decoded);
      final newBytes = img.encodeJpg(flipped, quality: 92);

      await originalFile.writeAsBytes(newBytes);
      return path;
    } catch (e) {
      print('Gagal memperbaiki mirror foto: $e');
      return path;
    }
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

    // Hitung jarak ke sekolah menggunakan data dari API
    double jarak = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      _schoolLat,
      _schoolLng,
    );
    jarakMeter.value = jarak;
    dalamRadius.value = jarak <= _radiusMeters;

    print("Distance to school: ${jarak.toStringAsFixed(2)} meters");
    print("Radius limit: $_radiusMeters meters");
    print("Within radius: ${dalamRadius.value}");
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