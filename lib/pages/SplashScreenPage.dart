import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/routes/route.dart';
import 'package:ta_mobile_project/routes/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Pindah ke loginPage setelah 3 detik
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) Get.offNamed(AppRoutes.loginPage);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain, 
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // ── Teks Welcome ──────────────────────────────────────────
                  const Text(
                    'Welcome to\nSD Cahaya Nur',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),

                  // ── Logo di tengah ────────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_cois.png',
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _placeholderLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderLogo() {
    return Container(
      width: 230,
      height: 230,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: const Center(
        child: Text(
          'COIS',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}