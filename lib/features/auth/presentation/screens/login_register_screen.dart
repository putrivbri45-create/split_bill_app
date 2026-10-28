import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController(text: 'putrivbri@splitbill.id');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final authBloc = context.read<AuthBloc>();
    if (_isLogin) {
      if (_identifierController.text.trim().isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan masukkan email/no HP dan password')),
        );
        return;
      }
      authBloc.add(AuthLoginRequested(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      ));
    } else {
      if (_nameController.text.trim().isEmpty || _identifierController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan lengkapi formulir pendaftaran')),
        );
        return;
      }
      authBloc.add(AuthRegisterRequested(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _identifierController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Text(
              'Split Bill',
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
                    const SnackBar(content: Text('Pusat Bantuan Split Bill: Hubungi support@splitbill.id')),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Logo Box
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.diversity_3_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Split Bill',
                    style: AppText.headlineLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Biar adil, nggak ribet.',
                    style: AppText.bodyMedium.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Container Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: palette.cardBorder, width: 1.2),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Segmented Toggle Masuk / Daftar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLogin = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isLogin ? (isDark ? AppColors.darkSurfaceContainerLowest : Colors.white) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _isLogin ? AppShadows.card : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Masuk',
                                      style: AppText.labelLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: _isLogin ? (isDark ? AppColors.primaryFixed : AppColors.primary) : palette.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLogin = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !_isLogin ? (isDark ? AppColors.darkSurfaceContainerLowest : Colors.white) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: !_isLogin ? AppShadows.card : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Daftar',
                                      style: AppText.labelLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: !_isLogin ? (isDark ? AppColors.primaryFixed : AppColors.primary) : palette.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register Extra Fields
                        if (!_isLogin) ...[
                          Text(
                            'Nama Lengkap',
                            style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: Putri Feby',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Nomor WhatsApp',
                            style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '0812-3456-7890',
                              prefixIcon: Icon(Icons.phone_iphone_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],


                        // Identifier
                        Text(
                          'Email atau Nomor HP',
                          style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'contoh@email.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password
                        Text(
                          'Password',
                          style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: palette.onSurface),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Minimal 8 karakter',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Remember me & Forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ingat saya',
                                  style: AppText.bodySm.copyWith(color: palette.onSurface),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tautan reset password telah dikirimkan ke email Anda')),
                                );
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Text(
                                'Lupa password?',
                                style: AppText.bodySm.copyWith(
                                  color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Submit Button
                        CustomButton(
                          text: _isLogin ? 'Masuk' : 'Daftar Akun',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),


                        const SizedBox(height: 18),

                        // Switch Mode text
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = !_isLogin),
                            child: RichText(
                              text: TextSpan(
                                text: _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                                style: AppText.bodyMedium.copyWith(color: palette.onSurfaceVariant),
                                children: [
                                  TextSpan(
                                    text: _isLogin ? 'Daftar sekarang' : 'Masuk sekarang',
                                    style: TextStyle(
                                      color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom 3 Trust Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTrustBadge(Icons.view_agenda_outlined, 'Bagi Otomatis', palette),
                      _buildTrustBadge(Icons.qr_code_scanner_rounded, 'Scan Struk', palette),
                      _buildTrustBadge(Icons.verified_user_outlined, 'Aman & Terbuka', palette),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© 2026 Split Bill. Solusi bagi tagihan bersama.',
                    style: AppText.bodySm.copyWith(
                      fontSize: 11,
                      color: palette.outline,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrustBadge(IconData icon, String label, AppPalette palette) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryContainer),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppText.labelSm.copyWith(
            color: palette.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
