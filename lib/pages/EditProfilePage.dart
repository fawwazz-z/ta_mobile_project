import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/Editprofilecontroller.dart';
import 'package:ta_mobile_project/routes/colors.dart';

class EditProfilPages extends StatelessWidget {
  const EditProfilPages({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EditProfileController>();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          color: AppColors.textDark, size: 22),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.bgField,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 3),
                            ),
                            child: const Icon(Icons.person_outline_rounded,
                                color: AppColors.primary, size: 44),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_outlined,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'INFORMASI PERSONAL',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.brownshade2,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Nama ──────────────────────────────────────────────
                    _buildFieldLabel('Nama Lengkap'),
                    const SizedBox(height: 6),
                    _buildEditableField(
                      controller: ctrl.namaController,
                      hint: 'Masukkan nama lengkap',
                    ),
                    const SizedBox(height: 14),

                    // ── NIP ───────────────────────────────────────────────
                    _buildFieldLabel('NIP'),
                    const SizedBox(height: 6),
                    _buildEditableField(
                      controller: ctrl.nipController,
                      hint: 'Masukkan NIP',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    // ── Email ─────────────────────────────────────────────
                    _buildFieldLabel('Email'),
                    const SizedBox(height: 6),
                    _buildEditableField(
                      controller: ctrl.emailController,
                      hint: 'Masukkan email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),

                    // ── Tombol Simpan ─────────────────────────────────────
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: ctrl.isLoading.value
                                ? null
                                : ctrl.simpanPerubahan,
                            icon: ctrl.isLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: AppColors.white, strokeWidth: 2))
                                : const Icon(Icons.save_outlined,
                                    size: 18, color: AppColors.white),
                            label: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        )),
                    const SizedBox(height: 10),

                    // ── Tombol Reset Password ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: ctrl.resetPassword,
                        icon: const Icon(Icons.lock_reset_rounded,
                            size: 18, color: AppColors.primary),
                        label: const Text(
                          'Reset Password',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bgCard,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3D2B1F),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.brownshade  , fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}