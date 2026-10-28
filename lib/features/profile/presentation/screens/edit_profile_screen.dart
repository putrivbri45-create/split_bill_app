import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _bankAccountController;

  String _selectedAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';
  String _selectedBank = 'BCA';
  bool _shareContactWithGroup = true;
  bool _whatsappNotification = true;
  bool _isSaving = false;

  final List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
  ];

  final List<String> _bankOptions = [
    'BCA',
    'Mandiri',
    'BRI',
    'BNI',
    'GoPay',
    'OVO',
    'DANA',
    'ShopeePay',
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    _nameController = TextEditingController(text: user?.fullName ?? 'putrivbri');
    _emailController = TextEditingController(text: user?.email ?? 'putri@email.com');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '081234567890');
    _bioController = TextEditingController(text: 'Suka kulineran & ngopi bareng ✨');
    _bankAccountController = TextEditingController(text: '123-456-7890 (a.n. putrivbri)');

    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      _selectedAvatar = user.avatarUrl!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  void _showAvatarPickerSheet(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: palette.cardBorder),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pilih Foto Profil Avatar',
                style: AppText.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih salah satu avatar persona yang sesuai dengan kepribadian Anda.',
                style: AppText.bodySm.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _avatarPresets.map((url) {
                  final isSelected = _selectedAvatar == url;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = url);
                      Navigator.pop(ctx);
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.primaryFixed : AppColors.primary)
                                  : palette.cardBorder,
                              width: isSelected ? 3 : 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.primaryFixedDim,
                                child: const Icon(Icons.person, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.link_rounded),
                      label: const Text('Masukkan URL Foto'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCustomUrlDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomUrlDialog(BuildContext context) {
    final textController = TextEditingController(text: _selectedAvatar);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('URL Foto Profil'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'https://...',
              labelText: 'Tautan Gambar',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final url = textController.text.trim();
                if (url.isNotEmpty) {
                  setState(() => _selectedAvatar = url);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Gunakan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    context.read<AuthBloc>().add(
          AuthUpdateProfileRequested(
            fullName: fullName,
            phone: phone,
            email: email,
            avatarUrl: _selectedAvatar,
          ),
        );

    // Brief simulated delay for smooth feel
    await Future.delayed(const Duration(milliseconds: 350));

    if (mounted) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Profil berhasil diperbarui ✨'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profil',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text(
              'Simpan',
              style: AppText.labelLarge.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Edit Section Card
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryFixedDim,
                              border: Border.all(
                                color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                _selectedAvatar,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.primaryFixedDim,
                                  child: const Icon(Icons.person, size: 48, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showAvatarPickerSheet(context),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: palette.card,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () => _showAvatarPickerSheet(context),
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Ganti Avatar'),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppColors.primaryFixed : AppColors.primary,
                          textStyle: AppText.labelMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Data Diri
                _buildSectionHeader('INFORMASI PRIBADI', palette),
                const SizedBox(height: 10),

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
                      // Full Name
                      _buildFieldLabel('Nama Lengkap', palette),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama lengkap',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          if (v.trim().length < 2) {
                            return 'Nama terlalu pendek';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildFieldLabel('Alamat Email', palette),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'contoh@email.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildFieldLabel('Nomor Handphone / WhatsApp', palette),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '081234567890',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor HP tidak boleh kosong';
                          }
                          if (v.trim().length < 9) {
                            return 'Nomor HP minimal 9 digit';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      _buildFieldLabel('Bio / Catatan Split Bill', palette),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Catatan singkat tentang kamu',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Pembayaran & QRIS Default
                _buildSectionHeader('METODE TERIMA DANA (SETTLEMENT)', palette),
                const SizedBox(height: 10),

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
                      _buildFieldLabel('Bank / E-Wallet Default', palette),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: palette.surfaceLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.outlineVariant.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBank,
                            isExpanded: true,
                            dropdownColor: palette.card,
                            items: _bankOptions.map((bank) {
                              return DropdownMenuItem(
                                value: bank,
                                child: Row(
                                  children: [
                                    const Icon(Icons.account_balance_rounded, size: 18, color: AppColors.primaryContainer),
                                    const SizedBox(width: 10),
                                    Text(
                                      bank,
                                      style: AppText.bodyMedium.copyWith(
                                        color: palette.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedBank = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Nomor Rekening / ID Akun', palette),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _bankAccountController,
                        decoration: const InputDecoration(
                          hintText: 'Misal: 1234567890 (a.n. Nama)',
                          prefixIcon: Icon(Icons.credit_card_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Informasi ini akan ditampilkan ke teman grup saat menyelesaikan tagihan (*settlement*).',
                        style: AppText.bodySm.copyWith(
                          fontSize: 11,
                          color: palette.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Preferensi Privasi & Notifikasi
                _buildSectionHeader('PREFERENSI & PRIVASI', palette),
                const SizedBox(height: 10),

                Material(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.cardBorder),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          activeColor: AppColors.primaryContainer,
                          value: _shareContactWithGroup,
                          title: Text(
                            'Bagikan nomor kontak ke anggota grup',
                            style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                          ),
                          subtitle: Text(
                            'Memudahkan teman mengirim bukti transfer atau chat',
                            style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant, fontSize: 11),
                          ),
                          onChanged: (val) => setState(() => _shareContactWithGroup = val),
                        ),
                        Divider(height: 1, color: palette.cardBorder),
                        SwitchListTile.adaptive(
                          activeColor: AppColors.primaryContainer,
                          value: _whatsappNotification,
                          title: Text(
                            'Pengingat tagihan via WhatsApp',
                            style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                          ),
                          subtitle: Text(
                            'Kirim ringkasan otomatis saat ada pengeluaran baru',
                            style: AppText.bodySm.copyWith(color: palette.onSurfaceVariant, fontSize: 11),
                          ),
                          onChanged: (val) => setState(() => _whatsappNotification = val),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Save button
                CustomButton(
                  text: 'Simpan Perubahan',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isSaving,
                  onPressed: _saveProfile,
                ),

                const SizedBox(height: 12),

                // Cancel button
                CustomButton(
                  text: 'Batal',
                  variant: ButtonVariant.outline,
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppText.labelSm.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: palette.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, AppPalette palette) {
    return Text(
      label,
      style: AppText.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: palette.onSurface,
      ),
    );
  }
}
