import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _progressAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.58, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.46, curve: Curves.easeOutBack),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.26, 0.72, curve: Curves.easeOutCubic),
          ),
        );

    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.45, 1, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _timer = Timer(const Duration(milliseconds: 2400), _openAuthWrapper);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _openAuthWrapper() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final value = _animationController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (value * 22),
                    right: -90 + (value * 16),
                    child: _buildGlowCircle(230, AppColors.primaryGreen),
                  ),
                  Positioned(
                    bottom: -120 + (value * 18),
                    left: -90 + (value * 24),
                    child: _buildGlowCircle(270, AppColors.mediumGreen),
                  ),
                ],
              );
            },
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedLogo(),
                    const SizedBox(height: 26),
                    SlideTransition(
                      position: _titleSlideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'FITNOVA',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Move Better. Live Stronger.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 42),
                    _buildLoadingBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;
        final pulse = 1 + math.sin(value * math.pi * 3) * 0.055;
        final ringOpacity = (1 - value).clamp(0.0, 1.0);

        return SizedBox(
          width: 156,
          height: 156,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + (value * 0.34),
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(
                        alpha: ringOpacity * 0.22,
                      ),
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: value * math.pi * 2.25,
                child: CustomPaint(
                  size: const Size(132, 132),
                  painter: _OrbitRingPainter(progress: value),
                ),
              ),
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: AppColors.softCard,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.28),
                        blurRadius: 42,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primaryGreen,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingBar() {
    return FadeTransition(
      opacity: _progressAnimation,
      child: Column(
        children: [
          SizedBox(
            width: 168,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    minHeight: 6,
                    backgroundColor: AppColors.softCard,
                    color: AppColors.primaryGreen,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Preparing your workout space',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final double progress;

  _OrbitRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.borderSoft.withValues(alpha: 0.75);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primaryGreen;

    canvas.drawCircle(center, radius - 2, ringPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -math.pi / 2,
      math.pi * (0.7 + progress * 0.35),
      false,
      arcPaint,
    );

    final dotAngle = -math.pi / 2 + progress * math.pi * 2;
    final dotOffset = Offset(
      center.dx + math.cos(dotAngle) * (radius - 2),
      center.dy + math.sin(dotAngle) * (radius - 2),
    );
    canvas.drawCircle(dotOffset, 4, Paint()..color = AppColors.softMint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
