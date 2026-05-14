import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jurnalController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/Components/app_widget.dart';

class JurnalPage extends StatelessWidget {
  const JurnalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<JurnalController>();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: 'Riwayat Jurnal Mengajar',
              showBack: true,
              onBack: () => Get.back(),
            ),
            const SizedBox(height: 16),

            Obx(
              () => AppMonthSelector(
                label: ctrl.selectedMonthLabel,
                onPrev: ctrl.previousMonth,
                onNext: ctrl.nextMonth,
              ),
            ),
            const SizedBox(height: 16),

            // ── List Jurnal ────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const AppLoadingCenter();
                }

                if (ctrl.errorMsg.isNotEmpty) {
                  return AppErrorState(
                    message: ctrl.errorMsg.value,
                    onRetry: ctrl.fetchJurnalHistory,
                  );
                }

                if (ctrl.jurnalList.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.history_edu_rounded,
                    title: 'Belum ada jurnal mengajar',
                    subtitle: 'di bulan ini',
                    iconColor: AppColors.brownshade3,
                    iconSize: 64,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: ctrl.jurnalList.length,
                  itemBuilder: (context, index) {
                    return _buildJurnalCard(ctrl.jurnalList[index], ctrl);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card jurnal ────────────────────────────────────────────────────────
  Widget _buildJurnalCard(JurnalHistoryModel jurnal, JurnalController ctrl) {
    // Format tanggal: 2026-05-08 -> 08 Mei 2026
    final dateParts = jurnal.date.split('-');
    const months = [
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
    final formattedDate = dateParts.length == 3
        ? '${int.parse(dateParts[2])} ${months[int.parse(dateParts[1]) - 1]} ${dateParts[0]}'
        : jurnal.date;

    // Nama hari dalam Bahasa Indonesia
    const dayNames = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };
    final dayName = dayNames[jurnal.day] ?? jurnal.day;

    final isFilled = jurnal.isJournalFilled;
    final statusColor = isFilled ? Colors.green : Colors.orange;
    final statusLabel = isFilled ? 'Sudah Diisi' : 'Belum Diisi';

    return GestureDetector(
      onTap: () {
        if (isFilled) {
          Get.toNamed(
            AppRoutes.updatePresensiPage,
            arguments: {
              'journal_id': jurnal.journalId,
              'schedule_id': jurnal.id,
              'classroom_id': jurnal.classroomId,
              'kelas': jurnal.classroomName,
              'mapel': jurnal.subjectName,
              'start_time': jurnal.startTime,
              'end_time': jurnal.endTime,
            },
          )?.then((_) => ctrl.refreshData());
        } else {
          Get.toNamed(
            AppRoutes.presensiSiswa,
            arguments: {
              'schedule_id': jurnal.id,
              'classroom_id': jurnal.classroomId,
              'kelas': jurnal.classroomName,
              'mapel': jurnal.subjectName,
              'start_time': jurnal.startTime,
              'end_time': jurnal.endTime,
              'is_journal_filled': jurnal.isJournalFilled,
            },
          )?.then((_) => ctrl.refreshData());
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          padding: EdgeInsets.zero,
          borderRadius: 16,
          blurRadius: 8,
          shadowColor: AppColors.brownshade2.withOpacity(0.05),
          shadowOffset: const Offset(0, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card: tanggal, hari, status ──────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppStatusBadge(
                          label: dayName,
                          color: AppColors.primary,
                          dot: false,
                          fontSize: 11,
                          paddingH: 8,
                          paddingV: 2,
                        ),
                      ],
                    ),
                    AppStatusBadge(
                      label: statusLabel,
                      color: statusColor,
                      dot: false,
                    ),
                  ],
                ),
              ),

              // ── Body card: mapel, kelas, waktu ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppIconTile(
                          icon: Icons.menu_book_outlined,
                          color: AppColors.info,
                          backgroundColor: AppColors.infoLight.withOpacity(0.3),
                          tileSize: 44,
                          iconSize: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jurnal.classroomName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                jurnal.subjectName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.brownshade4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: AppColors.brownshade4,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${jurnal.startTime} - ${jurnal.endTime}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.brownshade3,
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
      ),
    );
  }
}
