import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jadwalController.dart';
import 'package:ta_mobile_project/routes/route.dart';

class JadwalFragment extends StatelessWidget {
  const JadwalFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<JadwalController>();

    return Container(
      color: const Color(0xFFE8DCC8),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(ctrl),
            Expanded(
              child: Obx(() => _buildBody(ctrl)),
            ),
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
                color: Color(0xFF3D2B1F),
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
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(() => ctrl.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6B1A1A),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded,
                      color: Color(0xFF3D2B1F), size: 20)),
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
            CircularProgressIndicator(color: Color(0xFF6B1A1A)),
            SizedBox(height: 16),
            Text('Memuat jadwal...',
                style: TextStyle(color: Color(0xFF6B1A1A), fontSize: 14)),
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
              Icon(Icons.wifi_off_rounded, color: Colors.brown.shade300, size: 56),
              const SizedBox(height: 16),
              Text(
                ctrl.errorMsg.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.brown.shade500, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: ctrl.fetchJadwal,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B1A1A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
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
            Icon(Icons.calendar_today_outlined,
                color: Colors.brown.shade300, size: 56),
            const SizedBox(height: 16),
            Text(
              'Belum ada jadwal mengajar',
              style: TextStyle(
                  color: Colors.brown.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungi admin untuk pengaturan jadwal',
              style: TextStyle(color: Colors.brown.shade300, fontSize: 12),
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
      JadwalController ctrl, String hari, List<JadwalModel> items) {
    // Hari ini
    final now        = DateTime.now();
    final days       = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final todayName  = days[now.weekday]; // weekday: 1=Mon...7=Sun
    final isToday    = hari == todayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        // Label hari
        Row(
          children: [
            Text(
              hari.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isToday
                    ? const Color(0xFF6B1A1A)
                    : Colors.brown.shade500,
                letterSpacing: 1.2,
              ),
            ),
            if (isToday) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'HARI INI',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Isi jadwal atau label kosong
        if (items.isEmpty)
          _buildEmptyDay()
        else
          ...items.map((item) => _buildJadwalCard(item)).toList(),
      ],
    );
  }

  // ── Baris kosong ─────────────────────────────────────────────────────────
  Widget _buildEmptyDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.brown.shade100, width: 1, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_outlined,
              color: Colors.brown.shade300, size: 18),
          const SizedBox(width: 10),
          Text(
            'Tidak ada jadwal mengajar',
            style:
                TextStyle(fontSize: 13, color: Colors.brown.shade400),
          ),
        ],
      ),
    );
  }

  // ── Card satu slot jadwal ─────────────────────────────────────────────────
  Widget _buildJadwalCard(JadwalModel item) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.presensiSiswa,
        arguments: {
          'schedule_id': item.id,
          'kelas':       item.classroomName,
          'mapel':       item.subjectName,
          'start_time':  item.startTime,
          'end_time':    item.endTime,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.06),
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
                color: const Color(0xFFEFE8D8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_outlined,
                  color: Color(0xFF6B1A1A), size: 22),
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
                        color: Colors.brown.shade400,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subjectName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2B1F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.door_front_door_outlined,
                          size: 12, color: Colors.brown.shade400),
                      const SizedBox(width: 4),
                      Text(
                        item.classroomName,
                        style: TextStyle(
                            fontSize: 12, color: Colors.brown.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Waktu & chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.startTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2B1F),
                  ),
                ),
                Text(
                  item.endTime,
                  style: TextStyle(
                      fontSize: 12, color: Colors.brown.shade400),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.brown.shade300, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}