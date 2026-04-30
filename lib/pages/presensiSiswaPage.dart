import 'package:flutter/material.dart';

class PresensiSiswaPages extends StatelessWidget {
  const PresensiSiswaPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_left_rounded,
                        color: Color(0xFF3D2B1F), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Presensi Siswa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2B1F),
                        ),
                      ),
                      Text(
                        'Kelas X - MIPA 1 • Senin, 22 Mei 2024',
                        style: TextStyle(
                            fontSize: 11, color: Colors.brown.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: Colors.brown.shade300, size: 20),
                    const SizedBox(width: 8),
                    Text('Cari nama siswa...',
                        style: TextStyle(
                            fontSize: 13, color: Colors.brown.shade300)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSiswaCard(
                        nama: 'Aditya Pratama',
                        nis: 'NIS: 21001',
                        selected: 'HADIR'),
                    _buildSiswaCard(
                        nama: 'Bunga Citra Lestari',
                        nis: 'NIS: 21002',
                        selected: 'IZIN'),
                    _buildSiswaCard(
                        nama: 'Dimas Anggara',
                        nis: 'NIS: 21005',
                        selected: 'HADIR'),
                    _buildSiswaCard(
                        nama: 'Eka Wijaya',
                        nis: 'NIS: 21004',
                        selected: 'SAKIT'),
                    _buildSiswaCard(
                        nama: 'Fahri Ramadhan',
                        nis: 'NIS: 21006',
                        selected: ''),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Simpan button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B1A1A),
                    disabledBackgroundColor: const Color(0xFF6B1A1A),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Simpan Presensi',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaCard({
    required String nama,
    required String nis,
    required String selected,
  }) {
    const options = ['HADIR', 'IZIN', 'SAKIT', 'ALPA'];
    final Map<String, Color> activeColors = {
      'HADIR': const Color(0xFF6B1A1A),
      'IZIN': const Color(0xFF1565C0),
      'SAKIT': const Color(0xFFE65100),
      'ALPA': const Color(0xFF424242),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.brown.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8D8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline_rounded,
                    color: Color(0xFF6B1A1A), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2B1F),
                    ),
                  ),
                  Text(nis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.brown.shade400)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((opt) {
              final isSelected = opt == selected;
              final color = activeColors[opt] ?? const Color(0xFF6B1A1A);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? color : const Color(0xFFF5EFE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Colors.brown.shade400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}