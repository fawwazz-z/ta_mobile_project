import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_mobile_project/controllers/riwayatController.dart';
import 'package:ta_mobile_project/routes/colors.dart';
import 'package:ta_mobile_project/Components/app_widget.dart';

class RiwayatFragment extends StatelessWidget {
  RiwayatFragment({super.key});

  final RiwayatController controller = Get.find<RiwayatController>();

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':     return AppColors.success;
      case 'terlambat': return AppColors.error;
      case 'sakit':     return AppColors.warning;
      case 'izin':      return AppColors.info;
      default:          return AppColors.defalt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8DCC8),
      child: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Riwayat Presensi',
              action: AppIconButton(
                icon: Icons.refresh_rounded,
                onTap: controller.fetchHistory,
              ),
            ),

            _buildSearchBar(),
            const SizedBox(height: 10),

            Obx(
              () => AppMonthSelector(
                label: controller.selectedMonthLabel,
                onPrev: controller.previousMonth,
                onNext: controller.nextMonth,
              ),
            ),
            const SizedBox(height: 12),

            // ── List / State ───────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const AppLoadingCenter(color: AppColors.textDark);
                }

                if (controller.errorMessage.isNotEmpty) {
                  return AppErrorState(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchHistory,
                  );
                }

                if (controller.filteredRecords.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.inbox_rounded,
                    title: controller.searchQuery.isNotEmpty
                        ? 'Tidak ada hasil untuk\n"${controller.searchQuery.value}"'
                        : 'Tidak ada data presensi\npada bulan ini',
                    iconColor: AppColors.defalt,
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
                        tanggal: r.formattedDate,
                        status: r.displayStatus,
                        statusColor: _statusColor(r.displayStatus),
                        masuk: r.formattedCheckIn,
                        pulang: r.formattedCheckOut,
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

  // ── Search Bar (tetap custom karena Obx di suffixIcon) ──────────────────
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
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textDark,
              size: 20,
            ),
            suffixIcon: Obx(
              () => controller.searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: controller.clearSearch,
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.defalt,
                        size: 18,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── Card ────────────────────────────────────────────────────────────────
  Widget _buildRiwayatCard({
    required String tanggal,
    required String status,
    required Color statusColor,
    required String masuk,
    required String pulang,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        blurRadius: 0,
        shadowColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HARI/TANGGAL',
                  style: TextStyle(fontSize: 10, color: AppColors.defalt),
                ),
                AppStatusBadge(label: status, color: statusColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tanggal,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTimeDisplay(
                    label: 'JAM MASUK',
                    value: masuk,
                    labelFontSize: 10,
                    valueFontSize: 16,
                  ),
                ),
                Expanded(
                  child: AppTimeDisplay(
                    label: 'JAM PULANG',
                    value: pulang,
                    labelFontSize: 10,
                    valueFontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}