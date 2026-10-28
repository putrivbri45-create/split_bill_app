import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../settlements/data/settlement_repository.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final expenseRepo = RepositoryProvider.of<ExpenseRepository>(context);
      final settlementRepo = RepositoryProvider.of<SettlementRepository>(context);

      final expenses = await expenseRepo.getAllExpenses();
      final settlements = await settlementRepo.getAllSettlements();

      final List<Map<String, dynamic>> list = [];

      for (final e in expenses) {
        IconData icon = Icons.receipt_rounded;
        final cat = e.category.toLowerCase();
        if (cat.contains('makan')) {
          icon = Icons.restaurant_rounded;
        } else if (cat.contains('trans') || cat.contains('bensin') || cat.contains('tol') || cat.contains('kereta') || cat.contains('parkir')) {
          icon = Icons.directions_car_rounded;
        } else if (cat.contains('libur') || cat.contains('tiket') || cat.contains('wisata')) {
          icon = Icons.flight_takeoff_rounded;
        } else if (cat.contains('kost') || cat.contains('wifi') || cat.contains('rumah')) {
          icon = Icons.home_rounded;
        }

        final isPayerPutri = e.payerId == 'user-putri-01' || e.payerName.toLowerCase().contains('putri');
        final badge = isPayerPutri
            ? 'Kamu bayar ${CurrencyFormatter.format(e.totalAmount)}'
            : 'Dibayar oleh ${e.payerName}';

        list.add({
          'id': e.id,
          'title': e.title,
          'subtitle': '${e.category} • ${_formatDateTime(e.expenseDate)}',
          'badge': badge,
          'amount': -e.totalAmount,
          'isExpense': true,
          'category': e.category,
          'icon': icon,
          'date': e.expenseDate,
        });
      }

      for (final s in settlements) {
        list.add({
          'id': s.id,
          'title': 'Pelunasan dari ${s.debtorName}',
          'subtitle': 'Kepada ${s.creditorName} • ${_formatDateTime(s.settledAt)}',
          'badge': s.status == 'COMPLETED' ? 'Lunas (${s.method ?? "Transfer"})' : 'Menunggu Pelunasan',
          'amount': s.amount,
          'isExpense': false,
          'category': 'pelunasan',
          'icon': Icons.payments_rounded,
          'date': s.settledAt,
        });
      }

      list.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      if (mounted) {
        setState(() {
          _transactions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = dt.hour.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $hourStr:$minuteStr';
  }

  String _formatMonthYear(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    final query = _searchController.text.trim().toLowerCase();
    return _transactions.where((tx) {
      if (query.isNotEmpty) {
        final title = (tx['title'] as String).toLowerCase();
        final subtitle = (tx['subtitle'] as String).toLowerCase();
        if (!title.contains(query) && !subtitle.contains(query)) {
          return false;
        }
      }

      if (_selectedFilter == 'Pengeluaran' && !tx['isExpense']) {
        return false;
      }
      if (_selectedFilter == 'Pelunasan' && tx['isExpense']) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    final filtered = _getFilteredTransactions();

    double totalExpense = 0.0;
    double totalIncome = 0.0;
    for (final tx in _transactions) {
      final amount = tx['amount'] as double;
      if (tx['isExpense'] == true) {
        totalExpense += amount.abs();
      } else {
        totalIncome += amount;
      }
    }

    // Group filtered items by Month & Year
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final tx in filtered) {
      final key = _formatMonthYear(tx['date'] as DateTime);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Perbarui Data',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi atau nama grup...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', palette),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pengeluaran', palette),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pelunasan', palette),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Summary Cards Row
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
                                const Icon(Icons.north_east_rounded, size: 14, color: AppColors.error),
                                const SizedBox(width: 4),
                                Text('Total Pengeluaran', style: AppText.bodySm.copyWith(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '-${CurrencyFormatter.format(totalExpense)}',
                              style: AppText.headlineSm.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFC53030),
                              ),
                            ),
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
                                const Icon(Icons.check_rounded, size: 14, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text('Diterima / Lunas', style: AppText.bodySm.copyWith(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '+${CurrencyFormatter.format(totalIncome)}',
                              style: AppText.headlineSm.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (_isLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ] else if (filtered.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: palette.outline),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada transaksi',
                          style: AppText.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: palette.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Catat pengeluaran baru untuk melihat riwayat patungan.',
                          style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Dynamic Month Sections
                  for (final entry in grouped.entries) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: AppText.headlineSm.copyWith(
                            fontWeight: FontWeight.w800,
                            color: palette.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: palette.surfaceLow,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${entry.value.length} transaksi',
                            style: AppText.labelSm.copyWith(fontSize: 10, color: palette.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...entry.value.map((tx) => _buildTransactionCard(tx, palette, isDark)),
                    const SizedBox(height: 20),
                  ],
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AppPalette palette) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : palette.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppText.labelSm.copyWith(
                color: isSelected ? Colors.white : palette.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx, AppPalette palette, bool isDark) {
    final isExpense = tx['isExpense'] as bool;
    final amount = tx['amount'] as double;
    final formattedAmount = amount > 0
        ? '+${CurrencyFormatter.format(amount)}'
        : '-${CurrencyFormatter.format(-amount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isExpense ? const Color(0xFFE53E3E) : const Color(0xFF10B981),
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isExpense
                      ? (isDark ? const Color(0xFF381F1A) : const Color(0xFFFFEDD5))
                      : (isDark ? const Color(0xFF0F3024) : const Color(0xFFCFFAFE)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  tx['icon'] as IconData,
                  color: isExpense ? AppColors.foodAccent : AppColors.travelAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] as String,
                      style: AppText.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tx['subtitle'] as String,
                      style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isExpense
                            ? (isDark ? const Color(0xFF122C23) : const Color(0xFFE6FFFA))
                            : (isDark ? const Color(0xFF122C23) : const Color(0xFFE6FFFA)),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        tx['badge'] as String,
                        style: AppText.labelSm.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF006C49),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedAmount,
                style: AppText.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isExpense
                      ? (isDark ? const Color(0xFFFFB4AB) : const Color(0xFFC53030))
                      : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
