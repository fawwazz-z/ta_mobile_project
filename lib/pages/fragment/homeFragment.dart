import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';

class HomeFragment extends StatelessWidget {
  HomeFragment({super.key});

  final HomeController homeCtrl = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.bgField,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.primary,
            size: 24,
          ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    homeCtrl.sudahCheckIn
                        ? homeCtrl
                              .jamPulangSekolah
                              .value // sudah absen masuk → tampil jam pulang
                        : homeCtrl
                              .jamMasukSekolah
                              .value, // belum absen → tampil jam masuk
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
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

          // Jam MASUK & PULANG dari data presensi aktual
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    'MASUK',
                    homeCtrl.jamMasukDisplay.value,
                    filled: homeCtrl.jamMasukDisplay.value != '--:--',
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.brownshade3),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildTimeInfo(
                    'PULANG',
                    homeCtrl.jamPulangDisplay.value,
                    filled: homeCtrl.jamPulangDisplay.value != '--:--',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Tombol presensi — label berubah sesuai status
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.presensipage),
                icon: Icon(
                  homeCtrl.sudahCheckIn
                      ? Icons.logout_rounded
                      : Icons.fingerprint_rounded,
                  size: 22,
                ),
                label: Text(
                  homeCtrl.sudahCheckIn ? 'Presensi Pulang' : 'Mulai Presensi',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: homeCtrl.sudahCheckIn
                      ? AppColors.warning
                      : AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value, {bool filled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.brownshade4,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: filled ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Obx(() {
      if (!homeCtrl.sudahPresensi.value) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_month_outlined,
                iconColor: AppColors.info,
                iconBg: AppColors.infoLight,
                label: 'KEHADIRAN SISWA',
                value: '--%',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.medical_services_outlined,
                iconColor: AppColors.warning,
                iconBg: AppColors.warningLight,
                label: 'IZIN/SAKIT',
                value: '-- Siswa',
              ),
            ),
          ],
        );
      }

      final persenHadir = homeCtrl.persenHadir.toStringAsFixed(0);
      final izinSakit = homeCtrl.totalIzinSakit;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_month_outlined,
              iconColor: AppColors.info,
              iconBg: AppColors.infoLight,
              label: 'KEHADIRAN',
              value: '$persenHadir%',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildStatCard(
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.warning,
              iconBg: AppColors.warningLight,
              label: 'IZIN/SAKIT',
              value: '$izinSakit Siswa',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.brown.shade400,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D2B1F),
            ),
          ),
        ],
      ),
    );
  }

  // ── Jurnal/Jadwal Section ──────────────────────────────────────────────────
  Widget _buildJurnalSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Hari Ini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D2B1F),
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.jurnalPage),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B1A1A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (homeCtrl.isLoadingJadwal.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B1A1A)),
            );
          }
          if (homeCtrl.errorJadwal.isNotEmpty) {
            return Center(
              child: Text(
                homeCtrl.errorJadwal.value,
                style: TextStyle(color: Colors.brown.shade400),
              ),
            );
          }
          if (homeCtrl.jadwalHariIni.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    color: Colors.brown.shade300,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tidak ada jadwal mengajar hari ini',
                    style: TextStyle(color: Colors.brown.shade400),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.brownshade2.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
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

            // Tombol Refleksi (hanya muncul jika sudah filled)
            // Di bagian tombol refleksi, ganti dengan:
            if (isJournalFilled)
              Obx(() {
                final hasReflection = homeCtrl.getReflectionStatus(scheduleId);
                return GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.refleksipage,
                      arguments: {
                        'schedule_id': scheduleId,
                        'kelas': className,
                        'mapel': mapel,
                      },
                    )?.then((_) {
                      // Refresh status refleksi setelah kembali
                      homeCtrl.refreshData();
                    });
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
