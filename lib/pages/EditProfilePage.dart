import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/Editprofilecontroller.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/Components/app_widget.dart';

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
            AppPageHeader(
              title: 'Edit Profil',
              showBack: true,
              onBack: () => Get.back(),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: AppUserAvatar(
                        size: 88,
                        iconSize: 44,
                        showEditBadge: true,
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

                    const AppFieldLabel('Nama Lengkap'),
                    const SizedBox(height: 6),
                    AppTextFieldCard(
                      controller: ctrl.namaController,
                      hint: 'Masukkan nama lengkap',
                    ),
                    const SizedBox(height: 14),

                    const AppFieldLabel('NIP'),
                    const SizedBox(height: 6),
                    AppTextFieldCard(
                      controller: ctrl.nipController,
                      hint: 'Masukkan NIP',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    const AppFieldLabel('Email'),
                    const SizedBox(height: 6),
                    AppTextFieldCard(
                      controller: ctrl.emailController,
                      hint: 'Masukkan email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),

                    Obx(
                      () => AppPrimaryButton(
                        label: 'Simpan Perubahan',
                        icon: Icons.save_outlined,
                        onPressed: ctrl.simpanPerubahan,
                        isLoading: ctrl.isLoading.value,
                      ),
                    ),
                    const SizedBox(height: 10),

                    AppOutlinedButton(
                      label: 'Reset Password',
                      icon: Icons.lock_reset_rounded,
                      onPressed: ctrl.resetPassword,
                      color: AppColors.primary,
                      borderColor: AppColors.primary,
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
