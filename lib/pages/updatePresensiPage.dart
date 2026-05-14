import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/updatePresensiController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/components/app_widget.dart';

// =============================================================================
// UPDATE PRESENSI PAGE — Refactored menggunakan app_widgets.dart
// =============================================================================

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
            // ── AppBar dengan back button dan subtitle ─────────────────────
            _UpdatePresensiHeader(ctrl: ctrl),

            const SizedBox(height: 8),

            // ── List siswa ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const AppLoadingCenter();
                }
                if (ctrl.errorMsg.isNotEmpty) {
                  return AppErrorState(
                    message: ctrl.errorMsg.value,
                    onRetry: ctrl.fetchDetailJurnal,
                  );
                }
                if (ctrl.siswaList.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'Tidak ada data siswa',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  itemCount: ctrl.siswaList.length,
                  itemBuilder: (context, index) {
                    return _SiswaCard(
                      siswa: ctrl.siswaList[index],
                      ctrl: ctrl,
                    );
                  },
                );
              }),
            ),

            // ── Tombol Refleksi (kondisional) ──────────────────────────────
            Obx(() {
              if (ctrl.journalId.value == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: AppOutlinedButton(
                  label: 'Isi / Edit Refleksi',
                  icon: Icons.edit_note_outlined,
                  color: AppColors.info,
                  borderColor: AppColors.info,
                  height: 48,
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.refleksipage,
                      arguments: {
                        'journal_id': ctrl.journalId.value,
                        'schedule_id': ctrl.scheduleId,
                        'kelas': ctrl.kelasNama,
                        'mapel': ctrl.mapelNama,
                        'reflection': ctrl.refleksi.value,
                      },
                    )?.then((_) => ctrl.fetchDetailJurnal());
                  },
                ),
              );
            }),

            // ── Tombol Update Presensi ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Obx(
                () => AppPrimaryButton(
                  label: 'Update Presensi',
                  icon: Icons.update_outlined,
                  isLoading: ctrl.isSaving.value,
                  onPressed: () => _showMateriDialog(ctrl),
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
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppFieldLabel(
              'Update materi yang diajarkan:',
              color: AppColors.brownshade4,
            ),
            const SizedBox(height: 12),
            AppTextFieldCard(
              controller: materiCtrl,
              hint: 'Contoh: Teks Eksposisi - Struktur dan Ciri-ciri',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.brownshade2),
            ),
          ),
          AppPrimaryButton(
            label: 'Update',
            height: 40,
            borderRadius: 10,
            fontSize: 14,
            onPressed: () {
              Get.back();
              ctrl.updatePresensi(material: materiCtrl.text.trim());
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// _UpdatePresensiHeader (private)
//   AppBar kustom dengan back button, judul, dan subtitle kelas & mapel.
//   Tidak menggunakan AppPageHeader standar karena butuh subtitle di bawah judul.
// -----------------------------------------------------------------------------
class _UpdatePresensiHeader extends StatelessWidget {
  const _UpdatePresensiHeader({required this.ctrl});

  final UpdatePresensiController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => Get.back(),
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
                  style: const TextStyle(
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
    );
  }
}

// -----------------------------------------------------------------------------
// _SiswaCard (private)
//   Card per siswa dengan tombol status hadir/izin/sakit/alpa.
//   Dipisah ke widget tersendiri agar ListView lebih ringan (rebuild terisolir).
// -----------------------------------------------------------------------------
class _SiswaCard extends StatelessWidget {
  const _SiswaCard({required this.siswa, required this.ctrl});

  final SiswaUpdateModel siswa;
  final UpdatePresensiController ctrl;

  static const _options = ['hadir', 'izin', 'sakit', 'alpa'];
  static const _activeColors = {
    'hadir': AppColors.primary,
    'izin': AppColors.info,
    'sakit': AppColors.error,
    'alpa': AppColors.tauk,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStatus = ctrl.siswaList
          .firstWhere((s) => s.id == siswa.id)
          .status
          .toLowerCase();

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: AppCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        shadowColor: Colors.transparent,
        blurRadius: 0,
        shadowOffset: Offset.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info siswa ─────────────────────────────────────────────────
            Row(
              children: [
                const AppIconTile(
                  icon: Icons.person_outline_rounded,
                  color: AppColors.primary,
                  backgroundColor: AppColors.bgCard,
                  tileSize: 38,
                  iconSize: 20,
                  borderRadius: 19, // circle
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.brownshade4,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Pilihan status ─────────────────────────────────────────────
            Row(
              children: _options.map((opt) {
                final isSelected = opt == currentStatus;
                final color = _activeColors[opt] ?? AppColors.primary;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.setStatus(siswa.id, opt),
                    child: _StatusChip(
                      label: opt.toUpperCase(),
                      isSelected: isSelected,
                      color: color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        ), // AppCard
      ); // Padding
    });
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.color,
  });

  final String label;
  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? color : const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.white : AppColors.brownshade4,
          ),
        ),
      ),
    );
  }
}