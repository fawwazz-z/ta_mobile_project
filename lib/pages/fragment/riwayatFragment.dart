import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';
import 'package:ta_mobile_project/routes/colors.dart';

class RiwayatFragment extends StatelessWidget {
  RiwayatFragment({super.key});

  // Gunakan find, bukan put — controller sudah di-register oleh RiwayatBinding
  // MainController membuat fragment di onInit sehingga binding sudah jalan duluan
  final RiwayatController controller = Get.find<RiwayatController>();

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':      return AppColors.success;
      case 'terlambat':  return AppColors.error;
      case 'sakit':      return AppColors.warning;
      case 'izin':       return AppColors.info;
      default:           return AppColors.defalt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8DCC8),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Presensi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.fetchHistory,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ─────────────────────────────────────────────────
            _buildSearchBar(),
            const SizedBox(height: 10),

            // ── Month Selector ─────────────────────────────────────────────
            _buildMonthSelector(),
            const SizedBox(height: 12),

            // ── List / State ───────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.textDark),
                  );
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 48, color: AppColors.defalt),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: AppColors.defalt),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.fetchHistory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Coba Lagi',
                              style: TextStyle(color: AppColors.white)),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredRecords.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_rounded,
                            size: 48, color: AppColors.defalt),
                        const SizedBox(height: 12),
                        Text(
                          controller.searchQuery.isNotEmpty
                              ? 'Tidak ada hasil untuk\n"${controller.searchQuery.value}"'
                              : 'Tidak ada data presensi\npada bulan ini',
                          style: const TextStyle(color: AppColors.defalt),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchHistory,
                  color: AppColors.textDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.filteredRecords.length,
                    itemBuilder: (_, i) {
                      final r = controller.filteredRecords[i];
                      return _buildRiwayatCard(
                        tanggal:     r.formattedDate,
                        status:      r.displayStatus,
                        statusColor: _statusColor(r.displayStatus),
                        masuk:       r.formattedCheckIn,
                        pulang:      r.formattedCheckOut,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Cari tanggal atau status...',
            hintStyle: const TextStyle(color: AppColors.defalt, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textDark, size: 20),
            suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clearSearch,
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.defalt, size: 18),
                  )
                : const SizedBox.shrink()),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── Month Selector ──────────────────────────────────────────────────────────
  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: controller.previousMonth,
              child: const Icon(Icons.chevron_left_rounded, size: 26),
            ),
            Obx(() => Text(
                  controller.selectedMonthLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                )),
            GestureDetector(
              onTap: controller.nextMonth,
              child: const Icon(Icons.chevron_right_rounded, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card ────────────────────────────────────────────────────────────────────
  Widget _buildRiwayatCard({
    required String tanggal,
    required String status,
    required Color  statusColor,
    required String masuk,
    required String pulang,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HARI/TANGGAL',
                  style: TextStyle(fontSize: 10, color: AppColors.defalt)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '● $status',
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(tanggal,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textDark)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTimeInfo('JAM MASUK', masuk)),
              Expanded(child: _buildTimeInfo('JAM PULANG', pulang)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.defalt)),
        Text(time,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark)),
      ],
    );
  }
}