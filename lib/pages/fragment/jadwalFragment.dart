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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Jadwal Mengajar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2B1F)),
                    ),
                  ),
                  GestureDetector(
                    onTap: ctrl.fetchJadwal,
                    child: Icon(Icons.refresh_rounded,
                        color: Colors.brown.shade500, size: 20),
                  ),
                ],
              ),
            ),
            // Konten
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6B1A1A)));
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
                            style: TextStyle(color: Colors.brown.shade500)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: ctrl.fetchJadwal,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B1A1A)),
                          child: const Text('Coba Lagi',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                if (ctrl.jadwalList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: Colors.brown.shade300, size: 48),
                        const SizedBox(height: 12),
                        Text('Belum ada jadwal mengajar',
                            style: TextStyle(color: Colors.brown.shade400)),
                      ],
                    ),
                  );
                }

                // Group per hari
                final days = ctrl.dayOrder;
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: days.map((day) {
                      final items = ctrl.getByDay(day);
                      return _buildDaySection(day, items);
                    }).toList(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(String hari, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            hari.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.brown.shade500,
                letterSpacing: 1.2),
          ),
        ),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    color: Colors.brown.shade300, size: 20),
                const SizedBox(width: 10),
                Text('Tidak ada jadwal mengajar',
                    style: TextStyle(
                        fontSize: 13, color: Colors.brown.shade400)),
              ],
            ),
          )
        else
          ...items.map((item) => _buildJadwalCard(item)).toList(),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildJadwalCard(dynamic item) {
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
                color: Colors.brown.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xFFEFE8D8),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.menu_book_outlined,
                  color: Color(0xFF6B1A1A), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MATA PELAJARAN',
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.brown.shade400,
                          letterSpacing: 0.5)),
                  Text(item.subjectName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2B1F))),
                  const SizedBox(height: 2),
                  Text(item.classroomName,
                      style: TextStyle(
                          fontSize: 12, color: Colors.brown.shade500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item.startTime} - ${item.endTime}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D2B1F))),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFF6B1A1A),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('JADWAL',
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}