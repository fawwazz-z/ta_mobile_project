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
        title: Obx(() => Text(
              controller.isCheckIn ? 'Presensi Masuk' : 'Presensi Pulang',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
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

  // ── TAMPILAN KAMERA ──────────────────────────────────────────────────────────
  Widget _kamera() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Preview kamera
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
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _FaceBracketPainter(
                          // Warna bracket mengikuti status radius
                          color: controller.dalamRadius.value
                              ? AppColors.primaryLight
                              : Colors.red,
                        ),
                      ),
                    ),
                    // Badge radius pojok kiri atas
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Obx(() => _buildRadiusBadge()),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info card lokasi + radius
          _infoCard(),

          const SizedBox(height: 16),

          // Tombol ambil foto
          Obx(() => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isLoadingLocation.value
                        ? Colors.grey.shade300
                        : controller.dalamRadius.value
                            ? AppColors.primaryLight
                            : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: controller.isLoadingLocation.value
                      ? null
                      : controller.ambilFoto,
                  child: controller.isLoadingLocation.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.dalamRadius.value
                              ? 'Ambil Foto'
                              : 'Di Luar Radius Sekolah',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── TAMPILAN HASIL FOTO ──────────────────────────────────────────────────────
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

          const SizedBox(height: 16),
          _infoCard(),
          const SizedBox(height: 16),

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
              onPressed: controller.lanjutKeVerifikasi,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lanjut Verifikasi',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
              'Ambil Ulang',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── INFO CARD ────────────────────────────────────────────────────────────────
  Widget _infoCard() {
    return Obx(() {
      if (controller.isLoadingLocation.value) {
        return _loadingCard();
      }
      if (controller.locationError.value.isNotEmpty) {
        return _errorCard(controller.locationError.value);
      }
      return _dataCard();
    });
  }

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mendapatkan lokasi Anda...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Mohon tunggu sebentar',
                style: TextStyle(fontSize: 12, color: AppColors.brownshade4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol refresh
          GestureDetector(
            onTap: controller.retryLocation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCard() {
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
            label: 'LOKASI ANDA',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.alamat.value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol refresh di data card juga
                GestureDetector(
                  onTap: controller.retryLocation,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primaryLight,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          _infoRow(
            icon: controller.dalamRadius.value
                ? Icons.check_circle
                : Icons.cancel,
            iconColor: controller.dalamRadius.value
                ? AppColors.success
                : Colors.red,
            label: 'STATUS RADIUS',
            child: Row(
              children: [
                Text(
                  controller.dalamRadius.value
                      ? 'Dalam Radius Sekolah'
                      : 'Di Luar Radius Sekolah',
                  style: TextStyle(
                    color: controller.dalamRadius.value
                        ? AppColors.teal
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: controller.dalamRadius.value
                        ? AppColors.tealLight
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.jarakMeter.value.toStringAsFixed(0)} m',
                    style: TextStyle(
                      color: controller.dalamRadius.value
                          ? AppColors.teal
                          : Colors.red,
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

  Widget _buildRadiusBadge() {
    if (controller.isLoadingLocation.value) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Lokasi...',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      );
    }

    if (controller.locationError.value.isNotEmpty) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded,
                color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text(
              'GPS Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: controller.dalamRadius.value
            ? Colors.green.withOpacity(0.85)
            : Colors.red.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.dalamRadius.value
                ? Icons.check_circle
                : Icons.cancel,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            controller.dalamRadius.value
                ? 'Dalam Radius'
                : 'Luar Radius',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
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

// Corner bracket painter — warna bisa disesuaikan
class _FaceBracketPainter extends CustomPainter {
  final Color color;
  const _FaceBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 40.0;
    const bracketSize = 30.0;

    // Top-left
    canvas.drawLine(Offset(margin, margin + bracketSize), Offset(margin, margin), paint);
    canvas.drawLine(Offset(margin, margin), Offset(margin + bracketSize, margin), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - margin - bracketSize, margin), Offset(size.width - margin, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + bracketSize), paint);
    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin - bracketSize), Offset(margin, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + bracketSize, size.height - margin), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - margin - bracketSize, size.height - margin), Offset(size.width - margin, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - bracketSize), paint);
  }

  @override
  bool shouldRepaint(covariant _FaceBracketPainter old) => old.color != color;
}