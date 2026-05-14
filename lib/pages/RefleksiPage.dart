import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/refleksiController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/Components/app_widget.dart';

class RefleksiPage extends StatelessWidget {
  const RefleksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RefleksiController>();
    final textController = TextEditingController(text: ctrl.refleksiText.value);

    textController.addListener(() {
      ctrl.refleksiText.value = textController.text;
    });

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Get.back(),
                    backgroundColor: AppColors.bgCard,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Refleksi Pembelajaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${ctrl.kelasNama} • ${ctrl.mapelNama}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.brownshade2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      color: AppColors.infoLight.withOpacity(0.3),
                      blurRadius: 0,
                      shadowColor: Colors.transparent,
                      child: Row(
                        children: [
                          // ✅ AppIconTile untuk ikon catatan
                          AppIconTile(
                            icon: Icons.edit_note_outlined,
                            color: Colors.white,
                            backgroundColor: AppColors.info,
                            tileSize: 40,
                            iconSize: 22,
                            borderRadius: 12,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan Refleksi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Isikan refleksi setelah proses pembelajaran',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.brownshade4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const AppFieldLabel('Refleksi Hari Ini'),
                    const SizedBox(height: 8),

                    Container(
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
                      child: TextField(
                        controller: textController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText:
                              'Contoh: Siswa sangat antusias dalam memahami materi.\n'
                              'Sebagian siswa masih perlu bimbingan dalam mengerjakan latihan.\n'
                              'Pembelajaran berikutnya perlu menggunakan metode yang lebih interaktif.',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.brown.shade300,
                            height: 1.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Tips box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '💡 Tips: Tuliskan kendala, keberhasilan, '
                              'dan tindak lanjut untuk pertemuan berikutnya.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.brown,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Obx(
                () => AppPrimaryButton(
                  label: 'Simpan Refleksi',
                  icon: Icons.save_outlined,
                  onPressed: () {
                    if (ctrl.refleksiText.value.isNotEmpty) {
                      ctrl.updateRefleksi();
                    } else {
                      ctrl.simpanRefleksi();
                    }
                  },
                  isLoading: ctrl.isSaving.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
