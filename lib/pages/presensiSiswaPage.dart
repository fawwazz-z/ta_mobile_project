import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/presensiSiswaController.dart';

class PresensiSiswaPages extends StatelessWidget {
  const PresensiSiswaPages({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PresensiSiswaController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC8),
      body: SafeArea(
        child: Column(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Presensi Siswa',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3D2B1F))),
                        Text(
                          '${ctrl.kelasNama} • ${ctrl.mapelNama}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.brown.shade500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                    borderRadius: BorderRadius.circular(12)),
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

            // List siswa
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF6B1A1A)));
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
                            style:
                                TextStyle(color: Colors.brown.shade500)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: ctrl.fetchSiswa,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B1A1A)),
                          child: const Text('Coba Lagi',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                if (ctrl.siswaList.isEmpty) {
                  return Center(
                    child: Text('Tidak ada data siswa',
                        style: TextStyle(color: Colors.brown.shade400)),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ...ctrl.siswaList.map((siswa) =>
                          _buildSiswaCard(siswa, ctrl)),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),

            // Tombol Simpan
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: ctrl.isSaving.value
                          ? null
                          : () => _showMateriDialog(ctrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B1A1A),
                        disabledBackgroundColor: const Color(0xFF6B1A1A).withOpacity(0.6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: ctrl.isSaving.value
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Simpan Presensi',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog input materi sebelum simpan presensi
  void _showMateriDialog(PresensiSiswaController ctrl) {
    final materiCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Materi Pembelajaran',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF3D2B1F))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan materi yang diajarkan hari ini:',
                style: TextStyle(
                    fontSize: 13, color: Colors.brown.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: materiCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Teks Eksposisi - Struktur dan Ciri-ciri',
                hintStyle: TextStyle(
                    fontSize: 12, color: Colors.brown.shade300),
                filled: true,
                fillColor: const Color(0xFFF5EFE6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal',
                style: TextStyle(color: Colors.brown.shade500)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.simpanPresensi(material: materiCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B1A1A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Simpan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(SiswaModel siswa, PresensiSiswaController ctrl) {
    const options = ['hadir', 'izin', 'sakit', 'alpa'];
    final Map<String, Color> activeColors = {
      'hadir': const Color(0xFF6B1A1A),
      'izin':  const Color(0xFF1565C0),
      'sakit': const Color(0xFFE65100),
      'alpa':  const Color(0xFF424242),
    };

    return Obx(() {
      final currentStatus = ctrl.siswaList
          .firstWhere((s) => s.id == siswa.id)
          .status
          .toLowerCase();

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
                  decoration: const BoxDecoration(
                      color: Color(0xFFEFE8D8), shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Color(0xFF6B1A1A), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(siswa.nama,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D2B1F))),
                    Text('NIS: ${siswa.nis}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.brown.shade400)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: options.map((opt) {
                final isSelected = opt == currentStatus;
                final color =
                    activeColors[opt] ?? const Color(0xFF6B1A1A);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.setStatus(siswa.id, opt),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : const Color(0xFFF5EFE6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          opt.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.brown.shade400),
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
    });
  }
}