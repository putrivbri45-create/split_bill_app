import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../shared/widgets/balance_card.dart';
import '../../../../shared/widgets/group_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../groups/domain/models/group_model.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../../notifications/data/notification_repository.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(LoadGroupsEvent());
  }

  Future<void> _confirmDeleteGroup(GroupModel group) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4A1818) : AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Grup?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus grup "${group.name}"? Semua data pengeluaran dan anggota dalam grup ini akan dihapus permanen.',
          style: AppText.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: AppText.labelLarge.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    context.read<GroupBloc>().add(DeleteGroupEvent(group.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grup "${group.name}" berhasil dihapus'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<GroupBloc>().add(LoadGroupsEvent());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final userName = authState is Authenticated
                        ? authState.user.fullName
                        : 'putrivbri';
                    final userAvatar = (authState is Authenticated &&
                            authState.user.avatarUrl != null &&
                            authState.user.avatarUrl!.isNotEmpty)
                        ? authState.user.avatarUrl!
                        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';
                    return Row(
                      children: [
                        // Avatar with online status
                        Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryFixedDim,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(userAvatar),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $userName 👋',
                                style: AppText.headlineSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: palette.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Yuk cek split bill-mu hari ini.',
                                style: AppText.bodySm.copyWith(
                                  color: palette.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification Bell
                        Builder(
                          builder: (context) {
                            final unreadCount = NotificationRepositoryImpl()
                                .getUnreadCount();
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.notifications,
                                );
                                setState(() {});
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: palette.card,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: palette.cardBorder),
                                  boxShadow: AppShadows.card,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      color: palette.onSurface,
                                      size: 22,
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFDC2626),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Balance Cards Row
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    double debt = 125000.0;
                    double credit = 75000.0;
                    int debtCount = 2;
                    int creditCount = 1;

                    if (state is GroupLoaded) {
                      debt = state.totalDebt > 0 ? state.totalDebt : debt;
                      credit = state.totalCredit > 0
                          ? state.totalCredit
                          : credit;
                      debtCount = state.debtCount > 0
                          ? state.debtCount
                          : debtCount;
                      creditCount = state.creditCount > 0
                          ? state.creditCount
                          : creditCount;
                    }

                    return Row(
                      children: [
                        BalanceCard(
                          type: BalanceCardType.debt,
                          amount: debt,
                          count: debtCount,
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(
                                2,
                              ); // Navigate to history tab
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        BalanceCard(
                          type: BalanceCardType.credit,
                          amount: credit,
                          count: creditCount,
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(
                                2,
                              ); // Navigate to history tab
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Quick Action Buttons
                CustomButton(
                  text: '+ Buat Grup Baru',
                  icon: Icons.group_add_rounded,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.createGroup),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Catat Pengeluaran Cepat',
                  icon: Icons.bolt_rounded,
                  variant: ButtonVariant.secondary,
                  onPressed: () async {
                    final groupState = context.read<GroupBloc>().state;
                    if (groupState is GroupLoaded &&
                        groupState.groups.isNotEmpty) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.addExpense,
                        arguments: groupState.groups.first,
                      );
                      if (context.mounted) {
                        context.read<GroupBloc>().add(LoadGroupsEvent());
                      }
                    } else {
                      await Navigator.pushNamed(context, AppRoutes.createGroup);
                      if (context.mounted) {
                        context.read<GroupBloc>().add(LoadGroupsEvent());
                      }
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Active Groups Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grup Aktif',
                      style: AppText.headlineSm.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1); // Go to Groups tab
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            'Lihat Semua',
                            style: AppText.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.primaryFixed
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.primaryFixed
                                : AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Active Groups List
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    if (state is GroupLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is GroupLoaded) {
                      if (state.groups.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: palette.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: palette.cardBorder, width: 1.2),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.group_off_outlined, size: 48, color: palette.outline),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada grup aktif',
                                  style: AppText.headlineSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: palette.onSurface,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Buat grup baru untuk mulai patungan bersama teman',
                                  style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: state.groups.map((g) {
                          return GroupCard(
                            group: g,
                            onTap: () async {
                              context.read<GroupBloc>().add(
                                SelectGroupEvent(g.id),
                              );
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.groupDetail,
                                arguments: g,
                              );
                              if (context.mounted) {
                                context.read<GroupBloc>().add(LoadGroupsEvent());
                              }
                            },
                            onDelete: () => _confirmDeleteGroup(g),
                          );
                        }).toList(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 8),

                // Informational Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132338)
                        : const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFD6E2FF),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sync_lock_rounded,
                          color: AppColors.onSecondaryContainer,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Perhitungan adil otomatis tanpa bunga dan tanpa biaya admin.',
                          style: AppText.bodySm.copyWith(
                            color: palette.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Split Bill menggunakan algoritma Greedy Debt Simplification untuk meminimalkan transaksi',
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Pelajari',
                          style: AppText.labelSm.copyWith(
                            color: isDark
                                ? AppColors.primaryFixed
                                : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
