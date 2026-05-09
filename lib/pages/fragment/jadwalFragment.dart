import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jadwalController.dart';
import 'package:ta_mobile_project/routes/colors.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Jadwal Mengajar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          // Tombol refresh
          GestureDetector(
            onTap: ctrl.fetchJadwal,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
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
        ],
      ),
    );
  }

  // ── Body utama ───────────────────────────────────────────────────────────
  Widget _buildBody(JadwalController ctrl) {
    // Loading
    if (ctrl.isLoading.value) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Memuat jadwal...',
              style: TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Error
    if (ctrl.errorMsg.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: AppColors.brownshade,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                ctrl.errorMsg.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.brownshade2, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: ctrl.fetchJadwal,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Kosong
    if (ctrl.jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: AppColors.brownshade,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada jadwal mengajar',
              style: TextStyle(
                color: AppColors.brownshade4,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungi admin untuk pengaturan jadwal',
              style: TextStyle(color: AppColors.brownshade, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Ada data — tampilkan per hari
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ctrl.dayOrder.map((day) {
          final items = ctrl.getByDay(day);
          return _buildDaySection(ctrl, day, items);
        }).toList(),
      ),
    );
  }

  // ── Section per hari ─────────────────────────────────────────────────────
  Widget _buildDaySection(
    JadwalController ctrl,
    String hari,
    List<JadwalModel> items,
  ) {
    // Hari ini
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
    final todayName = days[now.weekday];
    final isToday = hari == todayName;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'HARI INI',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
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
        border: Border.all(
          color: AppColors.brownshade3,
          width: 1,
          style: BorderStyle.solid,
        ),
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

  // ── Card satu slot jadwal (TANPA onTap, hanya display) ───────────────────
  Widget _buildJadwalCard(JadwalModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.brownshade2.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon mapel
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.iconBgBrown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Info mapel & kelas
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
          // Waktu
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
    );
  }
}
