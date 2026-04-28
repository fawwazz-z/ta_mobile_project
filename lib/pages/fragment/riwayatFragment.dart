import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';

class RiwayatFragment extends StatelessWidget {
  RiwayatFragment({super.key});

  final RiwayatController controller = Get.put(RiwayatController());

  @override
  Widget build(BuildContext context) {
    // Kita langsung mengembalikan Container/Column, bukan Scaffold
    return Container(
      color: const Color(0xFFE8DCC8),
      child: SafeArea(
        child: Column(
          children: [
            // Header Riwayat
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Presensi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2B1F),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF3D2B1F),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Month Selector
            _buildMonthSelector(),

            const SizedBox(height: 12),

            // List Riwayat
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildRiwayatCard(
                      tanggal: 'Senin, 22 Mei 2024',
                      status: 'Hadir',
                      statusColor: const Color(0xFF4CAF50),
                      masuk: '06:45',
                      pulang: '15:10',
                    ),
                    _buildRiwayatCard(
                      tanggal: 'Selasa, 21 Mei 2024',
                      status: 'Hadir',
                      statusColor: const Color(0xFF4CAF50),
                      masuk: '06:52',
                      pulang: '15:05',
                    ),
                    _buildRiwayatCard(
                      tanggal: 'Senin, 20 Mei 2024',
                      status: 'Sakit',
                      statusColor: const Color(0xFFFF9800),
                      masuk: '--:--',
                      pulang: '--:--',
                    ),
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

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left_rounded, size: 22),
            Text('Mei 2024', style: TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right_rounded, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard({
    required String tanggal,
    required String status,
    required Color statusColor,
    required String masuk,
    required String pulang,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HARI/TANGGAL', style: TextStyle(fontSize: 10)),
              Text(
                '● $status',
                style: TextStyle(color: statusColor, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tanggal,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTimeInfo('JAM MASUK', masuk)),
              Expanded(child: _buildTimeInfo('JAM PULANG', pulang)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
