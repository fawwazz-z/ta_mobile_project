import 'package:flutter/material.dart';

class JadwalFragment extends StatelessWidget {
  const JadwalFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita langsung mengembalikan Container, navigasi sudah diurus MainPage
    return Container(
      color: const Color(0xFFE8DCC8),
      child: SafeArea(
        child: Column(
          children: [
            // Header Jadwal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF3D2B1F),
                      size: 22,
                    ),
                  ),
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
                  const SizedBox(width: 36), // Spacer agar teks tetap di tengah
                ],
              ),
            ),

            // Konten Scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDaySection('SENIN', [
                      const _JadwalItemData(
                        mapel: 'Bahasa Indonesia',
                        jam: '07:30 - 09:00',
                        kelas: 'Kelas X - IPA 1',
                        sesi: 'SESI 1',
                      ),
                    ]),
                    _buildDaySection('SELASA', [
                      const _JadwalItemData(
                        mapel: 'Bahasa Indonesia',
                        jam: '09:15 - 10:45',
                        kelas: 'Kelas XI - IPS 2',
                        sesi: 'SESI 2',
                      ),
                    ]),
                    _buildDaySection('RABU', [], empty: true),
                    _buildDaySection('KAMIS', [
                      const _JadwalItemData(
                        mapel: 'Sastra Indonesia',
                        jam: '07:30 - 09:00',
                        kelas: 'Kelas XII - Bahasa',
                        sesi: 'SESI 1',
                      ),
                      const _JadwalItemData(
                        mapel: 'Bahasa Indonesia',
                        jam: '11:00 - 12:30',
                        kelas: 'Kelas X - IPA 1',
                        sesi: 'SESI 3',
                      ),
                    ]),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildDaySection(
    String hari,
    List<_JadwalItemData> items, {
    bool empty = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            hari,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.brown.shade500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        if (empty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.brown.shade300,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Tidak ada jadwal mengajar',
                  style: TextStyle(fontSize: 13, color: Colors.brown.shade400),
                ),
              ],
            ),
          )
        else
          ...items.map((item) => _buildJadwalCard(item)).toList(),
      ],
    );
  }

  Widget _buildJadwalCard(_JadwalItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE8D8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: Color(0xFF6B1A1A),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MATA PELAJARAN',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.brown.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  item.mapel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2B1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.kelas,
                  style: TextStyle(fontSize: 12, color: Colors.brown.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.jam,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D2B1F),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B1A1A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.sesi,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data Model Class
class _JadwalItemData {
  final String mapel, jam, kelas, sesi;
  const _JadwalItemData({
    required this.mapel,
    required this.jam,
    required this.kelas,
    required this.sesi,
  });
}
