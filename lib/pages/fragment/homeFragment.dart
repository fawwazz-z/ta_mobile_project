import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat Datang,',
                style: TextStyle(fontSize: 14, color: Colors.brown.shade500)),
            const SizedBox(height: 2),
            Obx(() => Text(
                  homeCtrl.teacherName.value.isEmpty
                      ? 'Guru'
                      : homeCtrl.teacherName.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2B1F),
                  ),
                )),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFD4C4A8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: Color(0xFF6B1A1A), size: 24),
        ),
      ],
    );
  }

  Widget _buildPresensiCard() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Presensi Hari Ini',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2B1F))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF6B1A1A),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('07:00 - 15:00',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(dateStr,
              style: TextStyle(fontSize: 12, color: Colors.brown.shade400)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTimeInfo('MASUK', '--:--')),
              Container(width: 1, height: 40, color: Colors.brown.shade100),
              const SizedBox(width: 20),
              Expanded(child: _buildTimeInfo('PULANG', '--:--')),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              // ── PERBAIKAN: navigasi ke PresensiPage (kamera wajah) ──
              onPressed: () => Get.toNamed(AppRoutes.presensipage),
              icon: const Icon(Icons.fingerprint_rounded, size: 22),
              label: const Text('Mulai Presensi',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.brown.shade400,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D2B1F))),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_month_outlined,
            iconColor: const Color(0xFF2196F3),
            iconBg: const Color(0xFFE3F2FD),
            label: 'KEHADIRAN',
            value: '98%',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            icon: Icons.medical_services_outlined,
            iconColor: const Color(0xFFFF6B35),
            iconBg: const Color(0xFFFFF3EE),
            label: 'IZIN/SAKIT',
            value: '2 Hari',
          ),
        ),
      ],
    );
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.brown.shade400,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D2B1F))),
        ],
      ),
    );
  }

  Widget _buildJurnalSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Jadwal Hari Ini',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2B1F))),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.jurnalPage),
              child: const Text('Lihat Semua',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B1A1A),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (homeCtrl.isLoadingJadwal.value) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B1A1A)));
          }
          if (homeCtrl.errorJadwal.isNotEmpty) {
            return Center(
                child: Text(homeCtrl.errorJadwal.value,
                    style: TextStyle(color: Colors.brown.shade400)));
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
                  Icon(Icons.event_available_rounded,
                      color: Colors.brown.shade300),
                  const SizedBox(width: 12),
                  Text('Tidak ada jadwal mengajar hari ini',
                      style: TextStyle(color: Colors.brown.shade400)),
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
                  iconColor: entry.key == 0
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF9C27B0),
                  iconBg: entry.key == 0
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFF3E5F5),
                  className: jadwal.classroomName,
                  subject: jadwal.subjectName,
                  time: '${jadwal.startTime} - ${jadwal.endTime}',
                  scheduleId: jadwal.id,
                  mapel: jadwal.subjectName,
                  startTime: jadwal.startTime,
                  endTime: jadwal.endTime,
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
    required String time,
    required int scheduleId,
    required String mapel,
    required String startTime,
    required String endTime,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.presensiSiswa,
        arguments: {
          'schedule_id': scheduleId,
          'kelas': className,
          'mapel': mapel,
          'start_time': startTime,
          'end_time': endTime,
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.brown.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(className,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2B1F))),
                  const SizedBox(height: 2),
                  Text('$subject • $time',
                      style: TextStyle(
                          fontSize: 13, color: Colors.brown.shade400)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.brown.shade300, size: 22),
          ],
        ),
      ),
    );
  }
}