import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/refleksiController.dart';

class RefleksiPage extends StatelessWidget {
  const RefleksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RefleksiController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  const Expanded(
                    child: Text(
                      'Catatan Refleksi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2B1F)),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info kelas
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ctrl.kelasNama,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3D2B1F))),
                              Text(ctrl.mapelNama,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.brown.shade500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Label
                    Text(
                      'CATATAN REFLEKSI MENGAJAR',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.brown.shade500,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),

                    // Text area refleksi
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.brown.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: TextField(
                        controller: ctrl.refleksiController,
                        maxLines: 8,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF3D2B1F)),
                        decoration: InputDecoration(
                          hintText:
                              'Tuliskan refleksi pembelajaran hari ini...\n\nContoh: Siswa antusias dalam diskusi kelompok. Perlu lebih banyak waktu untuk latihan soal.',
                          hintStyle: TextStyle(
                              fontSize: 13, color: Colors.brown.shade300),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF6B1A1A), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Simpan Refleksi
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: ctrl.isSaving.value
                                ? null
                                : ctrl.simpanRefleksi,
                            icon: ctrl.isSaving.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.save_outlined,
                                    size: 18, color: Colors.white),
                            label: const Text('Simpan Refleksi',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B1A1A),
                              disabledBackgroundColor:
                                  const Color(0xFF6B1A1A).withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        )),
                    const SizedBox(height: 10),

                    // Lewati
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: ctrl.lewati,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFBCA98A), width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text('Lewati',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D2B1F))),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}