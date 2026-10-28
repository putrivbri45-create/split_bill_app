import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/expense_card.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../bloc/group_bloc.dart';
import '../../domain/models/group_model.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  int _selectedTab = 1; // 0: Anggota, 1: Pengeluaran

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadGroupExpensesEvent(widget.group.id));
  }

  Future<void> _confirmDeleteGroup(BuildContext context) async {
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
          'Apakah Anda yakin ingin menghapus grup "${widget.group.name}"? Semua data pengeluaran dan anggota dalam grup ini akan dihapus permanen.',
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

    if (confirmed == true && mounted) {
      context.read<GroupBloc>().add(DeleteGroupEvent(widget.group.id));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grup "${widget.group.name}" berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final group = widget.group;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF6DF5E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_rounded, color: Color(0xFF006F64), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: AppText.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.onSurface,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${group.members.length} anggota',
                    style: AppText.bodySm.copyWith(
                      color: palette.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: 'Yuk cek rincian split bill "${group.name}" di aplikasi Split Bill!\nTotal Pengeluaran: ${CurrencyFormatter.format(group.totalSpending)}',
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDeleteGroup(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hapus Grup',
                      style: AppText.labelLarge.copyWith(
                        color: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Summary Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: palette.cardBorder),
                              boxShadow: AppShadows.card,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.payments_outlined, size: 16, color: AppColors.primaryContainer),
                                    const SizedBox(width: 6),
                                    Text('Kamu bayar', style: AppText.bodySm.copyWith(fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  CurrencyFormatter.format(50000),
                                  style: AppText.headlineSm.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF006C49),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Telah kamu talangi', style: AppText.bodySm.copyWith(fontSize: 11, color: palette.outline)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: palette.cardBorder),
                              boxShadow: AppShadows.card,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.primaryContainer),
                                    const SizedBox(width: 6),
                                    Text('Kamu terima', style: AppText.bodySm.copyWith(fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  CurrencyFormatter.format(25000),
                                  style: AppText.headlineSm.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('Piutang belum lunas', style: AppText.bodySm.copyWith(fontSize: 10, color: palette.outline)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Anggota Avatar Circles Row
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Anggota Grup (${group.members.length})',
                                style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: palette.onSurface),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: Text(
                                  'Kelola >',
                                  style: AppText.labelSm.copyWith(
                                    color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: group.members.map((m) {
                              final initial = m.userName.isNotEmpty ? m.userName.substring(0, 2).toUpperCase() : 'M';
                              final isHost = m.role == 'admin';
                              final isUser = m.userName.contains('Anda') || m.userName.contains('Putri') || m.userName.contains('Dimas');

                              return Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isUser
                                              ? const Color(0xFFD1FAE5)
                                              : (isHost ? const Color(0xFFCFFAFE) : palette.surfaceLow),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isUser ? AppColors.primaryContainer : palette.cardBorder,
                                            width: isUser ? 2 : 1,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initial,
                                          style: TextStyle(
                                            color: isUser ? AppColors.primary : palette.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      if (isHost)
                                        Positioned(
                                          bottom: -4,
                                          right: -4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Host', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                          ),
                                        )
                                      else if (isUser)
                                        Positioned(
                                          bottom: -4,
                                          right: -4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryContainer,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Kamu', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    m.userName.split(' ').first,
                                    style: AppText.labelSm.copyWith(
                                      color: palette.onSurface,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Segmented Tabs: Anggota | Pengeluaran
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Anggota (${group.members.length})',
                                  style: AppText.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 0 ? Colors.white : palette.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Pengeluaran (${group.expenseCount > 0 ? group.expenseCount : 4})',
                                  style: AppText.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 1 ? Colors.white : palette.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_selectedTab == 1) ...[
                      // Total Pengeluaran Banner
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006C49),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.badge,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Pengeluaran Grup',
                                  style: AppText.bodySm.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.format(group.totalSpending > 0 ? group.totalSpending : 400000.0),
                                  style: AppText.headlineLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_outlined, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${group.expenseCount > 0 ? group.expenseCount : 4} Transaksi',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Expenses List
                      BlocBuilder<ExpenseBloc, ExpenseState>(
                        builder: (context, state) {
                          if (state is ExpenseLoading) {
                            return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                          }

                          if (state is ExpenseLoaded) {
                            final list = state.expenses;
                            return Column(
                              children: list.map((e) => ExpenseCard(expense: e)).toList(),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ] else ...[
                      // Members Tab Detail
                      ...group.members.map((m) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: palette.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.cardBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.secondaryContainer.withOpacity(0.6),
                                child: Text(
                                  m.userName.isNotEmpty ? m.userName[0].toUpperCase() : 'M',
                                  style: const TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.userName, style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, color: palette.onSurface)),
                                    Text(m.phoneNumber ?? 'Anggota grup', style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Text(
                                m.netBalance >= 0 ? '+${CurrencyFormatter.format(m.netBalance)}' : CurrencyFormatter.format(m.netBalance),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: m.netBalance >= 0 ? const Color(0xFF10B981) : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: palette.card,
                border: Border(top: BorderSide(color: palette.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.splitSummary,
                          arguments: group,
                        );
                      },
                      icon: const Icon(Icons.account_balance_outlined, size: 18),
                      label: const Text('Selesaikan Tagihan (Settle Up)'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: palette.cardBorder),
                        foregroundColor: isDark ? AppColors.primaryFixed : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addExpense,
                        arguments: group,
                      );
                    },
                    backgroundColor: AppColors.primaryContainer,
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
