import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/presensiSiswaController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/Components/app_widget.dart';

class PresensiSiswaPages extends StatelessWidget {
  const PresensiSiswaPages({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PresensiSiswaController>();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Get.back(),
                    backgroundColor: AppColors.bgCard,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Presensi Siswa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${ctrl.kelasNama} • ${ctrl.mapelNama}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.brownshade2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar (placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.brownshade,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cari nama siswa...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brownshade,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── List siswa ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const AppLoadingCenter();
                }

                if (ctrl.errorMsg.isNotEmpty) {
                  return AppErrorState(
                    message: ctrl.errorMsg.value,
                    onRetry: ctrl.fetchSiswa,
                  );
                }

                if (ctrl.siswaList.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'Tidak ada data siswa',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: ctrl.siswaList.length,
                  itemBuilder: (context, index) {
                    return _buildSiswaCard(ctrl.siswaList[index], ctrl);
                  },
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Obx(
                () => AppPrimaryButton(
                  label: 'Simpan Presensi',
                  icon: Icons.save_outlined,
                  onPressed: () => _showMateriDialog(ctrl),
                  isLoading: ctrl.isSaving.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog input materi sebelum simpan presensi
  void _showMateriDialog(PresensiSiswaController ctrl) {
    final materiCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Materi Pembelajaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan materi yang diajarkan hari ini:',
              style: TextStyle(fontSize: 13, color: Colors.brown.shade600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: materiCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Teks Eksposisi - Struktur dan Ciri-ciri',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.brown.shade300,
                ),
                filled: true,
                fillColor: const Color(0xFFF5EFE6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF795548)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.simpanPresensi(material: materiCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(SiswaModel siswa, PresensiSiswaController ctrl) {
    const options = ['hadir', 'izin', 'sakit', 'alpa'];
    final Map<String, Color> activeColors = {
      'hadir': AppColors.primary,
      'izin': AppColors.info,
      'sakit': AppColors.error,
      'alpa': AppColors.tauk,
    };

    return Obx(() {
      final currentStatus = ctrl.siswaList
          .firstWhere((s) => s.id == siswa.id)
          .status
          .toLowerCase();

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          blurRadius: 6,
          shadowColor: AppColors.brownshade2.withOpacity(0.05),
          shadowOffset: const Offset(0, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppUserAvatar(
                    size: 38,
                    iconSize: 20,
                    borderRadius: 19,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'NIS: ${siswa.nis}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.brownshade4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: options.map((opt) {
                  final isSelected = opt == currentStatus;
                  final color = activeColors[opt] ?? AppColors.primary;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.setStatus(siswa.id, opt),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : const Color(0xFFF5EFE6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            opt.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.brownshade4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}