import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/updatePresensiController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';

class UpdatePresensiPage extends StatelessWidget {
  const UpdatePresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<UpdatePresensiController>();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
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
                        color: AppColors.bgCard,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update Presensi Siswa',
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

            const SizedBox(height: 8),

            // List siswa
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
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
                          onPressed: ctrl.fetchDetailJurnal,
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
                if (ctrl.siswaList.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data siswa',
                      style: TextStyle(color: AppColors.brownshade4),
                    ),
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

            Obx(() {
              if (ctrl.journalId.value != 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigasi ke halaman refleksi
                        Get.toNamed(
                          AppRoutes.refleksipage,
                          arguments: {
                            'journal_id': ctrl.journalId.value,
                            'schedule_id': ctrl.scheduleId,
                            'kelas': ctrl.kelasNama,
                            'mapel': ctrl.mapelNama,
                            'reflection': ctrl
                                .refleksi
                                .value, // kirim refleksi yang sudah ada
                          },
                        )?.then((_) {
                          // Refresh data setelah kembali dari refleksi
                          ctrl.fetchDetailJurnal();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.info,
                        side: BorderSide(color: AppColors.info),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note_outlined, size: 18),
                      label: const Text(
                        'Isi / Edit Refleksi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),

            // Tombol Update
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: ctrl.isSaving.value
                        ? null
                        : () => _showMateriDialog(ctrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        0.6,
                      ),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: ctrl.isSaving.value
                        ? const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.update_outlined, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Update Presensi',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMateriDialog(UpdatePresensiController ctrl) {
    final materiCtrl = TextEditingController(text: ctrl.materi.value);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Materi Pembelajaran',
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
              'Update materi yang diajarkan:',
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
            child: Text(
              'Batal',
              style: TextStyle(color: const Color(0xFF795548)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.updatePresensi(material: materiCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Update',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(
    SiswaUpdateModel siswa,
    UpdatePresensiController ctrl,
  ) {
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

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.brownshade2.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.bgCard,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
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
                        color: isSelected ? color : const Color(0xFFF5EFE6),
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
      );
    });
  }
}
