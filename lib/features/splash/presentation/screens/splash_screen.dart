import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseGlow;

  late AnimationController _loadingController;
  late AnimationController _progressController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Safe auth session check after frame is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<AuthBloc>().add(AuthCheckRequested());
        } catch (_) {}
      }
    });

    // 1. Initial entrance animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();

    // 2. Continuous subtle breathing/pulse animation for the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
    _pulseGlow = Tween<double>(begin: 0.22, end: 0.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 3. Dot loading animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // 4. Timer dan Progress Bar 10 detik sebelum masuk ke halaman login/utama
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _proceedToNext();
      }
    });
  }

  void _proceedToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
        return;
      }
    } catch (_) {}
    Navigator.pushReplacementNamed(context, AppRoutes.loginRegister);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF091A15),
                        const Color(0xFF0F171A),
                        const Color(0xFF0D1217),
                      ]
                    : [
                        const Color(0xFFE8FAF3),
                        const Color(0xFFF7FCFA),
                        const Color(0xFFFAF8FF),
                      ],
              ),
            ),
          ),

          // Ambient Mint & Emerald Decorative Blurs (matching design prototype)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF14B8A6) : const Color(0xFF6DF5E1)).withOpacity(isDark ? 0.15 : 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF10B981) : const Color(0xFF6FFBBE)).withOpacity(isDark ? 0.12 : 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: 30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF059669) : const Color(0xFF71F8E4)).withOpacity(isDark ? 0.12 : 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top security header tags & Skip button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PATUNGAN ID',
                            style: AppText.labelSm.copyWith(
                              letterSpacing: 1.2,
                              color: isDark ? AppColors.primaryFixed : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Terenkripsi',
                            style: AppText.labelSm.copyWith(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Tombol Lewati untuk langsung ke halaman login
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _proceedToNext,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Lewati',
                                      style: AppText.labelSm.copyWith(
                                        color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Center brand & logo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Animated Hero Logo with Living Glow
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseScale.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryContainer.withOpacity(_pulseGlow.value),
                                          blurRadius: 36,
                                          spreadRadius: 4,
                                          offset: const Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: AppColors.secondaryContainer.withOpacity(_pulseGlow.value * 0.7),
                                          blurRadius: 44,
                                          spreadRadius: 1,
                                          offset: const Offset(0, -4),
                                        ),
                                      ],
                                    ),
                                    child: const AppLogo(
                                      size: 112,
                                      showGlow: false,
                                      borderRadius: 26,
                                      padding: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // App Name
                            Text(
                              'Patungan',
                              style: AppText.headlineXl.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Core Tagline
                            Text(
                              'Biar adil, nggak ribet.',
                              style: AppText.bodyLarge.copyWith(
                                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Social Comfort Highlight Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF132B25) : const Color(0xFFEDFBF6),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(
                                  color: AppColors.primaryContainer.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    size: 16,
                                    color: AppColors.primaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bagi tagihan tanpa rasa canggung',
                                    style: AppText.labelSm.copyWith(
                                      color: isDark ? AppColors.primaryFixed : AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom footer with animated dots & credentials
                  Column(
                    children: [
                      // Animated Loading Dots Wave (Mint, Emerald, Deep Green)
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          final colors = [
                            AppColors.primaryContainer,
                            isDark ? AppColors.primaryFixed : AppColors.primary,
                            AppColors.secondaryContainer,
                          ];

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final offset = index * 0.22;
                              final t = (_loadingController.value - offset) % 1.0;
                              final wave = math.sin(t * 2 * math.pi);
                              final translateY = (wave < 0 ? wave * 4.5 : 0.0);
                              final opacity = 0.45 + (0.55 * (wave < 0 ? -wave : 0.0));

                              return Transform.translate(
                                offset: Offset(0, translateY),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors[index].withOpacity(opacity.clamp(0.3, 1.0)),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Memuat pengalaman berbagi yang adil...',
                        style: AppText.bodySm.copyWith(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Indikator Progress Bar 10 Detik
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          final secondsRemaining = (10 * (1.0 - _progressController.value)).ceil();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 180,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1B332B) : const Color(0xFFE2F5ED),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 180 * _progressController.value.clamp(0.0, 1.0),
                                    height: 5,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF10B981),
                                          Color(0xFF14B8A6),
                                          Color(0xFF34D399),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryContainer.withOpacity(0.35),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Menuju halaman masuk ($secondsRemaining detik)',
                                style: AppText.labelSm.copyWith(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkOnSurfaceVariant.withOpacity(0.7)
                                      : AppColors.onSurfaceVariant.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'v2.4.0 • Karya Anak Bangsa',
                        style: AppText.labelSm.copyWith(
                          color: isDark ? AppColors.darkOutline : AppColors.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: palette.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Standard Standar Keuangan ISO/IEC 27001',
                            style: AppText.bodySm.copyWith(
                              fontSize: 11,
                              color: isDark ? AppColors.darkOutline : AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
