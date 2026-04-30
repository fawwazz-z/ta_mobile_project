import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/jurnalController.dart';
import 'package:ta_mobile_project/routes/route.dart';

class JurnalPage extends StatelessWidget {
  const JurnalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<JurnalController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.chevron_left_rounded,
                              color: Color(0xFF3D2B1F), size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Daftar Jurnal Mengajar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2B1F),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search bar
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
                        Text(
                          'Cari materi atau kelas...',
                          style: TextStyle(
                              fontSize: 13, color: Colors.brown.shade300),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Label + refresh
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SEMUA JURNAL',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.brown.shade500,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: ctrl.fetchJurnal,
                            child: Icon(Icons.refresh_rounded,
                                color: Colors.brown.shade500, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.filter_list_rounded,
                              color: Colors.brown.shade500, size: 16),
                          const SizedBox(width: 4),
                          Text('Filter',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.brown.shade500)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Konten
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6B1A1A)),
                      );
                    }
                    if (ctrl.errorMsg.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                color: Colors.brown.shade300, size: 48),
                            const SizedBox(height: 12),
                            Text(ctrl.errorMsg.value,
                                style: TextStyle(
                                    color: Colors.brown.shade500)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: ctrl.fetchJurnal,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF6B1A1A)),
                              child: const Text('Coba Lagi',
                                  style:
                                      TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }
                    if (ctrl.jurnalList.isEmpty) {
                      return Center(
                        child: Text('Belum ada jurnal',
                            style: TextStyle(
                                color: Colors.brown.shade400)),
                      );
                    }
                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      child: Column(
                        children: ctrl.jurnalList
                            .map((j) => _buildJurnalCard(j))
                            .toList(),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // FAB
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B1A1A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF6B1A1A).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJurnalCard(JurnalModel jurnal) {
    return GestureDetector(
      // ← KLIK CARD → PresensiSiswaPage
      onTap: () => Get.toNamed(
        AppRoutes.presensiSiswa,
        arguments: {'jurnal_id': jurnal.id, 'kelas': jurnal.kelas},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFEFE8D8),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF6B1A1A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jurnal.kelas,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B1A1A),
                      ),
                    ),
                  ),
                  Text(
                    jurnal.idKode,
                    style: TextStyle(
                        fontSize: 11, color: Colors.brown.shade400),
                  ),
                ],
              ),
            ),
            // Body card
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.menu_outlined,
                          color: Colors.brown.shade400, size: 18),
                      const SizedBox(width: 10),
                      Column(
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
                          const SizedBox(height: 2),
                          Text(
                            jurnal.mapel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3D2B1F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          color: Colors.brown.shade400, size: 18),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WAKTU',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.brown.shade400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            jurnal.waktu,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3D2B1F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.brown.shade100, height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.presensiSiswa,
                          arguments: {
                            'jurnal_id': jurnal.id,
                            'kelas': jurnal.kelas,
                          },
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Detail Jurnal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.brown.shade600,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.brown.shade500,
                                size: 16),
                          ],
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