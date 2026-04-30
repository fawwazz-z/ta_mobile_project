import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/presensiController.dart';

class PresensiPage extends StatelessWidget {
  PresensiPage({super.key});

  final controller = Get.find<PresensiController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE2),
      appBar: AppBar(
        title: const Text('Presensi Wajah'),
        backgroundColor: const Color(0xFFF5EDE2),
        elevation: 0,
      ),
      body: Obx(() {
        if (!controller.isCameraReady.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return controller.capturedImagePath.value.isNotEmpty
            ? _hasilFoto()
            : _kamera();
      }),
    );
  }

  // ================= KAMERA =================
  Widget _kamera() {
    return Column(
      children: [
        const SizedBox(height: 20),

        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraPreview(controller.cameraController!),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A0019),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: controller.ambilFoto,
              child: const Text(
                'Ambil Foto',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ================= HASIL FOTO =================
  Widget _hasilFoto() {
    return Column(
      children: [
        const SizedBox(height: 20),

        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(controller.capturedImagePath.value),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Text(
                "Foto berhasil diambil",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A0019),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: controller.selesaiPresensi,
                  child: const Text('Selesaikan Presensi'),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: controller.ambilUlang,
                child: const Text("Ambil Ulang"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}