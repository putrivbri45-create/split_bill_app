import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../../../shared/widgets/qris_modal.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Split Bill',
              style: AppText.headlineSm.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.primaryFixed : AppColors.primary,
              ),
            ),
            Text(
              '  /  Profil Saya',
              style: AppText.headlineSm.copyWith(
                fontWeight: FontWeight.w600,
                color: palette.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              final currentName = authState is Authenticated ? authState.user.fullName : 'putrivbri';
              QrisModal.show(
                context,
                recipientName: currentName,
                amount: 100000,
                note: 'QRIS Statis $currentName',
                onConfirmPayment: () {},
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Profile Header Card
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state is Authenticated ? state.user : null;
                  final fullName = user?.fullName ?? 'putrivbri';
                  final email = user?.email ?? 'putri@email.com';
                  final phone = user?.phoneNumber ?? '0812-3456-7890';
                  final avatarUrl = (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                      ? user.avatarUrl!
                      : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: palette.cardBorder),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryFixedDim,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        avatarUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.primaryFixedDim,
                                          child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, size: 11, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        fullName,
                                        style: AppText.headlineSm.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: palette.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF103B2E) : const Color(0xFFD1FAE5),
                                          borderRadius: BorderRadius.circular(AppRadius.pill),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.verified_user_rounded, size: 10, color: AppColors.primaryContainer),
                                            const SizedBox(width: 3),
                                            Text(
                                              'Terverifikasi',
                                              style: AppText.labelSm.copyWith(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$email • $phone',
                                    style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant, fontSize: 11),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: palette.surfaceLow,
                                        borderRadius: BorderRadius.circular(AppRadius.pill),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit_outlined, size: 12, color: palette.onSurface),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Edit Profil',
                                            style: AppText.labelSm.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: palette.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Stats 3 Cards
              BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  int totalGroups = 4;
                  if (state is GroupLoaded) {
                    totalGroups = state.groups.length;
                  }

                  return Row(
                    children: [
                      _buildStatCard('Total Grup', '$totalGroups', palette),
                      const SizedBox(width: 10),
                      _buildStatCard('Total Transaksi', '28', palette),
                      const SizedBox(width: 10),
                      _buildStatCard('Grup Aktif', '2', palette, hasGreenDot: true),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Menu Group 1
              _buildMenuGroup(
                palette,
                [
                  _buildMenuItem(
                    icon: Icons.badge_outlined,
                    iconBg: isDark ? const Color(0xFF1E2838) : const Color(0xFFEFF6FF),
                    iconFg: const Color(0xFF2563EB),
                    title: 'Edit Profil',
                    subtitle: 'Info kontak, avatar, dan identitas',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                  _buildMenuItem(
                    icon: Icons.groups_outlined,
                    iconBg: isDark ? const Color(0xFF132F28) : const Color(0xFFECFDF5),
                    iconFg: const Color(0xFF059669),
                    title: 'Grup Saya',
                    subtitle: 'Kelola daftar lingkaran split bill',
                    trailingBadge: '2 Aktif',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.groupsList),
                  ),
                  _buildMenuItem(
                    icon: Icons.pie_chart_outline_rounded,
                    iconBg: isDark ? const Color(0xFF281E38) : const Color(0xFFFAF5FF),
                    iconFg: const Color(0xFF9333EA),
                    title: 'Ringkasan Split Bill',
                    subtitle: 'Laporan pengeluaran dan riwayat bayar',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Menu Group 2
              _buildMenuGroup(
                palette,
                [
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    iconBg: isDark ? const Color(0xFF132F28) : const Color(0xFFECFDF5),
                    iconFg: const Color(0xFF059669),
                    title: 'Metode Pembayaran & QRIS',
                    subtitle: 'BCA, Mandiri, GoPay, dan QR statis',
                    hasGreenDot: true,
                    onTap: () {
                      final authState = context.read<AuthBloc>().state;
                      final currentName = authState is Authenticated ? authState.user.fullName : 'putrivbri';
                      QrisModal.show(
                        context,
                        recipientName: currentName,
                        amount: 50000,
                        note: 'QRIS Metode Pembayaran',
                        onConfirmPayment: () {},
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    iconBg: isDark ? const Color(0xFF2E2413) : const Color(0xFFFFFBEB),
                    iconFg: const Color(0xFFD97706),
                    title: 'Notifikasi',
                    subtitle: 'Tagihan baru dan pengingat bayar',
                    trailingCount: 3,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Menu Group 3
              _buildMenuGroup(
                palette,
                [
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    iconBg: isDark ? const Color(0xFF1E2838) : const Color(0xFFF1F5F9),
                    iconFg: const Color(0xFF475569),
                    title: 'Bantuan & FAQ',
                    subtitle: 'Panduan bagi tagihan & customer support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pusat Bantuan: Hubungi cs@splitbill.id')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout Button
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Keluar dari Akun?'),
                      content: const Text('Anda perlu masuk kembali untuk mengakses data split bill.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginRegister, (r) => false);
                          },
                          child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3B1A1A) : const Color(0xFFFFEDEC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: Color(0xFFBA1A1A), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Keluar dari Akun',
                        style: AppText.labelLarge.copyWith(
                          color: const Color(0xFFBA1A1A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 13, color: palette.outline),
                  const SizedBox(width: 4),
                  Text(
                    'Split Bill v2.4.0 • Aman & Terenkripsi',
                    style: AppText.bodySm.copyWith(
                      fontSize: 11,
                      color: palette.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, AppPalette palette, {bool hasGreenDot = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.cardBorder),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppText.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onSurface,
                  ),
                ),
                if (hasGreenDot) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppText.bodySm.copyWith(
                fontSize: 11,
                color: palette.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(AppPalette palette, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailingBadge,
    int? trailingCount,
    bool hasGreenDot = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconFg, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.bodySm.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingBadge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  trailingBadge,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0E7490)),
                ),
              ),
            if (trailingCount != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$trailingCount',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            if (hasGreenDot)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
