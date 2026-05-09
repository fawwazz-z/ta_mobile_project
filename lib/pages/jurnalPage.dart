import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jurnalController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';

class JurnalPage extends StatelessWidget {
  const JurnalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<JurnalController>();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.textDark,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Daftar Jurnal Mengajar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 10),
                // Month Selector
                _buildMonthSelector(ctrl),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (ctrl.errorMsg.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: AppColors.brownshade,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ctrl.errorMsg.value,
                              style: TextStyle(color: AppColors.brownshade2),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: ctrl.fetchJurnal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (ctrl.jurnalList.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada jurnal',
                          style: TextStyle(color: AppColors.brownshade4),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      child: Column(
                        children: ctrl.jurnalList
                            .map((j) => _buildJurnalCard(j))
                            .toList(),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // FAB
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Month Selector ──────────────────────────────────────────────────────────
  Widget _buildMonthSelector(JurnalController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: ctrl.previousMonth,
              child: const Icon(Icons.chevron_left_rounded, size: 26),
            ),
            Obx(
              () => Text(
                ctrl.selectedMonthLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            GestureDetector(
              onTap: ctrl.nextMonth,
              child: const Icon(Icons.chevron_right_rounded, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  // ── Jurnal Card ─────────────────────────────────────────────────────────────
  Widget _buildJurnalCard(JurnalModel jurnal) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.presensiSiswa,
        arguments: {'jurnal_id': jurnal.id, 'kelas': jurnal.kelas},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.brownshade2.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jurnal.kelas,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    jurnal.idKode,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.brownshade4,
                    ),
                  ),
                ],
              ),
            ),
            // Body card
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.menu_outlined,
                        color: AppColors.brownshade4,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MATA PELAJARAN',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.brownshade4,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            jurnal.mapel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: AppColors.brownshade4,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WAKTU',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.brownshade4,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            jurnal.waktu,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: AppColors.brownshade3, height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.presensiSiswa,
                          arguments: {
                            'jurnal_id': jurnal.id,
                            'kelas': jurnal.kelas,
                          },
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Detail Jurnal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6D4C41),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.brownshade2,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
