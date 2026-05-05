import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/loginController.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC8),
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
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 12),
                    _buildForgotPassword(),
                    const SizedBox(height: 28),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    // ── Tombol Google ──
                    _buildGoogleButton(),
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
        color: const Color(0xFFD4C4A8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.school_rounded, size: 44, color: Color(0xFF6B1A1A)),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text('Masuk',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B1A1A))),
        const SizedBox(height: 6),
        Text('Sistem Manajemen & Presensi Guru',
            style: TextStyle(fontSize: 14, color: Colors.brown.shade400)),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D2B1F))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
              hint: 'nama@sekolah.id', icon: Icons.alternate_email_rounded),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kata Sandi',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D2B1F))),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              decoration: _inputDecoration(
                hint: 'Masukkan kata sandi',
                icon: Icons.lock_outline_rounded,
                suffix: GestureDetector(
                  onTap: controller.togglePasswordVisibility,
                  child: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.brown.shade400,
                    size: 20,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: controller.forgotPassword,
        child: const Text('Lupa Kata Sandi?',
            style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B1A1A),
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() => ElevatedButton(
            onPressed:
                controller.isLoading.value ? null : controller.login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B1A1A),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF6B1A1A).withOpacity(0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Masuk',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          )),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Divider(color: Colors.brown.shade300, thickness: 0.8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('ATAU MASUK DENGAN',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.brown.shade400,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
            child: Divider(color: Colors.brown.shade300, thickness: 0.8)),
      ],
    );
  }

  // ── Tombol Google Sign-In ────────────────────────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() => OutlinedButton(
            onPressed: controller.isLoadingGoogle.value
                ? null
                : controller.loginWithGoogle,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.brown.shade200, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: controller.isLoadingGoogle.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Color(0xFF6B1A1A), strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Google sederhana dengan warna aslinya
                      _googleLogo(),
                      const SizedBox(width: 12),
                      const Text(
                        'Masuk dengan Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D2B1F),
                        ),
                      ),
                    ],
                  ),
          )),
    );
  }

  /// Logo Google 4-warna menggunakan CustomPaint ringan
  Widget _googleLogo() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text('Mengalami kendala teknis?',
            style: TextStyle(fontSize: 13, color: Colors.brown.shade400)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {},
          child: const Text('Hubungi Admin IT Sekolah',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B1A1A),
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.brown.shade400, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF6B1A1A), width: 1.5),
      ),
    );
  }
}

// ── Google Logo Painter ───────────────────────────────────────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Lingkaran luar putih sebagai background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius, bgPaint);

    // Gambar huruf "G" Google sederhana dengan 4 warna via arc
    const strokeW = 4.5;
    final rect = Rect.fromCircle(center: center, radius: radius - 2);

    final paints = [
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    ];

    // 4 kuadran warna (90° masing-masing)
    const step = 3.14159 / 2; // π/2
    for (int i = 0; i < 4; i++) {
      canvas.drawArc(rect, i * step - 3.14159 / 4, step, false, paints[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}