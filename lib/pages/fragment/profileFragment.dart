import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/profileController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/components/app_widget.dart';

class ProfileFragment extends StatelessWidget {
  const ProfileFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();

    return Container(
      color: AppColors.bgMain,
      child: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'Profil Guru'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(
                  () => Column(
                    children: [
                      const AppUserAvatar(size: 88, iconSize: 44),
                      const SizedBox(height: 14),
                      Text(
                        ctrl.userName.value.isEmpty
                            ? 'Guru'
                            : ctrl.userName.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (ctrl.userRole.value.isNotEmpty)
                        AppPrimaryBadge(
                          label: ctrl.userRole.value.toUpperCase(),
                          fontSize: 10,
                          paddingH: 12,
                          paddingV: 4,
                        ),
                      const SizedBox(height: 24),
                      AppInfoCard(
                        icon: Icons.email_outlined,
                        label: 'EMAIL',
                        value: ctrl.userEmail.value.isEmpty
                            ? '-'
                            : ctrl.userEmail.value,
                      ),
                      const SizedBox(height: 24),
                      AppOutlinedButton(
                        label: 'Edit Profil',
                        icon: Icons.edit_outlined,
                        onPressed: ctrl.goToEditProfil,
                        height: 50,
                      ),
                      const SizedBox(height: 10),
                      AppPrimaryButton(
                        label: 'Keluar',
                        icon: Icons.logout_rounded,
                        onPressed: ctrl.logout,
                        isLoading: ctrl.isLoading.value,
                        height: 50,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sistem Presensi SD Cahya Nur',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.brownshade4,
                        ),
                      ),
                      const SizedBox(height: 16),
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
}
