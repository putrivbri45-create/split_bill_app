import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/settlement_card.dart';
import '../../../../shared/widgets/qris_modal.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/settlement_bloc.dart';
import '../../../groups/domain/models/group_model.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../domain/models/settlement_model.dart';

class SplitSummaryScreen extends StatefulWidget {
  final GroupModel group;

  const SplitSummaryScreen({super.key, required this.group});

  @override
  State<SplitSummaryScreen> createState() => _SplitSummaryScreenState();
}

class _SplitSummaryScreenState extends State<SplitSummaryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettlementBloc>().add(LoadSettlementsEvent(widget.group.id));
  }

  void _onShareDetails([List<SettlementModel>? settlements]) {
    final list = settlements ??
        (context.read<SettlementBloc>().state is SettlementLoaded
            ? (context.read<SettlementBloc>().state as SettlementLoaded).settlements
            : <SettlementModel>[]);

    final buffer = StringBuffer();
    buffer.writeln('*Rincian Pembagian Split Bill: ${widget.group.name}*');
    buffer.writeln('Total Pengeluaran: ${CurrencyFormatter.format(widget.group.totalSpending > 0 ? widget.group.totalSpending : 0)}');
    buffer.writeln('');
    buffer.writeln('*Yang Harus Bayar / Menerima:*');

    if (list.isEmpty) {
      buffer.writeln('Semua tagihan sudah lunas atau belum ada tagihan.');
    } else {
      for (int i = 0; i < list.length; i++) {
        final stl = list[i];
        final statusLabel = stl.status.toUpperCase() == 'COMPLETED' ? 'Lunas ✓' : 'Belum lunas';
        buffer.writeln('${i + 1}. ${stl.debtorName} -> ${stl.creditorName}: ${CurrencyFormatter.format(stl.amount)} ($statusLabel)');
      }
    }

    buffer.writeln('');
    buffer.writeln('Biar adil, nggak ribet! Bayar langsung via QRIS di aplikasi Split Bill.');

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _openQris(SettlementModel settlement) {
    QrisModal.show(
      context,
      recipientName: settlement.creditorName,
      amount: settlement.amount,
      note: 'Split Bill ${widget.group.name}',
      onConfirmPayment: () {
        context.read<SettlementBloc>().add(
          RecordSettlementEvent(
            settlement.copyWith(
              status: 'COMPLETED',
              method: 'QRIS Instan',
              settledAt: DateTime.now(),
            ),
          ),
        );
        context.read<GroupBloc>().add(LoadGroupsEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran ${CurrencyFormatter.format(settlement.amount)} berhasil dikonfirmasi!'),
            backgroundColor: AppColors.primaryContainer,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final groupState = context.watch<GroupBloc>().state;
    final group = (groupState is GroupLoaded)
        ? groupState.groups.firstWhere(
            (g) => g.id == widget.group.id,
            orElse: () => widget.group,
          )
        : widget.group;
    final totalSpending = group.totalSpending;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hasil Pembagian',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _onShareDetails,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Optimal Banner
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006C49), Color(0xFF004D34)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.badge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pengeluaran',
                          style: AppText.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Algoritma Optimal',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(totalSpending),
                      style: AppText.headlineXl.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.2), height: 1),
                    const SizedBox(height: 12),
                    BlocBuilder<SettlementBloc, SettlementState>(
                      builder: (context, state) {
                        final count = state is SettlementLoaded ? state.settlements.length : 0;
                        final countText = count > 0
                            ? 'Disederhanakan menjadi $count transaksi pembayaran termudah'
                            : 'Semua saldo seimbang atau tidak ada tagihan tertunda';
                        return Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF6FFBBE), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                countText,
                                style: AppText.bodySm.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Header
              BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) {
                  final count = state is SettlementLoaded ? state.settlements.length : 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yang Harus Bayar / Menerima',
                        style: AppText.headlineSm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: palette.onSurface,
                          fontSize: 17,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B2A32) : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '$count Transaksi',
                          style: AppText.labelSm.copyWith(
                            color: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),

              // Settlements List
              BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) {
                  if (state is SettlementLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                  }

                  if (state is SettlementLoaded) {
                    final list = state.settlements;
                    if (list.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: palette.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: palette.cardBorder),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.primaryContainer),
                              const SizedBox(height: 12),
                              Text(
                                'Semua Impas!',
                                style: AppText.headlineSm.copyWith(fontWeight: FontWeight.w700, color: palette.onSurface),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tidak ada tagihan atau hutang yang belum terselesaikan di grup ini.',
                                textAlign: TextAlign.center,
                                style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: list.map((stl) {
                        return SettlementCard(
                          settlement: stl,
                          onRemind: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text: 'Hai ${stl.debtorName}, jangan lupa selesaikan tagihan split bill "${widget.group.name}" sebesar ${CurrencyFormatter.format(stl.amount)} ke ${stl.creditorName} ya! Terima kasih 🙏',
                              ),
                            );
                          },
                          onPay: () => _openQris(stl),
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 12),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132338) : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFD6E2FF),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF006C49),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Perhitungan ini meminimalkan transfer antar anggota agar penyelesaian lebih cepat dan tanpa biaya admin tambahan.',
                        style: AppText.bodySm.copyWith(
                          color: palette.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CTA buttons
              CustomButton(
                text: 'Lihat Riwayat Pembayaran',
                icon: Icons.receipt_long_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.history);
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Bagikan Rincian (PDF / WA)',
                icon: Icons.share_rounded,
                variant: ButtonVariant.secondary,
                onPressed: _onShareDetails,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
