import 'package:flutter/material.dart';
import 'package:ta_mobile_project/routes/colors.dart';

// =============================================================================
// APP WIDGETS — Reusable Components
// =============================================================================
// Kumpulan widget reusable yang diekstrak dari:
//   HomeFragment, JadwalFragment, RiwayatFragment, ProfileFragment,
//   EditProfilPages, JurnalPage, LoginPage, MainPage
// =============================================================================

// -----------------------------------------------------------------------------
// 1. AppPageHeader
//    Header standar dengan tombol back (opsional), judul tengah, dan aksi kanan
//
// Contoh penggunaan:
//   AppPageHeader(title: 'Jadwal Mengajar')
//   AppPageHeader(title: 'Edit Profil', showBack: true)
//   AppPageHeader(title: 'Home', action: Icon(Icons.refresh))
// -----------------------------------------------------------------------------
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.action,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  /// Widget di sisi kanan (misal tombol refresh, ikon notif, dsb.)
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          if (showBack)
            AppIconButton(
              icon: Icons.chevron_left_rounded,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            )
          else
            const SizedBox(width: 36),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (action != null)
            action!
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. AppIconButton
//    Tombol bulat/rounded kecil dengan ikon — dipakai di header, refresh, back
//
// Contoh penggunaan:
//   AppIconButton(icon: Icons.refresh_rounded, onTap: ctrl.fetchData)
//   AppIconButton(icon: Icons.chevron_left_rounded, size: 22)
// -----------------------------------------------------------------------------
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 20,
    this.iconColor = AppColors.textDark,
    this.backgroundColor,
    this.borderRadius = 10,
    this.padding = 0,
    this.child,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color iconColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double padding;

  /// Override seluruh konten (misal loading indicator)
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child ??
            Icon(icon, color: iconColor, size: size),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. AppStatusBadge
//    Badge label berwarna — status hadir/terlambat/izin/sakit, dll.
//
// Contoh penggunaan:
//   AppStatusBadge(label: 'Hadir', color: AppColors.success)
//   AppStatusBadge(label: 'Sudah Diisi', color: Colors.green, dot: false)
//   AppStatusBadge(label: 'HARI INI', color: AppColors.primary, fontSize: 9)
// -----------------------------------------------------------------------------
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.dot = true,
    this.fontSize = 11,
    this.paddingH = 8,
    this.paddingV = 3,
  });

  final String label;
  final Color color;
  final bool dot;
  final double fontSize;
  final double paddingH;
  final double paddingV;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dot ? '● $label' : label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. AppPrimaryBadge
//    Badge dengan background solid (bukan transparan) — untuk label utama
//
// Contoh penggunaan:
//   AppPrimaryBadge(label: '07:30')
//   AppPrimaryBadge(label: 'GURU', color: AppColors.primary)
// -----------------------------------------------------------------------------
class AppPrimaryBadge extends StatelessWidget {
  const AppPrimaryBadge({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.paddingH = 10,
    this.paddingV = 4,
  });

