import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _septemberTransactions = [
    {
      'title': 'Makan Malam Reuni',
      'subtitle': 'Grup Makan Malam Reuni • Hari ini, 19:30',
      'badge': 'Kamu bayar Rp50.000',
      'amount': -50000.0,
      'isExpense': true,
      'category': 'makanan',
      'icon': Icons.restaurant_rounded,
    },
    {
      'title': 'Liburan Jogja',
      'subtitle': 'Tiket Kereta PP • Kemarin, 14:15',
      'badge': 'Pelunasan dari Budi',
      'amount': 75000.0,
      'isExpense': false,
      'category': 'liburan',
      'icon': Icons.flight_takeoff_rounded,
    },
    {
      'title': 'Parkir & Tips',
      'subtitle': 'Grup Makan Malam Reuni • 24 Sep, 21:00',
      'badge': 'Bagian kamu: Rp7.500 (1/4)',
      'amount': -7500.0,
      'isExpense': true,
      'category': 'transport',
      'icon': Icons.local_parking_rounded,
    },
    {
      'title': 'Bensin & Tol',
      'subtitle': 'Grup Liburan Jogja • 22 Sep, 08:30',
      'badge': 'Dibayarkan oleh Dian',
      'amount': -35000.0,
      'isExpense': true,
      'category': 'transport',
      'icon': Icons.ev_station_rounded,
    },
  ];

  final List<Map<String, dynamic>> _augustTransactions = [
    {
      'title': 'Kost Bulanan & Wifi',
      'subtitle': 'Grup Kontrakan Ceria • 15 Agu, 10:00',
      'badge': 'Lunas dari 3 anggota',
      'amount': 150000.0,
      'isExpense': false,
      'category': 'rumah',
      'icon': Icons.home_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () {},
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 12),

              // Filter Chips
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = 'Semua'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedFilter == 'Semua' ? AppColors.primaryContainer : palette.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Semua',
                            style: AppText.labelSm.copyWith(
                              color: _selectedFilter == 'Semua' ? Colors.white : palette.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedFilter == 'Semua') ...[
                            const SizedBox(width: 4),
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
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
                              Icon(Icons.north_east_rounded, size: 14, color: AppColors.error),
                              const SizedBox(width: 4),
                              Text('Total Pengeluaran', style: AppText.bodySm.copyWith(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '-Rp92.500',
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
                            '+Rp225.000',
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

              // September 2026 Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'September 2026',
                    style: AppText.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.surfaceLow,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '4 transaksi',
                          style: AppText.labelSm.copyWith(fontSize: 10, color: palette.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Net +Rp22.500',
                        style: AppText.labelSm.copyWith(
                          color: palette.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // September items
              ..._septemberTransactions.map((tx) => _buildTransactionCard(tx, palette, isDark)),

              const SizedBox(height: 20),

              // August 2026 Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agustus 2026',
                    style: AppText.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.surfaceLow,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '1 transaksi',
                          style: AppText.labelSm.copyWith(fontSize: 10, color: palette.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Net +Rp150.000',
                        style: AppText.labelSm.copyWith(
                          color: palette.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // August items
              ..._augustTransactions.map((tx) => _buildTransactionCard(tx, palette, isDark)),

              const SizedBox(height: 30),
            ],
          ),
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
