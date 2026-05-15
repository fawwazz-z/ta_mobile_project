import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/controllers/mainController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/components/app_widget.dart';

class HomeFragment extends StatelessWidget {
  HomeFragment({super.key});

  final HomeController homeCtrl = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: () async => await homeCtrl.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPresensiCard(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildJurnalSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang,',
              style: TextStyle(fontSize: 14, color: AppColors.brownshade2),
            ),
            const SizedBox(height: 2),
            Obx(
              () => Text(
                homeCtrl.teacherName.value.isEmpty
                    ? 'Guru'
                    : homeCtrl.teacherName.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBrown,
                ),
              ),
            ),
          ],
        ),

        GestureDetector(
          onTap: () => Get.find<MainController>().changeIndex(3),
          child: AppUserAvatar(size: 44, iconSize: 24, borderRadius: 12),
        ),
      ],
    );
  }

  // ── Presensi Card ──────────────────────────────────────────────────────────
  Widget _buildPresensiCard() {
    final now = DateTime.now();
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dateStr =
        '${days[now.weekday % 7]}, ${now.day} ${months[now.month]} ${now.year}';

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card: judul + badge jam sekolah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Presensi Hari Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Obx(
                () => AppPrimaryBadge(
                  label: homeCtrl.sudahCheckIn
                      ? homeCtrl.jamPulangSekolah.value
                      : homeCtrl.jamMasukSekolah.value,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(fontSize: 12, color: AppColors.brownshade),
          ),
          const SizedBox(height: 16),

          // Jam MASUK & PULANG
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: AppTimeDisplay(
                    label: 'MASUK',
                    value: homeCtrl.jamMasukDisplay.value,
                    filled: homeCtrl.jamMasukDisplay.value != '--:--',
                  ),
                ),
                AppDivider.vertical(height: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: AppTimeDisplay(
                    label: 'PULANG',
                    value: homeCtrl.jamPulangDisplay.value,
                    filled: homeCtrl.jamPulangDisplay.value != '--:--',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Tombol presensi
          Obx(() {
            final sudahKeduanya =
                homeCtrl.sudahCheckIn && homeCtrl.sudahCheckOut;
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: sudahKeduanya
                    ? null
                    : () => Get.toNamed(AppRoutes.presensipage),
                icon: Icon(
                  sudahKeduanya
                      ? Icons.check_circle_rounded
                      : homeCtrl.sudahCheckIn
                      ? Icons.logout_rounded
                      : Icons.fingerprint_rounded,
                  size: 22,
                ),
                label: Text(
                  sudahKeduanya
                      ? 'Presensi Selesai'
                      : homeCtrl.sudahCheckIn
                      ? 'Presensi Pulang'
                      : 'Mulai Presensi',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sudahKeduanya
                      ? Colors.grey.shade400
                      : homeCtrl.sudahCheckIn
                      ? AppColors.warning
                      : AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Obx(() {
      final persenHadir = homeCtrl.sudahPresensi.value
          ? '${homeCtrl.persenHadir.toStringAsFixed(0)}%'
          : '--%';
      final izinSakit = homeCtrl.sudahPresensi.value
          ? '${homeCtrl.totalIzinSakit} Siswa'
          : '-- Siswa';
      final labelKehadiran = homeCtrl.sudahPresensi.value
          ? 'KEHADIRAN'
          : 'KEHADIRAN SISWA';

      return Row(
        children: [
          Expanded(
            child: AppStatCard(
              icon: Icons.calendar_month_outlined,
              iconColor: AppColors.info,
              iconBg: AppColors.infoLight,
              label: labelKehadiran,
              value: persenHadir,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AppStatCard(
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.warning,
              iconBg: AppColors.warningLight,
              label: 'IZIN/SAKIT',
              value: izinSakit,
            ),
          ),
        ],
      );
    });
  }

  // ── Jurnal/Jadwal Section ──────────────────────────────────────────────────
  Widget _buildJurnalSection() {
    return Column(
      children: [
        AppSectionTitle(
          title: 'Jadwal Hari Ini',
          onSeeAll: () => Get.toNamed(AppRoutes.jurnalPage),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (homeCtrl.isLoadingJadwal.value) {
            return const AppLoadingCenter();
          }
          if (homeCtrl.errorJadwal.isNotEmpty) {
            return Center(
              child: Text(
                homeCtrl.errorJadwal.value,
                style: TextStyle(color: AppColors.brownshade4),
              ),
            );
          }
          if (homeCtrl.jadwalHariIni.isEmpty) {
            return AppCard(
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    color: AppColors.brownshade,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tidak ada jadwal mengajar hari ini',
                    style: TextStyle(color: AppColors.brownshade4),
                  ),
                ],
              ),
            );
          }

          final preview = homeCtrl.jadwalHariIni.take(2).toList();
          return Column(
            children: preview.asMap().entries.map((entry) {
              final jadwal = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildJurnalItem(
                  icon: Icons.menu_book_outlined,
                  iconColor: entry.key == 0 ? AppColors.info : AppColors.purple,
                  iconBg: entry.key == 0
                      ? AppColors.iconBgBlue
                      : AppColors.iconBgPurple,
                  className: jadwal.classroomName,
                  subject: jadwal.subjectName,
                  time: '${jadwal.startTime} - ${jadwal.endTime}',
                  scheduleId: jadwal.id,
                  journalId: jadwal.journalId,
                  classroomId: jadwal.classroomId,
                  mapel: jadwal.subjectName,
                  startTime: jadwal.startTime,
                  endTime: jadwal.endTime,
                  isJournalFilled: jadwal.isJournalFilled,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildJurnalItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String className,
    required String subject,
    required int scheduleId,
    required int journalId,
    required int classroomId,
    required String time,
    required String mapel,
    required String startTime,
    required String endTime,
    required bool isJournalFilled,
  }) {
    return GestureDetector(
      onTap: () {
        if (isJournalFilled) {
          Get.toNamed(
            AppRoutes.updatePresensiPage,
            arguments: {
              'schedule_id': scheduleId,
              'journal_id': journalId,
              'classroom_id': classroomId,
              'kelas': className,
              'mapel': mapel,
              'start_time': startTime,
              'end_time': endTime,
            },
          )?.then((_) => homeCtrl.refreshData());
        } else {
          Get.toNamed(
            AppRoutes.presensiSiswa,
            arguments: {
              'schedule_id': scheduleId,
              'classroom_id': classroomId,
              'kelas': className,
              'mapel': mapel,
              'start_time': startTime,
              'end_time': endTime,
              'is_journal_filled': isJournalFilled,
            },
          )?.then((_) => homeCtrl.refreshData());
        }
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 16,
        child: Row(
          children: [
            AppIconTile(
              icon: icon,
              color: iconColor,
              backgroundColor: iconBg,
              tileSize: 42,
              iconSize: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$subject • $time',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.brownshade4,
                    ),
                  ),
                ],
              ),
            ),

            // Di tombol refleksi (kurang lebih line 320-350)
            if (isJournalFilled)
              Obx(() {
                final hasReflection = homeCtrl.getReflectionStatus(scheduleId);
                return GestureDetector(
                  onTap: () {
                    // 🔥 KIRIMKAN schedule_id DAN journal_id
                    final arguments = {
                      'schedule_id': scheduleId,
                      'kelas': className,
                      'mapel': mapel,
                    };

                    // Jika journalId tersedia (bukan 0), kirimkan
                    if (journalId != 0) {
                      arguments['journal_id'] = journalId;
                    }

                    Get.toNamed(
                      AppRoutes.refleksipage,
                      arguments: arguments,
                    )?.then((_) => homeCtrl.refreshData());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: hasReflection
                          ? Colors.green.withOpacity(0.1)
                          : AppColors.infoLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_note_outlined,
                          size: 14,
                          color: hasReflection ? Colors.green : AppColors.info,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasReflection ? 'Refleksi ✓' : 'Refleksi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasReflection
                                ? Colors.green
                                : AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.brownshade,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
