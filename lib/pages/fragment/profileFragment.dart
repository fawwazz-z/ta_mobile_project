import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/profileController.dart';
import 'package:ta_mobile_project/routes/colors.dart';

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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Profil Guru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => Column(
                      children: [
                        // Avatar
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                              color: AppColors.bgField,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 3)),
                          child: const Icon(Icons.person_outline_rounded,
                              color: AppColors.primary, size: 44),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          ctrl.userName.value.isEmpty
                              ? 'Guru'
                              : ctrl.userName.value,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        if (ctrl.userRole.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              ctrl.userRole.value.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.white,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        const SizedBox(height: 24),
                        _buildInfoCard(
                            icon: Icons.email_outlined,
                            label: 'EMAIL',
                            value: ctrl.userEmail.value.isEmpty
                                ? '-'
                                : ctrl.userEmail.value),
                        const SizedBox(height: 24),
                        // Edit Profil
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: ctrl.goToEditProfil,
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.textDark, size: 18),
                            label: const Text('Edit Profil',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.borderFaint, width: 1.2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              backgroundColor: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Logout
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed:
                                ctrl.isLoading.value ? null : ctrl.logout,
                            icon: ctrl.isLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: AppColors.white, strokeWidth: 2))
                                : const Icon(Icons.logout_rounded,
                                    size: 18, color: AppColors.white),
                            label: const Text('Keluar',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('🏫 Sistem Presensi SD Cahya Nur',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.brownshade4)),
                        const SizedBox(height: 16),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String label,
      required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.brownshade2.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.brownshade4,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ],
          ),
        ],
      ),
    );
  }
}