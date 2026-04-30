import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/profileController.dart';

class ProfileFragment extends StatelessWidget {
  const ProfileFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // ProfileController sudah di-inject oleh MainBinding
    final ctrl = Get.find<ProfileController>();

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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF3D2B1F),
                      size: 22,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Profil Guru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2B1F),
                      ),
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
                  children: [
                    // Avatar
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4C4A8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF6B1A1A),
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ahmad Fauzi, S.Pd.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2B1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIP. 19850312 201001 1 004',
                      style: TextStyle(
                          fontSize: 13, color: Colors.brown.shade500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B1A1A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GURU BAHASA INDONESIA',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      icon: Icons.business_outlined,
                      label: 'UNIT KERJA',
                      value: 'SMA Negeri 1 Jakarta',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      label: 'EMAIL',
                      value: 'ahmad.fauzi@dikbud.go.id',
                    ),
                    const SizedBox(height: 24),

                    // Tombol Edit Profil → navigasi ke EditProfilPage
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: ctrl.goToEditProfil,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF3D2B1F),
                          size: 18,
                        ),
                        label: const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3D2B1F),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFBCA98A), width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tombol Keluar → logout via ProfileController
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: ctrl.isLoading.value
                                ? null
                                : ctrl.logout,
                            icon: ctrl.isLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.logout_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                            label: const Text(
                              'Keluar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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
                    const SizedBox(height: 20),
                    Text(
                      '🏫 Sistem Presensi SD Cahya Nur',
                      style: TextStyle(
                          fontSize: 11, color: Colors.brown.shade400),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B1A1A), size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.brown.shade400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D2B1F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}