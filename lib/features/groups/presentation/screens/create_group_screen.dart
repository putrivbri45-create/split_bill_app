import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/group_bloc.dart';
import '../../domain/models/group_model.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'Makanan';
  String _iconName = 'restaurant';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makanan', 'icon': Icons.restaurant_rounded, 'id': 'restaurant'},
    {'name': 'Liburan', 'icon': Icons.flight_takeoff_rounded, 'id': 'flight'},
    {'name': 'Rumah/Kost', 'icon': Icons.home_rounded, 'id': 'home'},
    {'name': 'Acara', 'icon': Icons.celebration_rounded, 'id': 'event'},
    {'name': 'Belanja', 'icon': Icons.shopping_bag_outlined, 'id': 'shopping'},
  ];

  late List<GroupMemberModel> _members;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is Authenticated ? authState.user : null;

    _members = [
      GroupMemberModel(
        id: 'mem-user',
        groupId: '',
        userId: currentUser?.id ?? 'user-putri-01',
        role: 'admin',
        userName: currentUser?.fullName ?? 'Putri Buana',
        phoneNumber: currentUser?.phoneNumber ?? '0812-3456-7890',
      ),
      const GroupMemberModel(
        id: 'mem-ani',
        groupId: '',
        userId: 'user-ani-02',
        role: 'member',
        userName: 'Ani',
        phoneNumber: '0812-9988-7766',
      ),
      const GroupMemberModel(
        id: 'mem-budi',
        groupId: '',
        userId: 'user-budi-03',
        role: 'member',
        userName: 'Budi',
        phoneNumber: '0813-1122-3344',
      ),
      const GroupMemberModel(
        id: 'mem-citra',
        groupId: '',
        userId: 'user-citra-04',
        role: 'member',
        userName: 'Citra',
        phoneNumber: '0815-5566-7788',
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showAddManualMemberDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tambah Anggota Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Contoh: Dian',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp (Opsional)',
                  hintText: '0812-xxxx-xxxx',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _members.add(GroupMemberModel(
                      id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
                      groupId: '',
                      userId: 'user-${DateTime.now().millisecondsSinceEpoch}',
                      userName: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _createGroup() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan nama grup')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.id : 'user-putri-01';

    context.read<GroupBloc>().add(CreateGroupEvent(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      iconName: _iconName,
      createdBy: currentUserId,
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      members: _members,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Grup Baru',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buat grup untuk membagi tagihan dengan teman, keluarga, atau rekan.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon selector bubble
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainerLow : const Color(0xFFE8FAF3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryContainer.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _categories.firstWhere((c) => c['name'] == _selectedCategory)['icon'] as IconData,
                            size: 40,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih Ikon atau Foto Grup',
                      style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Group inputs card
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
                    Text(
                      'Nama Grup *',
                      style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Makan Malam Reuni',
                        suffixIcon: _nameController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.cancel_rounded, size: 18),
                                onPressed: () => setState(() => _nameController.clear()),
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deskripsi (Opsional)',
                      style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Tuliskan catatan atau tujuan grup ini...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kategori',
                      style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                    ),
                    const SizedBox(height: 10),
                    // Categories chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat['name'];
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategory = cat['name'] as String;
                            _iconName = cat['id'] as String;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryContainer
                                  : (isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : palette.cardBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  size: 16,
                                  color: isSelected ? Colors.white : palette.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat['name'] as String,
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
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Group Members Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Anggota Grup',
                    style: AppText.headlineSm.copyWith(fontWeight: FontWeight.w800, color: palette.onSurface),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.surfaceLow,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Anggota Terdaftar (${_members.length} orang)',
                      style: AppText.labelSm.copyWith(
                        color: palette.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Members List
              ...List.generate(_members.length, (idx) {
                final mem = _members[idx];
                final isCreator = idx == 0;
                final initial = mem.userName.isNotEmpty ? mem.userName.substring(0, 2).toUpperCase() : 'ME';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCreator ? AppColors.primaryContainer : palette.cardBorder,
                      width: isCreator ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCreator
                              ? AppColors.primary
                              : AppColors.secondaryContainer.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: isCreator ? Colors.white : AppColors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  mem.userName,
                                  style: AppText.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: palette.onSurface,
                                  ),
                                ),
                                if (isCreator) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Anda',
                                      style: AppText.labelSm.copyWith(
                                        fontSize: 10,
                                        color: AppColors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (mem.phoneNumber != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                mem.phoneNumber!,
                                style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isCreator)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'Pembuat',
                            style: AppText.labelSm.copyWith(
                              color: isDark ? AppColors.primaryFixed : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          onPressed: () {
                            setState(() => _members.removeAt(idx));
                          },
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Add member buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Simulated contacts
                        setState(() {
                          _members.add(const GroupMemberModel(
                            id: 'mem-dian',
                            groupId: '',
                            userId: 'user-dian-05',
                            userName: 'Dian',
                            phoneNumber: '0812-7788-9900',
                          ));
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dian ditambahkan dari Kontak')),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: const Text('Dari Kontak'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: BorderSide(color: palette.cardBorder),
                        foregroundColor: palette.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showAddManualMemberDialog,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Nama Manual'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: BorderSide(color: palette.cardBorder),
                        foregroundColor: palette.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Primary CTA
              CustomButton(
                text: 'Buat Grup',
                icon: Icons.group_add_rounded,
                onPressed: _createGroup,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
