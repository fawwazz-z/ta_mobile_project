import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/mainController.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final MainController controller = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFEFE8D8), // Warna latar global
        body: IndexedStack(
          // Menggunakan IndexedStack agar state halaman terjaga
          index: controller.selectedIndex.value,
          children: controller.fragments,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.history_rounded, 'label': 'Riwayat'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Jadwal'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = controller.selectedIndex.value == index;
            return GestureDetector(
              onTap: () => controller.changeIndex(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: isSelected
                        ? const Color(0xFF6B1A1A)
                        : Colors.brown.shade300,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF6B1A1A)
                          : Colors.brown.shade300,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
