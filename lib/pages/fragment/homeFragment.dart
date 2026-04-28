import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/homeController.dart';

class HomeFragment extends StatelessWidget {
  HomeFragment({super.key});

  final HomeController homeCtrl = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    // Tidak perlu Scaffold lagi, karena sudah ada di MainPage
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
            Text(
              'Selamat Datang,',
              style: TextStyle(fontSize: 14, color: Colors.brown.shade500),
            ),
            const SizedBox(height: 2),
            const Text(
              'Guru Bahasa Indonesia',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D2B1F),
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD4C4A8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF6B1A1A),
                size: 24,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresensiCard() {
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
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Presensi Hari Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D2B1F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '07:00 - 15:00',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Senin, 22 Mei 2024',
            style: TextStyle(fontSize: 12, color: Colors.brown.shade400),
          ),
          const SizedBox(height: 16),
          // Masuk / Pulang
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MASUK',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.brown.shade400,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '--:--',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2B1F),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.brown.shade100),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PULANG',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.brown.shade400,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '--:--',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2B1F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Mulai Presensi Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.fingerprint_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Mulai Presensi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildJurnalSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jurnal Mengajar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D2B1F),
              ),
            ),
            GestureDetector(
              onTap: () {},
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
        _buildJurnalItem(
          icon: Icons.menu_book_outlined,
          iconColor: const Color(0xFF2196F3),
          iconBg: const Color(0xFFE3F2FD),
          className: 'Kelas X - MIPA 1',
          subject: 'Teks Eksposisi',
          time: '08:00 - 09:30',
        ),
        const SizedBox(height: 12),
        _buildJurnalItem(
          icon: Icons.auto_stories_outlined,
          iconColor: const Color(0xFF9C27B0),
          iconBg: const Color(0xFFF3E5F5),
          className: 'Kelas XI - IPS 2',
          subject: 'Analisis Puisi',
          time: '10:00 - 11:30',
        ),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
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
                    color: Color(0xFF3D2B1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$subject • $time',
                  style: TextStyle(fontSize: 13, color: Colors.brown.shade400),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.brown.shade300,
            size: 22,
          ),
        ],
      ),
    );
  }
}
