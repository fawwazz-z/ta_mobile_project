import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jadwalController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/components/app_widget.dart';

class JadwalFragment extends StatelessWidget {
  const JadwalFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<JadwalController>();

    return Container(
      color: AppColors.bgCard,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(ctrl),
            Expanded(child: Obx(() => _buildBody(ctrl))),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(JadwalController ctrl) {
    return Column(
      children: [
        AppPageHeader(
          title: 'Jadwal Mengajar',
          action: AppIconButton(
            icon: Icons.refresh_rounded,
            onTap: ctrl.fetchJadwal,
            child: Obx(
              () => ctrl.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
            ),
          ),
        ),

        // ✅ Obx wajib agar label bulan reaktif saat prev/next ditekan
        Obx(
          () => AppMonthSelector(
            label: ctrl.selectedMonthLabel,
            onPrev: ctrl.previousMonth,
            onNext: ctrl.nextMonth,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ── Body utama ───────────────────────────────────────────────────────────
  Widget _buildBody(JadwalController ctrl) {
    if (ctrl.isLoading.value) {
      return const AppLoadingCenter(label: 'Memuat jadwal...');
    }

    if (ctrl.errorMsg.isNotEmpty) {
      return AppErrorState(
        message: ctrl.errorMsg.value,
        onRetry: ctrl.fetchJadwal,
      );
    }

    if (ctrl.jadwalList.isEmpty) {
      return const AppEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Belum ada jadwal mengajar',
        subtitle: 'Hubungi admin untuk pengaturan jadwal',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ctrl.dayOrder.map((day) {
          final items = ctrl.getByDay(day);
          return _buildDaySection(day, items);
        }).toList(),
      ),
    );
  }

  // ── Section per hari ─────────────────────────────────────────────────────
  Widget _buildDaySection(String hari, List<JadwalModel> items) {
    final now = DateTime.now();
    final days = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final isToday = hari == days[now.weekday];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              hari.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isToday ? AppColors.primary : AppColors.brownshade2,
                letterSpacing: 1.2,
              ),
            ),
            if (isToday) ...[
              const SizedBox(width: 8),
              // ✅ AppPrimaryBadge
              const AppPrimaryBadge(
                label: 'HARI INI',
                fontSize: 9,
                paddingH: 8,
                paddingV: 2,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          _buildEmptyDay()
        else
          ...items.map((item) => _buildJadwalCard(item)),
      ],
    );
  }

  // ── Baris kosong ─────────────────────────────────────────────────────────
  Widget _buildEmptyDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brownshade3, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_busy_outlined,
            color: AppColors.brownshade,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Tidak ada jadwal mengajar',
            style: TextStyle(fontSize: 13, color: AppColors.brownshade4),
          ),
        ],
      ),
    );
  }

  // ── Card satu slot jadwal ────────────────────────────────────────────────
  Widget _buildJadwalCard(JadwalModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 14,
        blurRadius: 8,
        shadowOffset: const Offset(0, 3),
        child: Row(
          children: [
            AppIconTile(
              icon: Icons.menu_book_outlined,
              color: AppColors.primary,
              backgroundColor: AppColors.iconBgBrown,
              tileSize: 46,
              iconSize: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
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
                    item.subjectName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.door_front_door_outlined,
                        size: 12,
                        color: AppColors.brownshade4,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.classroomName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.brownshade2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.startTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  item.endTime,
                  style: TextStyle(fontSize: 12, color: AppColors.brownshade4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
