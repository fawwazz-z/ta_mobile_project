import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/loginController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/Components/app_widget.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: Stack(
        children: [
          _buildBackgroundWatermark(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 40),

                    const AppFieldLabel('Email'),
                    const SizedBox(height: 8),
                    AppTextFieldCard(
                      controller: controller.emailController,
                      hint: 'nama@sekolah.id',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        color: AppColors.brownshade4,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const AppFieldLabel('Kata Sandi'),
                    const SizedBox(height: 8),
                    Obx(
                      () => AppTextFieldCard(
                        controller: controller.passwordController,
                        hint: 'Masukkan kata sandi',
                        obscureText: controller.obscurePassword.value,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.brownshade4,
                          size: 20,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: controller.togglePasswordVisibility,
                          child: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.brownshade4,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // _buildForgotPassword(),
                    const SizedBox(height: 28),

                    Obx(
                      () => AppPrimaryButton(
                        label: 'Masuk',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: controller.login,
                        isLoading: controller.isLoading.value,
                        height: 56,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildFooter(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundWatermark() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: 0.08,
        child: Image.asset(
          'assets/images/school_building.png',
          fit: BoxFit.cover,
          height: 300,
          errorBuilder: (context, error, stackTrace) =>
              const SizedBox(height: 300),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.bgField,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.school_rounded,
        size: 44,
        color: Color(0xFF6B1A1A),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Masuk',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sistem Manajemen & Presensi Guru',
          style: TextStyle(fontSize: 14, color: AppColors.brownshade4),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: controller.forgotPassword,
        child: const Text(
          'Lupa Kata Sandi?',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Mengalami kendala teknis?',
          style: TextStyle(fontSize: 13, color: AppColors.brownshade4),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Hubungi Admin IT Sekolah',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
