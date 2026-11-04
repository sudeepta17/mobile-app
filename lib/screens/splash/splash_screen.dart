import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/navigation/app_routes.dart';
import '../../services/service_locator.dart';
import '../../state/auth_state.dart';

/// Warm Light Splash Screen mirroring Light2.dc.html
/// - Background: LinearGradient(165deg, #FFF6EE 0%, #FFE6D4 100%)
/// - Concentric ambient rings pulsing behind mark (#E8590C, 5 circles)
/// - Geometric mark: 4 bars in #E8590C with staggered pop animations
/// - Wordmark: "Essane Global" (#E8590C, Poppins) with rise animation
/// - Subtitle: "COMPANY MANAGEMENT" (#5B616B)
/// - Foot modules: Dashboard, Team, Projects, Reports with custom SVG paths
/// - Loading bar & "Loading your workspace"
/// - Automatically routes to AppRoutes.login after splash completion
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

  // Staggered Mark Animations (Pop curve: cubic-bezier(.2,.9,.3,1.2))
  late final Animation<double> _b1Anim;
  late final Animation<double> _b2Anim;
  late final Animation<double> _b3Anim;
  late final Animation<double> _b4Anim;

  // Rise Animations (translateY 14 -> 0, opacity 0 -> 1.0)
  late final Animation<double> _wordAnim;
  late final Animation<double> _subAnim;
  late final Animation<double> _footAnim;

  Timer? _navigationTimer;

  // Colors from Light2.dc.html
  static const Color _accentColor = Color(0xFFE8590C); // Warm Deep Orange
  static const Color _mutedColor = Color(0xFF5B616B); // Subtitle & label grey
  static const Color _trackColor = Color(0x1A121417); // rgba(18,20,23, 0.10)

  @override
  void initState() {
    super.initState();

    // 1. Entrance timeline (total 2400ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    const springCurve = Cubic(0.2, 0.9, 0.3, 1.2);

    // Staggered Mark bars (.es-b1, .es-b2, .es-b3, .es-b4 matching .15s, .3s, .45s, .6s)
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

    // Wordmark rise (.es-word delay 0.8s)
    _wordAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.33, 0.62, curve: Curves.easeOut),
    );

    // Subtitle rise (.es-sub delay 1.0s)
    _subAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.41, 0.70, curve: Curves.easeOut),
    );

    // Foot modules rise (.es-foot delay 1.2s)
    _footAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.50, 0.79, curve: Curves.easeOut),
    );

    // 2. Ambient breathing glow loop (pulse 3.2s infinite ease-in-out)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // 3. Loader bar fill animation (3s infinite loop)
    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _entranceController.forward();
    _warmUpServices();

    // Automatic transition to Login page after splash sequence (~3.2 seconds) or tap to skip
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

    // Transition directly to Login page as requested
    final destination = hasValidTarget ? widget.targetRoute! : AppRoutes.login;

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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceed, // Allows immediate tap-to-continue
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // Background: 165deg, #FFF6EE 0%, #FFE6D4 100%
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.26, -0.97),
              end: Alignment(0.26, 0.97),
              colors: [
                Color(0xFFFFF6EE),
                Color(0xFFFFE6D4),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 0. Fluid Ribbon Background Wallpaper
              Positioned.fill(
                child: Image.asset(
                  'assets/images/app_background.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),

              // 1. Concentric ambient rings pulsing behind logo mark (cx: 195, cy: 388 on 390x844)
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  // es-glow: 0%, 100% { opacity: 0.7 } 50% { opacity: 1.0 }
                  final glowOpacity = 0.7 + (Curves.easeInOut.transform(_glowController.value) * 0.3);
                  return Opacity(
                    opacity: glowOpacity,
                    child: CustomPaint(
                      painter: _ConcentricRingsPainter(color: _accentColor),
                    ),
                  );
                },
              ),

              // 2. Center Content: SVG Mark + "Essane Global" + "Company Management"
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand Mark + Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // SVG Mark (width 62, height 116, viewBox 10 0 160 300)
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

                          // Wordmark Column: "Essane" & "Global"
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
                                    children: const [
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
                                      SizedBox(height: 2),
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

                      // Subtitle Tag: "COMPANY MANAGEMENT" (margin-top: 40px)
                      const SizedBox(height: 40),
                      AnimatedBuilder(
                        animation: _subAnim,
                        builder: (context, _) {
                          final riseY = (1.0 - _subAnim.value) * 14.0;
                          return Opacity(
                            opacity: _subAnim.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, riseY),
                              child: const Text(
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

              // 3. Footer: Modules (Dashboard, Team, Projects, Reports) + Loading Track + Copyright
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
                              // 4 Core Module Cards (gap: 22px)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  _ModuleCard(
                                    type: _ModuleType.dashboard,
                                    label: 'Dashboard',
                                  ),
                                  SizedBox(width: 22),
                                  _ModuleCard(
                                    type: _ModuleType.team,
                                    label: 'Team',
                                  ),
                                  SizedBox(width: 22),
                                  _ModuleCard(
                                    type: _ModuleType.projects,
                                    label: 'Projects',
                                  ),
                                  SizedBox(width: 22),
                                  _ModuleCard(
                                    type: _ModuleType.reports,
                                    label: 'Reports',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // Loading Track & Animated Fill (width 140, height 3)
                              Container(
                                width: 140,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: _trackColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                alignment: Alignment.centerLeft,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // es-load animation: 0% scaleX(0) -> 70% scaleX(1) -> 100% scaleX(1)
                                    final progress = _loadController.value;
                                    final fillWidth = progress <= 0.7
                                        ? 140 * Curves.easeInOut.transform(progress / 0.7)
                                        : 140.0;
                                    return Container(
                                      width: fillWidth,
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

                              // Status: "Loading your workspace"
                              const Text(
                                'Loading your workspace',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: _mutedColor,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Copyright: "© 2026 Essane Global"
                              const Text(
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
      ),
    );
  }
}

/// Concentric ambient rings painter reproducing Light2.dc.html:
/// 5 circles centered behind logo mark:
/// - r=120, opacity=0.16, strokeWidth=1.5
/// - r=190, opacity=0.12, strokeWidth=1.5
/// - r=260, opacity=0.09, strokeWidth=1.5
/// - r=330, opacity=0.06, strokeWidth=1.5
/// - r=400, opacity=0.04, strokeWidth=1.5
class _ConcentricRingsPainter extends CustomPainter {
  final Color color;

  _ConcentricRingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Relative center matching cx="195" cy="388" on 390x844 frame
    final center = Offset(size.width * 0.5, size.height * 0.46);

    const rings = [
      (120.0, 0.16),
      (190.0, 0.12),
      (260.0, 0.09),
      (330.0, 0.06),
      (400.0, 0.04),
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final ring in rings) {
      paint.color = color.withValues(alpha: ring.$2);
      canvas.drawCircle(center, ring.$1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

enum _ModuleType { dashboard, team, projects, reports }

/// Module card item matching Light2.dc.html:
/// 44x44 card, radius 14, border rgba(18,20,23,0.12), bg rgba(18,20,23,0.03), icon stroke #E8590C
class _ModuleCard extends StatelessWidget {
  final _ModuleType type;
  final String label;

  const _ModuleCard({
    required this.type,
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
              color: const Color(0x08121417), // rgba(18,20,23,0.03)
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0x1F121417), // rgba(18,20,23,0.12)
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(
                painter: _ModuleIconPainter(type: type, color: const Color(0xFFE8590C)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF5B616B),
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

/// Custom Painter drawing the exact SVG module icons from Light2.dc.html
class _ModuleIconPainter extends CustomPainter {
  final _ModuleType type;
  final Color color;

  _ModuleIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 24x24 coordinate space scaled to size
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case _ModuleType.dashboard:
        // 4 grid rects: (3,3,7,7), (14,3,7,7), (3,14,7,7), (14,14,7,7), rx=1.5
        const r = Radius.circular(1.5);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 3, 7, 7), r), strokePaint);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, 3, 7, 7), r), strokePaint);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 14, 7, 7), r), strokePaint);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, 14, 7, 7), r), strokePaint);
        break;

      case _ModuleType.team:
        // Circle (cx 9, cy 8, r 3.2), Body arc path M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6
        // Secondary arc M16 5.2a3.2 3.2 0 0 1 0 5.6 and M18 14.4c1.8.8 3 2.7 3 5.6
        canvas.drawCircle(const Offset(9, 8), 3.2, strokePaint);
        final body1 = Path()
          ..moveTo(3, 20)
          ..cubicTo(3, 16.7, 5.7, 14, 9, 14)
          ..cubicTo(12.3, 14, 15, 16.7, 15, 20);
        canvas.drawPath(body1, strokePaint);

        final secHead = Path()
          ..arcToPoint(const Offset(16, 10.8), radius: const Radius.circular(3.2));
        final secHeadP = Path()..moveTo(16, 5.2)..addPath(secHead, Offset.zero);
        canvas.drawPath(secHeadP, strokePaint);

        final secBody = Path()
          ..moveTo(18, 14.4)
          ..cubicTo(19.8, 15.2, 21, 17.1, 21, 20);
        canvas.drawPath(secBody, strokePaint);
        break;

      case _ModuleType.projects:
        // Briefcase: rect(3, 7, 18, 13, rx 2) and handle M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3, 7, 18, 13), const Radius.circular(2)),
          strokePaint,
        );
        final handle = Path()
          ..moveTo(9, 7)
          ..lineTo(9, 5)
          ..cubicTo(9, 4.45, 9.45, 4, 10, 4)
          ..lineTo(14, 4)
          ..cubicTo(14.55, 4, 15, 4.45, 15, 5)
          ..lineTo(15, 7);
        canvas.drawPath(handle, strokePaint);
        break;

      case _ModuleType.reports:
        // Bar chart: M4 20V10, M10 20V4, M16 20V13, M21 20H3
        canvas.drawLine(const Offset(4, 20), const Offset(4, 10), strokePaint);
        canvas.drawLine(const Offset(10, 20), const Offset(10, 4), strokePaint);
        canvas.drawLine(const Offset(16, 20), const Offset(16, 13), strokePaint);
        canvas.drawLine(const Offset(21, 20), const Offset(3, 20), strokePaint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ModuleIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}

/// Custom Painter reproducing the exact Essane Global SVG Mark geometry:
/// ViewBox: (10, 0, 160, 300)
/// - b1: rect x="116" y="5" width="46" height="110" rx="2"
/// - b2: rect x="116" y="195" width="46" height="100" rx="2"
/// - b3: line x1="20" y1="80" x2="104" y2="128" stroke-width="46"
/// - b4: line x1="20" y1="230" x2="104" y2="182" stroke-width="46"
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

    // Bar 1 (b1): rect (116, 5, 46, 110)
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

    // Bar 2 (b2): rect (116, 195, 46, 100)
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

    // Bar 3 (b3): line (20, 80) -> (104, 128)
    if (b3Progress > 0) {
      final p1 = const Offset(20, 80);
      final p2 = const Offset(104, 128);
      final c3 = const Offset((20 + 104) / 2, (80 + 128) / 2);
      drawWithPop(canvas, c3, b3Progress, () {
        strokePaint.color = color.withValues(alpha: b3Progress.clamp(0.0, 1.0));
        canvas.drawLine(p1, p2, strokePaint);
      });
    }

    // Bar 4 (b4): line (20, 230) -> (104, 182)
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
