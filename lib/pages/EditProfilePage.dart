import 'package:flutter/material.dart';

class EditProfilPages extends StatelessWidget {
  const EditProfilPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC8),
      body: SafeArea(
        child: Column(
          children: [
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
                    child: const Icon(Icons.chevron_left_rounded,
                        color: Color(0xFF3D2B1F), size: 22),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profil',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with edit icon
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4C4A8),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.person_outline_rounded,
                                color: Color(0xFF6B1A1A), size: 44),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6B1A1A),
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
                    // Section label
                    Text(
                      'INFORMASI PERSONAL',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.brown.shade500,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Nama Lengkap
                    _buildFieldLabel('Nama Lengkap'),
                    const SizedBox(height: 6),
                    _buildTextField('Ahmad Fauzi, S.Pd.'),
                    const SizedBox(height: 14),
                    // NIP
                    _buildFieldLabel('NIP'),
                    const SizedBox(height: 6),
                    _buildTextField('19850312 201001 1 004'),
                    const SizedBox(height: 14),
                    // Email
                    _buildFieldLabel('Email'),
                    const SizedBox(height: 6),
                    _buildTextField('ahmad.fauzi@dikbud.go.id'),
                    const SizedBox(height: 28),
                    // Simpan Perubahan
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.save_outlined,
                            size: 18, color: Colors.white),
                        label: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B1A1A),
                          disabledBackgroundColor: const Color(0xFF6B1A1A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Reset Password
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: Icon(Icons.lock_reset_rounded,
                            size: 18,
                            color: const Color(0xFF6B1A1A)),
                        label: const Text(
                          'Reset Password',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B1A1A)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFE8D8),
                          disabledBackgroundColor: const Color(0xFFEFE8D8),
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
            _buildBottomNav(selectedIndex: 3),
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

  Widget _buildTextField(String value) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.brown.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF3D2B1F),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav({required int selectedIndex}) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.history_rounded, 'label': 'Riwayat'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Jadwal'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.brown.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final sel = i == selectedIndex;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(items[i]['icon'] as IconData,
                  color: sel
                      ? const Color(0xFF6B1A1A)
                      : Colors.brown.shade300,
                  size: 24),
              const SizedBox(height: 3),
              Text(items[i]['label'] as String,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          sel ? FontWeight.w600 : FontWeight.normal,
                      color: sel
                          ? const Color(0xFF6B1A1A)
                          : Colors.brown.shade300)),
            ],
          );
        }),
      ),
    );
  }
}