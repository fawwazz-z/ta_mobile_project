import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/routes/route.dart';

class PresensiController extends GetxController {
  CameraController? cameraController;

  var isCameraReady = false.obs;
  var isTakingPhoto = false.obs;
  var capturedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> initCamera() async {
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
  }

  Future<void> ambilFoto() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized) return;

    isTakingPhoto.value = true;

    final file = await cameraController!.takePicture();
    capturedImagePath.value = file.path;

    isTakingPhoto.value = false;
  }

  void ambilUlang() {
    capturedImagePath.value = '';
  }

  void selesaiPresensi() {
    Get.offAllNamed(AppRoutes.verifikasipage);
  }
}