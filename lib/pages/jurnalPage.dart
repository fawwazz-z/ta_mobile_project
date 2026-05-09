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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar
            _buildAppBar(),
            const SizedBox(height: 16),
            // Month Selector
            _buildMonthSelector(ctrl),
            const SizedBox(height: 16),
            // List Jurnal
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (ctrl.errorMsg.isNotEmpty) {
                  return _buildErrorView(ctrl);
                }
                if (ctrl.jurnalList.isEmpty) {
                  return _buildEmptyView();
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

  Widget _buildAppBar() {
    return Padding(
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
            'Riwayat Jurnal Mengajar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(JurnalController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: ctrl.previousMonth,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_left_rounded, size: 24),
              ),
            ),
            Obx(
              () => Text(
                ctrl.selectedMonthLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ),
            GestureDetector(
              onTap: ctrl.nextMonth,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_right_rounded, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(JurnalController ctrl) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.brownshade, size: 48),
          const SizedBox(height: 12),
          Text(
            ctrl.errorMsg.value,
            style: TextStyle(color: AppColors.brownshade2),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: ctrl.fetchJurnalHistory,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_edu_rounded,
            color: AppColors.brownshade3,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada jurnal mengajar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.brownshade4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'di bulan ini',
            style: TextStyle(fontSize: 12, color: AppColors.brownshade3),
          ),
        ],
      ),
    );
  }

  Widget _buildJurnalCard(JurnalHistoryModel jurnal, JurnalController ctrl) {
    // Format tanggal: 2026-05-08 -> 08 Mei 2026
    final dateParts = jurnal.date.split('-');
    final months = [
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
    final dayNames = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };
    final dayName = dayNames[jurnal.day] ?? jurnal.day;

    return GestureDetector(
      // Di dalam _buildJurnalCard, pada onTap:
      onTap: () {
        if (jurnal.isJournalFilled) {
          // 🔥 KIRIMKAN journal_id UNTUK MENGGUNAKAN ENDPOINT BARU
          Get.toNamed(
            AppRoutes.updatePresensiPage,
            arguments: {
              'journal_id': jurnal.journalId, // <-- UTAMA untuk endpoint baru
              'schedule_id': jurnal.id, // <-- CADANGAN
              'classroom_id': jurnal.classroomId,
              'kelas': jurnal.classroomName,
              'mapel': jurnal.subjectName,
              'start_time': jurnal.startTime,
              'end_time': jurnal.endTime,
            },
          )?.then((_) => ctrl.refreshData());
        } else {
          // Data baru (belum diisi) - tidak kirim journal_id
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card - Tanggal & Hari
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: jurnal.isJournalFilled
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      jurnal.isJournalFilled ? 'Sudah Diisi' : 'Belum Diisi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: jurnal.isJournalFilled
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.infoLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: AppColors.info,
                          size: 22,
                        ),
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
    );
  }
}