  final String label;
  final Color color;
  final Color textColor;
  final double fontSize;
  final double paddingH;
  final double paddingV;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. AppIconTile
//    Ikon berwarna dalam kotak rounded — dipakai di stat card, jadwal, jurnal
//
// Contoh penggunaan:
//   AppIconTile(icon: Icons.menu_book_outlined, color: AppColors.info, bg: AppColors.infoLight)
//   AppIconTile(icon: Icons.medical_services_outlined, color: AppColors.warning, size: 38)
// -----------------------------------------------------------------------------
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.iconSize = 22,
    this.tileSize = 42,
    this.borderRadius = 12,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double iconSize;
  final double tileSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. AppCard
//    Container card dengan shadow dan rounded corner standar
//
// Contoh penggunaan:
//   AppCard(child: Text('Isi'))
//   AppCard(padding: EdgeInsets.all(20), child: Column(...))
// -----------------------------------------------------------------------------
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16.0,
    this.color = AppColors.white,
    this.shadowColor = AppColors.shadow,
    this.blurRadius = 12,
    this.shadowOffset = const Offset(0, 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;
  final Color shadowColor;
  final double blurRadius;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// 7. AppTimeDisplay
//    Tampilan jam (label + nilai) — dipakai di presensi card & riwayat card
//
// Contoh penggunaan:
//   AppTimeDisplay(label: 'MASUK', value: '07:45', filled: true)
//   AppTimeDisplay(label: 'JAM PULANG', value: '--:--')
// -----------------------------------------------------------------------------
class AppTimeDisplay extends StatelessWidget {
  const AppTimeDisplay({
    super.key,
    required this.label,
    required this.value,
    this.filled = false,
    this.labelFontSize = 11,
    this.valueFontSize = 20,
  });

  final String label;
  final String value;

  /// Jika true, value ditampilkan dengan warna AppColors.primary
  final bool filled;
  final double labelFontSize;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: AppColors.brownshade4,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: filled ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 8. AppStatCard
//    Kartu statistik kecil dengan ikon, label, dan nilai — di HomeFragment
//
// Contoh penggunaan:
//   AppStatCard(
//     icon: Icons.calendar_month_outlined,
//     iconColor: AppColors.info,
//     iconBg: AppColors.infoLight,
//     label: 'KEHADIRAN',
//     value: '95%',
//   )
// -----------------------------------------------------------------------------
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(
            icon: icon,
            color: iconColor,
            backgroundColor: iconBg,
            tileSize: 38,
            borderRadius: 10,
            iconSize: 20,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.brownshade4,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 9. AppEmptyState
//    State kosong generik dengan ikon, judul, dan subtitle
//
// Contoh penggunaan:
//   AppEmptyState(
//     icon: Icons.inbox_rounded,
//     title: 'Tidak ada data',
//     subtitle: 'Belum ada presensi bulan ini',
//   )
// -----------------------------------------------------------------------------
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor = AppColors.defalt,
    this.iconSize = 56,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.brownshade4,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.brownshade,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 10. AppErrorState
//     State error dengan ikon wifi off, pesan, dan tombol retry
//
// Contoh penggunaan:
//   AppErrorState(
//     message: 'Gagal memuat data',
//     onRetry: ctrl.fetchData,
//   )
// -----------------------------------------------------------------------------
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Coba Lagi',
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.brownshade, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.brownshade2,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: retryLabel,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 11. AppPrimaryButton
//     Tombol utama ElevatedButton dengan loading state
//
// Contoh penggunaan:
//   AppPrimaryButton(label: 'Simpan', onPressed: ctrl.save)
//   AppPrimaryButton(label: 'Masuk', icon: Icons.arrow_forward_rounded, isLoading: ctrl.isLoading.value)
// -----------------------------------------------------------------------------
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color = AppColors.primary,
    this.height = 52,
    this.fontSize = 15,
    this.borderRadius = 14.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color color;
  final double height;
  final double fontSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.6),
          foregroundColor: AppColors.white,
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 12. AppOutlinedButton
//     Tombol outlined (border saja) — untuk aksi sekunder
//
// Contoh penggunaan:
//   AppOutlinedButton(label: 'Edit Profil', icon: Icons.edit_outlined, onPressed: ...)
// -----------------------------------------------------------------------------
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.textDark,
    this.borderColor = AppColors.borderFaint,
    this.height = 50,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final Color borderColor;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: BorderSide(color: borderColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 13. AppMonthSelector
//     Navigasi bulan — dipakai di RiwayatFragment & JurnalPage
//
// Contoh penggunaan:
//   AppMonthSelector(
//     label: ctrl.selectedMonthLabel,
//     onPrev: ctrl.previousMonth,
//     onNext: ctrl.nextMonth,
//   )
// -----------------------------------------------------------------------------
class AppMonthSelector extends StatelessWidget {
  const AppMonthSelector({
    super.key,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onPrev,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_left_rounded, size: 24),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: onNext,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_right_rounded, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 14. AppInfoCard
//    Kartu info satu baris (ikon + label kecil + nilai) — di ProfileFragment
//
// Contoh penggunaan:
//   AppInfoCard(icon: Icons.email_outlined, label: 'EMAIL', value: 'guru@sd.sch.id')
//   AppInfoCard(icon: Icons.badge_outlined, label: 'NIP', value: '198001012010011001')
// -----------------------------------------------------------------------------
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      shadowColor: AppColors.shadow,
      blurRadius: 6,
      shadowOffset: const Offset(0, 2),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.brownshade4,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 15. AppTextFieldCard
//    TextField di dalam container card — dipakai di EditProfilPages & search bar
//
// Contoh penggunaan:
//   AppTextFieldCard(controller: ctrl.namaController, hint: 'Nama lengkap')
//   AppTextFieldCard(controller: ctrl.emailController, keyboardType: TextInputType.emailAddress)
// -----------------------------------------------------------------------------
class AppTextFieldCard extends StatelessWidget {
  const AppTextFieldCard({
    super.key,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.brownshade,
            fontSize: 14,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 16. AppFieldLabel
//    Label di atas field input — dipakai di EditProfilPages & LoginPage
//
// Contoh penggunaan:
//   AppFieldLabel('Nama Lengkap')
//   AppFieldLabel('Email', color: AppColors.brownshade2)
// -----------------------------------------------------------------------------
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.label, {super.key, this.color = AppColors.textDark});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 17. AppSectionTitle
//    Judul bagian dengan link "Lihat Semua" — dipakai di HomeFragment
//
// Contoh penggunaan:
//   AppSectionTitle(title: 'Jadwal Hari Ini', onSeeAll: () => Get.toNamed(...))
//   AppSectionTitle(title: 'Statistik') // tanpa tombol lihat semua
// -----------------------------------------------------------------------------
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllLabel = 'Lihat Semua',
  });

  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              seeAllLabel,
              style: const TextStyle(
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

// -----------------------------------------------------------------------------
// 18. AppNavItem
//    Item navigasi bawah — dipakai di MainPage bottom nav bar
//
// Contoh penggunaan:
//   AppNavItem(icon: Icons.home_rounded, label: 'Beranda', isSelected: true, onTap: ...)
// -----------------------------------------------------------------------------
class AppNavItem extends StatelessWidget {
  const AppNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.brownshade,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.brownshade,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 19. AppDivider
//    Divider vertikal tipis — dipakai sebagai pemisah jam masuk & pulang
//
// Contoh penggunaan:
//   AppDivider.vertical(height: 40)
//   AppDivider.horizontal()
// -----------------------------------------------------------------------------
class AppDivider extends StatelessWidget {
  const AppDivider.vertical({
    super.key,
    this.height = 40,
    this.color = AppColors.brownshade3,
  }) : isVertical = true,
       width = 1;

  const AppDivider.horizontal({
    super.key,
    this.color = AppColors.divider,
  }) : isVertical = false,
       height = 1,
       width = double.infinity;

  final bool isVertical;
  final double height;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isVertical ? 1 : double.infinity,
      height: isVertical ? height : 1,
      color: color,
    );
  }
}

// -----------------------------------------------------------------------------
// 20. AppLoadingCenter
//    Loading indicator centered — dipakai di semua halaman saat fetch data
//
// Contoh penggunaan:
//   if (ctrl.isLoading.value) return AppLoadingCenter()
//   AppLoadingCenter(label: 'Memuat jadwal...')
// -----------------------------------------------------------------------------
class AppLoadingCenter extends StatelessWidget {
  const AppLoadingCenter({
    super.key,
    this.label,
    this.color = AppColors.primary,
  });

  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: color),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(
              label!,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 21. AppUserAvatar
//    Avatar lingkaran dengan ikon person — dipakai di header & profile
//
// Contoh penggunaan:
//   AppUserAvatar()
//   AppUserAvatar(size: 88, iconSize: 44)
// -----------------------------------------------------------------------------
class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({
    super.key,
    this.size = 44,
    this.iconSize = 24,
    this.showEditBadge = false,
    this.borderRadius,
  });

  final double size;
  final double iconSize;
  final bool showEditBadge;

  /// Jika null, menggunakan lingkaran penuh (BoxShape.circle)
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgField,
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        border: Border.all(color: AppColors.white, width: 3),
      ),
      child: Icon(
        Icons.person_outline_rounded,
        color: AppColors.primary,
        size: iconSize,
      ),
    );

    if (!showEditBadge) return container;

    return Stack(
      children: [
        container,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}