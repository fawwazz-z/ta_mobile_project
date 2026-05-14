import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/SplashScreenController.dart';
import 'package:ta_mobile_project/routes/colors.dart';

// =============================================================================
// SPLASH SCREEN — Reusable & Refactored
// =============================================================================

// -----------------------------------------------------------------------------
// SplashAnimatedWrapper
//   Widget reusable yang membungkus konten dengan animasi fade + scale.
//   Bisa dipakai di halaman lain yang butuh animasi masuk serupa.
//
// Contoh penggunaan:
//   SplashAnimatedWrapper(
//     duration: Duration(milliseconds: 1200),
//     child: YourWidget(),
//   )
// -----------------------------------------------------------------------------
class SplashAnimatedWrapper extends StatefulWidget {
  const SplashAnimatedWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.fadeCurve = Curves.easeIn,
    this.scaleCurve = Curves.easeOutBack,
    this.scaleBegin = 0.85,
  });

  final Widget child;
  final Duration duration;
  final Curve fadeCurve;
  final Curve scaleCurve;
  final double scaleBegin;

  @override
  State<SplashAnimatedWrapper> createState() => _SplashAnimatedWrapperState();
}

class _SplashAnimatedWrapperState extends State<SplashAnimatedWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: widget.fadeCurve),
    );
    _scaleAnim = Tween<double>(
      begin: widget.scaleBegin,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animController, curve: widget.scaleCurve),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(scale: _scaleAnim, child: widget.child),
    );
  }
}


class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.assetPath,
    this.width = 200,
    this.fallbackText = 'LOGO',
    this.placeholderSize = 230,
  });

  final String assetPath;
  final double width;
  final String fallbackText;
  final double placeholderSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _SplashLogoPlaceholder(
        text: fallbackText,
        size: placeholderSize,
      ),
    );
  }
}

class _SplashLogoPlaceholder extends StatelessWidget {
  const _SplashLogoPlaceholder({required this.text, this.size = 230});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class SplashWelcomeText extends StatelessWidget {
  const SplashWelcomeText({
    super.key,
    required this.appName,
    this.greeting = 'Welcome to',
    this.fontSize = 28,
    this.color = AppColors.primary,
  });

  final String appName;
  final String greeting;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$greeting\n$appName',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.3,
      ),
    );
  }
}


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: SplashAnimatedWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                const SplashWelcomeText(appName: 'SD Cahaya Nur'),

                const Expanded(
                  child: Center(
                    child: SplashLogo(
                      assetPath: 'assets/images/logo_cois.png',
                      width: 200,
                      fallbackText: 'COIS',
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}