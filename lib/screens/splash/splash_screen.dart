import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/service_locator.dart';
import '../../state/auth_state.dart';

class SplashScreen extends StatefulWidget {
  final AuthState authState;
  final String? targetRoute;

  const SplashScreen({
    super.key,
    required this.authState,
    this.targetRoute,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _glowController;
  late final AnimationController _loadController;

  // Staggered Mark Animations (Spring pop: scale 0.4 -> 1.0, opacity 0 -> 1.0)
  late final Animation<double> _b1Anim;
  late final Animation<double> _b2Anim;
  late final Animation<double> _b3Anim;
  late final Animation<double> _b4Anim;

  // Text and Subtitle Animations (Rise: translateY 14 -> 0, opacity 0 -> 1.0)
  late final Animation<double> _wordAnim;
  late final Animation<double> _subAnim;
  late final Animation<double> _footAnim;

  Timer? _navigationTimer;

  static const Color _bgColor = Color(0xFF121417);
  static const Color _lineColor2 = Color(0x1FFFFFFF); // rgba(255,255,255, 0.12)
  static const Color _accentColor = Color(0xFFFF7E33);
  static const Color _mutedColor = Color(0xFF8F959E);

  @override
  void initState() {
    super.initState();

    // 1. Entrance timeline
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    const springCurve = Cubic(0.2, 0.9, 0.3, 1.2);

    // Staggered Mark bars matching .b2, .b3, .b4, .b5 (.15s, .3s, .45s, .6s)
    _b1Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.06, 0.35, curve: springCurve),
    );
    _b2Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.41, curve: springCurve),
    );
    _b3Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.18, 0.47, curve: springCurve),
    );
    _b4Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.24, 0.53, curve: springCurve),
    );

    // Words & Subtitles
    _wordAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.33, 0.62, curve: Curves.easeOut),
    );
    _subAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.41, 0.70, curve: Curves.easeOut),
    );
    _footAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.50, 0.79, curve: Curves.easeOut),
    );

    // 2. Ambient breathing glow loop (pulse 3.2s infinite)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // 3. Loader bar fill animation
    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    _entranceController.forward();
    _warmUpServices();

    // Automatic transition after splash sequence (~3.2 seconds) or tap to skip
    _navigationTimer = Timer(const Duration(milliseconds: 3200), () {
      _proceed();
    });
  }

  void _warmUpServices() {
    unawaited(services.attendanceService.getAttendanceData());
    unawaited(services.projectService.getProjects());
    unawaited(services.payrollService.getPayrollData());
  }

  void _proceed() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    HapticFeedback.lightImpact();

    final hasValidTarget = widget.targetRoute != null &&
        widget.targetRoute != AppRoutes.initial &&
        widget.targetRoute != AppRoutes.splash;

    final destination = hasValidTarget
        ? widget.targetRoute!
        : (widget.authState.isAuthenticated ? AppRoutes.main : AppRoutes.login);

    Navigator.pushReplacementNamed(context, destination);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _glowController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceed, // Allows immediate tap-to-continue
        child: Stack(
          children: [
            // Ambient Radial Glow (.glow2 in index.html: radial-gradient(circle at 50% 46%, var(--accent-glow) 0%, transparent 66%))
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, _) {
                final glowOpacity = 0.7 + (_glowController.value * 0.3); // 0.7 -> 1.0
                return Positioned.fill(
                  child: Opacity(
                    opacity: glowOpacity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.0, -0.08), // circle at 50% 46%
                          radius: 0.66,
                          colors: [
                            _accentColor.withValues(alpha: 0.16),
                            _accentColor.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.38, 0.66],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Center Content: Mark + "Essane Global" + Tag
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Mark + Title Row (.logo in index.html)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SVG Mark via Animated Custom Painter (width 62, height 116, viewBox 10 0 160 300)
                        AnimatedBuilder(
                          animation: _entranceController,
                          builder: (context, _) {
                            return SizedBox(
                              width: 62,
                              height: 116,
                              child: CustomPaint(
                                painter: _EssaneMarkPainter(
                                  b1Progress: _b1Anim.value,
                                  b2Progress: _b2Anim.value,
                                  b3Progress: _b3Anim.value,
                                  b4Progress: _b4Anim.value,
                                  color: _accentColor,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),

                        // Wordmarks: Essane (.word) & Global (.word2)
                        AnimatedBuilder(
                          animation: _wordAnim,
                          builder: (context, _) {
                            final riseY = (1.0 - _wordAnim.value) * 14.0;
                            return Opacity(
                              opacity: _wordAnim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, riseY),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Essane',
                                      style: TextStyle(
                                        fontSize: 54,
                                        fontWeight: FontWeight.w500,
                                        height: 1.0,
                                        letterSpacing: -0.5,
                                        color: _accentColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Global',
                                      style: TextStyle(
                                        fontSize: 33,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1,
                                        color: _accentColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Subtitle Tag (.tag in index.html: Company Management)
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _subAnim,
                      builder: (context, _) {
                        final riseY = (1.0 - _subAnim.value) * 14.0;
                        return Opacity(
                          opacity: _subAnim.value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, riseY),
                            child: Text(
                              'COMPANY MANAGEMENT',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 3.0,
                                color: _mutedColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer (.foot in index.html: .mods, .track, .load, .copy)
            Positioned(
              left: 0,
              right: 0,
              bottom: 36,
              child: SafeArea(
                top: false,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_footAnim, _loadController]),
                  builder: (context, _) {
                    final riseY = (1.0 - _footAnim.value) * 14.0;
                    return Opacity(
                      opacity: _footAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, riseY),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 4 Core Module Icons (.mods in index.html)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ModuleIconItem(
                                  icon: CupertinoIcons.square_grid_2x2,
                                  label: 'Dashboard',
                                ),
                                const SizedBox(width: 22),
                                _ModuleIconItem(
                                  icon: CupertinoIcons.person_2,
                                  label: 'Team',
                                ),
                                const SizedBox(width: 22),
                                _ModuleIconItem(
                                  icon: CupertinoIcons.briefcase,
                                  label: 'Projects',
                                ),
                                const SizedBox(width: 22),
                                _ModuleIconItem(
                                  icon: CupertinoIcons.chart_bar,
                                  label: 'Reports',
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Loading Track & Animated Fill (.track & .fill in index.html)
                            Container(
                              width: 140,
                              height: 3,
                              decoration: BoxDecoration(
                                color: _lineColor2,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              alignment: Alignment.centerLeft,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final fillProgress = Curves.easeInOut.transform(
                                    _loadController.value.clamp(0.0, 1.0),
                                  );
                                  return Container(
                                    width: 140 * fillProgress,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: _accentColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Loading workspace status (.load in index.html)
                            Text(
                              'Loading your workspace',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _mutedColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Copyright line (.copy in index.html)
                            Text(
                              '© 2026 Essane Global',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: _mutedColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Module icon item (.mod in index.html: 44x44 card, radius 14, icon + label)
class _ModuleIconItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ModuleIconItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x1FFFFFFF), width: 1.0),
            ),
            child: Icon(icon, size: 20, color: AppColors.accentDark),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.darkMuted,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Custom Painter reproducing the exact Essane Global SVG Mark geometry:
/// ViewBox: (10, 0, 160, 300)
/// - b2: rect x="116" y="5" width="46" height="110" rx="2"
/// - b3: rect x="116" y="195" width="46" height="100" rx="2"
/// - b4: line x1="20" y1="80" x2="104" y2="128" stroke-width="46"
/// - b5: line x1="20" y1="230" x2="104" y2="182" stroke-width="46"
class _EssaneMarkPainter extends CustomPainter {
  final double b1Progress;
  final double b2Progress;
  final double b3Progress;
  final double b4Progress;
  final Color color;

  _EssaneMarkPainter({
    required this.b1Progress,
    required this.b2Progress,
    required this.b3Progress,
    required this.b4Progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double vbX = 10.0;
    const double vbY = 0.0;
    const double vbWidth = 160.0;
    const double vbHeight = 300.0;

    final double scaleX = size.width / vbWidth;
    final double scaleY = size.height / vbHeight;

    canvas.save();
    canvas.scale(scaleX, scaleY);
    canvas.translate(-vbX, -vbY);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 46.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    void drawWithPop(Canvas c, Offset center, double progress, void Function() drawFn) {
      if (progress <= 0.0) return;
      c.save();
      final scale = 0.4 + (progress * 0.6);
      c.translate(center.dx, center.dy);
      c.scale(scale);
      c.translate(-center.dx, -center.dy);

      drawFn();
      c.restore();
    }

    // Bar 1 (b2): rect (116, 5, 46, 110)
    if (b1Progress > 0) {
      final r1 = RRect.fromRectAndRadius(
        const Rect.fromLTWH(116, 5, 46, 110),
        const Radius.circular(2),
      );
      final c1 = const Offset(116 + 23, 5 + 55);
      drawWithPop(canvas, c1, b1Progress, () {
        fillPaint.color = color.withValues(alpha: b1Progress.clamp(0.0, 1.0));
        canvas.drawRRect(r1, fillPaint);
      });
    }

    // Bar 2 (b3): rect (116, 195, 46, 100)
    if (b2Progress > 0) {
      final r2 = RRect.fromRectAndRadius(
        const Rect.fromLTWH(116, 195, 46, 100),
        const Radius.circular(2),
      );
      final c2 = const Offset(116 + 23, 195 + 50);
      drawWithPop(canvas, c2, b2Progress, () {
        fillPaint.color = color.withValues(alpha: b2Progress.clamp(0.0, 1.0));
        canvas.drawRRect(r2, fillPaint);
      });
    }

    // Bar 3 (b4): line (20, 80) -> (104, 128)
    if (b3Progress > 0) {
      final p1 = const Offset(20, 80);
      final p2 = const Offset(104, 128);
      final c3 = const Offset((20 + 104) / 2, (80 + 128) / 2);
      drawWithPop(canvas, c3, b3Progress, () {
        strokePaint.color = color.withValues(alpha: b3Progress.clamp(0.0, 1.0));
        canvas.drawLine(p1, p2, strokePaint);
      });
    }

    // Bar 4 (b5): line (20, 230) -> (104, 182)
    if (b4Progress > 0) {
      final p3 = const Offset(20, 230);
      final p4 = const Offset(104, 182);
      final c4 = const Offset((20 + 104) / 2, (230 + 182) / 2);
      drawWithPop(canvas, c4, b4Progress, () {
        strokePaint.color = color.withValues(alpha: b4Progress.clamp(0.0, 1.0));
        canvas.drawLine(p3, p4, strokePaint);
      });
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EssaneMarkPainter oldDelegate) {
    return oldDelegate.b1Progress != b1Progress ||
        oldDelegate.b2Progress != b2Progress ||
        oldDelegate.b3Progress != b3Progress ||
        oldDelegate.b4Progress != b4Progress ||
        oldDelegate.color != color;
  }
}
