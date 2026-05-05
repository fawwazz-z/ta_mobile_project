import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import '../controllers/verifikasiController.dart';
import '../routes/route.dart';

class VerifikasiPage extends StatelessWidget {
  VerifikasiPage({super.key});

  final controller = Get.put(VerifikasiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: const Text(
          "Verifikasi Lokasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Preview foto
            Obx(() {
              final path = controller.fotoPath.value; // sesuaikan nama field di controller kamu
              return Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.bgPreview,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: path.isNotEmpty
                          ? Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: 220)
                          : const Center(child: Icon(Icons.person, size: 80, color: Colors.white54)),
                    ),
                    // Tombol ambil ulang foto di bawah preview
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            "AMBIL ULANG FOTO",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Info lokasi, koordinat, status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Lokasi
                  _infoRow(
                    icon: Icons.location_on,
                    iconColor: AppColors.primaryLight,
                    label: "LOKASI ANDA",
                    child: Obx(() => Text(
                          controller.alamat.value,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        )),
                  ),

                  const Divider(height: 24),

                  // Koordinat
                  _infoRow(
                    icon: Icons.explore,
                    iconColor: AppColors.primaryLight,
                    label: "KOORDINAT",
                    child: Obx(() => Text(
                          controller.koordinat.value,
                          style: const TextStyle(fontSize: 14),
                        )),
                  ),

                  const Divider(height: 24),

                  // Status radius
                  _infoRow(
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                    label: "STATUS RADIUS",
                    child: Obx(() => Row(
                          children: [
                            Text(
                              controller.status.value,
                              style: const TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        )),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Tombol selesaikan
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
                onPressed: () {
                  Get.offAllNamed(AppRoutes.mainPage);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Selesaikan Presensi",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
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