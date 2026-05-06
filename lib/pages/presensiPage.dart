import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/presensiController.dart';
import '../routes/colors.dart';

class PresensiPage extends StatelessWidget {
  PresensiPage({super.key});

  final controller = Get.find<PresensiController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: const Text(
          'Presensi Wajah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        centerTitle: true,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Preview kamera dengan bracket corner
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bgPreview,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller.cameraController!),
                    // Corner brackets
                    Positioned.fill(
                      child: CustomPaint(painter: _FaceBracketPainter()),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Info lokasi & status (sama seperti verifikasi)
          _infoCard(),

          const SizedBox(height: 20),

          // Tombol ambil foto
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: controller.ambilFoto,
              child: const Text(
                'Ambil Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================= HASIL FOTO =================
  Widget _hasilFoto() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bgPreview,
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

          const SizedBox(height: 20),

          _infoCard(),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: controller.selesaiPresensi,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selesaikan Presensi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: controller.ambilUlang,
            child: const Text(
              "Ambil Ulang",
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.location_on,
            iconColor: AppColors.primaryLight,
            label: "LOKASI ANDA",
            child: const Text(
              "Jl. Pendidikan No. 45, Kebayoran Baru, Jakarta Selatan, DKI Jakarta 12130",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const Divider(height: 24),
          _infoRow(
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            label: "STATUS RADIUS",
            child: Row(
              children: [
                const Text(
                  "Dalam Radius Sekolah",
                  style: TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "12 Meter",
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.defalt,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

// Painter untuk corner bracket di kamera
class _FaceBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 40.0;
    const bracketSize = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(margin, margin + bracketSize),
      Offset(margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + bracketSize, margin),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - margin - bracketSize, margin),
      Offset(size.width - margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + bracketSize),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(margin, size.height - margin - bracketSize),
      Offset(margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + bracketSize, size.height - margin),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - margin - bracketSize, size.height - margin),
      Offset(size.width - margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - bracketSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
