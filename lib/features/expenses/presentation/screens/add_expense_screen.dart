import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/algorithm/split_calculator.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/expense_bloc.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../../groups/domain/models/group_model.dart';
import '../../domain/models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final GroupModel group;

  const AddExpenseScreen({super.key, required this.group});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController(text: '200000');
  final TextEditingController _titleController = TextEditingController(text: 'Makan di Restoran');
  final TextEditingController _noteController = TextEditingController(text: 'Makan malam di restoran Seafood.');

  double _totalAmount = 200000.0;
  String _selectedCategory = 'Makanan & Minuman';
  String? _payerId;
  String _payerName = 'Ani';
  final SplitMethod _splitMethod = SplitMethod.equal;

  late List<String> _selectedMemberIds;
  final Map<String, double> _exactAmounts = {};
  final Map<String, double> _percentages = {};
  final List<SplitItem> _items = [];

  final List<String> _categories = [
    'Makanan & Minuman',
    'Transport',
    'Hiburan',
    'Belanja',
    'Akomodasi',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMemberIds = widget.group.members.map((m) => m.userId).toList();
    if (widget.group.members.isNotEmpty) {
      _payerId = widget.group.members.first.userId;
      _payerName = widget.group.members.first.userName;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addAmount(double add) {
    setState(() {
      _totalAmount += add;
      _amountController.text = _totalAmount.round().toString();
    });
  }

  void _scanReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memindai struk... Terdeteksi total: Rp200.000 (Restoran Seafood)'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      _totalAmount = 200000;
      _amountController.text = '200000';
      _titleController.text = 'Makan di Restoran Seafood';
    });
  }

  void _saveExpense() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan nama pengeluaran')),
      );
      return;
    }

    if (_totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 orang yang ikut split bill')),
      );
      return;
    }

    final splitResult = SplitCalculator.calculate(
      method: _splitMethod,
      participantIds: _selectedMemberIds,
      subtotal: _totalAmount,
      exactAmounts: _exactAmounts,
      percentages: _percentages,
      items: _items,
    );

    if (!splitResult.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(splitResult.error ?? 'Perhitungan pembagian belum pas')),
      );
      return;
    }

    final splits = _selectedMemberIds.map((userId) {
      final member = widget.group.members.firstWhere(
        (m) => m.userId == userId,
        orElse: () => GroupMemberModel(id: '', groupId: widget.group.id, userId: userId, userName: 'Member'),
      );
      return ExpenseSplitModel(
        id: '',
        expenseId: '',
        userId: userId,
        userName: member.userName,
        amountOwed: splitResult.shares[userId] ?? 0.0,
      );
    }).toList();

    final expense = ExpenseModel(
      id: '',
      groupId: widget.group.id,
      payerId: _payerId,
      payerName: _payerName,
      title: _titleController.text.trim(),
      totalAmount: _totalAmount,
      splitType: _splitMethod.code,
      category: _selectedCategory,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      expenseDate: DateTime.now(),
      createdAt: DateTime.now(),
      splits: splits,
    );

    context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    context.read<GroupBloc>().add(LoadGroupsEvent());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    final perPerson = _selectedMemberIds.isNotEmpty ? _totalAmount / _selectedMemberIds.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Pengeluaran',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _scanReceipt,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
            label: const Text('Scan Struk'),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.primaryFixed : AppColors.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nominal Total Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: palette.cardBorder),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nominal Total',
                                style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: palette.surfaceLow,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.payments_outlined, size: 12, color: AppColors.primaryContainer),
                                    const SizedBox(width: 4),
                                    Text('IDR', style: AppText.labelSm.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Currency Input
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Rp ',
                                style: AppText.headlineLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: palette.onSurface,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: AppText.headlineXl.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: palette.onSurface,
                                    fontSize: 32,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _totalAmount = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Quick increment pills
                          Row(
                            children: [
                              _buildQuickChip('+10k', () => _addAmount(10000)),
                              const SizedBox(width: 8),
                              _buildQuickChip('+50k', () => _addAmount(50000)),
                              const SizedBox(width: 8),
                              _buildQuickChip('+100k', () => _addAmount(100000)),
                              const SizedBox(width: 8),
                              _buildQuickChip('Pas', () {
                                setState(() {
                                  _totalAmount = (_totalAmount / 1000).round() * 1000.0;
                                  _amountController.text = _totalAmount.round().toString();
                                });
                              }, isAccent: true),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Nama Pengeluaran
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Pengeluaran',
                            style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: Makan di Restoran',
                              prefixIcon: Icon(Icons.restaurant_rounded, color: AppColors.primaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Kategori Chips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori',
                            style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories.map((cat) {
                                final isSelected = _selectedCategory == cat;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedCategory = cat),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryContainer : palette.surfaceLow,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.category_rounded,
                                          size: 14,
                                          color: isSelected ? Colors.white : palette.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          cat,
                                          style: AppText.labelSm.copyWith(
                                            color: isSelected ? Colors.white : palette.onSurfaceVariant,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Dibayar oleh (Payer Dropdown)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dibayar oleh',
                            style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: palette.surfaceLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: palette.cardBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _payerId,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                items: widget.group.members.map((m) {
                                  return DropdownMenuItem<String>(
                                    value: m.userId,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: AppColors.primaryContainer,
                                          child: Text(
                                            m.userName.isNotEmpty ? m.userName[0].toUpperCase() : 'M',
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(m.userName, style: AppText.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                              Text(
                                                'Membayar lunas ${CurrencyFormatter.format(_totalAmount)}',
                                                style: AppText.bodySm.copyWith(fontSize: 10, color: palette.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    final found = widget.group.members.firstWhere((m) => m.userId == val);
                                    setState(() {
                                      _payerId = val;
                                      _payerName = found.userName;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Ditanggung oleh (Participant List & Split Method)
                    Container(
                      padding: const EdgeInsets.all(18),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ditanggung oleh',
                                    style: AppText.headlineSm.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: palette.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Pilih siapa saja yang ikut split bill',
                                    style: AppText.bodySm.copyWith(fontSize: 11, color: palette.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedMemberIds.length == widget.group.members.length) {
                                      _selectedMemberIds.clear();
                                    } else {
                                      _selectedMemberIds = widget.group.members.map((m) => m.userId).toList();
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6DF5E1).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF006F64)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Pilih semua (${widget.group.members.length})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006F64)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Participants list
                          ...widget.group.members.map((m) {
                            final isChecked = _selectedMemberIds.contains(m.userId);
                            final initial = m.userName.isNotEmpty ? m.userName[0].toUpperCase() : 'M';
                            final isPayer = m.userId == _payerId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isChecked ? (isDark ? const Color(0xFF132B25) : const Color(0xFFF0FDF4)) : palette.surfaceLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isChecked ? AppColors.primaryContainer.withOpacity(0.4) : palette.cardBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          _selectedMemberIds.add(m.userId);
                                        } else {
                                          _selectedMemberIds.remove(m.userId);
                                        }
                                      });
                                    },
                                  ),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isPayer ? AppColors.primaryContainer : AppColors.secondaryContainer.withOpacity(0.5),
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: isPayer ? Colors.white : AppColors.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.userName,
                                          style: AppText.titleMedium.copyWith(fontWeight: FontWeight.bold, color: palette.onSurface),
                                        ),
                                        Text(
                                          isPayer ? 'Pembayar Utama' : 'Anggota',
                                          style: AppText.bodySm.copyWith(fontSize: 10, color: palette.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isChecked ? CurrencyFormatter.format(perPerson) : 'Rp0',
                                        style: AppText.labelLarge.copyWith(fontWeight: FontWeight.w800, color: palette.onSurface),
                                      ),
                                      Text('/ orang', style: AppText.bodySm.copyWith(fontSize: 10, color: palette.outline)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 12),

                          // Estimation banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF10283A) : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calculate_outlined, size: 18, color: Color(0xFF0284C7)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Estimasi: ${_selectedMemberIds.length} orang membagi rata masing-masing ${CurrencyFormatter.format(perPerson)}.',
                                    style: AppText.bodySm.copyWith(
                                      color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Catatan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Catatan',
                                style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                              ),
                              Text('Opsional', style: AppText.bodySm.copyWith(color: palette.outline, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              hintText: 'Tuliskan catatan...',
                              prefixIcon: Icon(Icons.notes_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),


                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: CustomButton(
                text: 'Simpan Pengeluaran',
                icon: Icons.check_circle_rounded,
                onPressed: _saveExpense,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String text, VoidCallback onTap, {bool isAccent = false}) {
    final palette = context.palette;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isAccent ? const Color(0xFF6DF5E1) : palette.surfaceLow,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAccent ? const Color(0xFF006F64) : palette.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
