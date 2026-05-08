import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/refleksiController.dart';
import 'package:ta_mobile_project/routes/colors.dart';

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
            _buildAppBar(ctrl),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Refleksi Hari Ini',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRefleksiTextField(textController),
                    const SizedBox(height: 16),
                    _buildTipsBox(),
                  ],
                ),
              ),
            ),
            _buildSaveButton(ctrl),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(RefleksiController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textDark,
                size: 22,
              ),
            ),
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
                  style: TextStyle(fontSize: 11, color: AppColors.brownshade2),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note_outlined,
              color: Colors.white,
              size: 22,
            ),
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
                  style: TextStyle(fontSize: 11, color: AppColors.brownshade4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefleksiTextField(TextEditingController textController) {
    return Container(
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
    );
  }

  Widget _buildTipsBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '💡 Tips: Tuliskan kendala, keberhasilan, '
              'dan tindak lanjut untuk pertemuan berikutnya.',
              style: TextStyle(fontSize: 11, color: Colors.brown, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(RefleksiController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: ctrl.isSaving.value
                ? null
                : () {
                    if (ctrl.refleksiText.value.isNotEmpty) {
                      ctrl.updateRefleksi();
                    } else {
                      ctrl.simpanRefleksi();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: ctrl.isSaving.value
                ? const CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Refleksi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
