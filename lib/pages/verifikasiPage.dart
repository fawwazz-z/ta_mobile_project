import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/Components/app_widget.dart';
import '../controllers/verifikasiController.dart';

class VerifikasiPage extends StatelessWidget {
  VerifikasiPage({super.key});

  final controller = Get.find<VerifikasiController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Presensi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Preview Foto ───────────────────────────────────────────────
            Obx(() {
              final path = controller.fotoPath.value;
              return Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.bgPreview,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: path.isNotEmpty
                          ? Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 240,
                            )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white54,
                              ),
                            ),
                    ),

                    // Badge radius pojok kanan bawah foto
                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: controller.dalamRadius.value
                                ? Colors.green.withOpacity(0.9)
                                : Colors.red.withOpacity(0.9),
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
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                controller.dalamRadius.value
                                    ? 'Dalam Radius'
                                    : 'Luar Radius',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            AppCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.white.withOpacity(0.5),
              blurRadius: 0,
              shadowColor: Colors.transparent,
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.location_on,
                    iconColor: AppColors.primaryLight,
                    label: 'LOKASI ANDA',
                    child: Obx(
                      () => Text(
                        controller.alamat.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.explore,
                    iconColor: AppColors.primaryLight,
                    label: 'KOORDINAT',
                    child: Obx(
                      () => Text(
                        controller.koordinat.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.radar,
                    iconColor: AppColors.success,
                    label: 'STATUS RADIUS',
                    child: Obx(
                      () => Row(
                        children: [
                          Text(
                            controller.statusText,
                            style: TextStyle(
                              color: controller.dalamRadius.value
                                  ? AppColors.teal
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppStatusBadge(
                            label: controller.jarakText,
                            color: controller.dalamRadius.value
                                ? AppColors.teal
                                : Colors.red,
                            dot: false,
                            fontSize: 11,
                            paddingH: 8,
                            paddingV: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            AppOutlinedButton(
              label: 'Ambil Ulang Foto',
              icon: Icons.camera_alt_outlined,
              onPressed: () => Get.back(),
              color: AppColors.primaryLight,
              borderColor: AppColors.primaryLight,
              height: 50,
            ),

            const SizedBox(height: 12),

            Obx(
              () => AppPrimaryButton(
                label: 'Selesaikan Presensi',
                icon: Icons.check_circle_outline,
                onPressed: controller.dalamRadius.value
                    ? () => controller.selesaikanPresensi()
                    : null,
                color: controller.dalamRadius.value
                    ? AppColors.primaryLight
                    : Colors.grey,
                height: 55,
                fontSize: 16,
                borderRadius: 16,
              ),
            ),

            const SizedBox(height: 28),
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