import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../state/auth_state.dart';

/// Sign In Screen mirroring login.html & styles.css
class LoginScreen extends StatefulWidget {
  final AuthState authState;

  const LoginScreen({super.key, required this.authState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'sarah.jenkins@essane.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  late final AnimationController _animController;
  late final Animation<double> _brandFade;
  late final Animation<Offset> _brandSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // Replicate .rise & .d2 animations from styles.css
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _brandFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _brandSlide = Tween<Offset>(begin: const Offset(0, 14), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // .d2 (delayed by ~0.12s)
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.18, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 14), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.18, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authState.login(email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Invalid credentials. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillDemoUser(UserRole role) {
    HapticFeedback.selectionClick();
    setState(() {
      if (role == UserRole.employee) {
        _emailController.text = 'sarah.jenkins@essane.com';
      } else {
        _emailController.text = 'marcus.vance@essane.com';
      }
      _passwordController.text = 'password123';
      _errorMessage = null;
    });
  }

  void _showForgotPasswordDialog(Color accent, Color bg, Color cardBg, Color borderCol2, Color textPrimary, Color textSoft) {
    HapticFeedback.lightImpact();
    final resetController = TextEditingController(text: _emailController.text);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol2, width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your work email address and we will send you instructions to reset your password.',
                    style: TextStyle(
                      fontSize: 13,
                      color: textSoft,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol2, width: 1.0),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: resetController,
                      style: TextStyle(fontSize: 15, color: textPrimary, fontFamily: 'Poppins'),
                      cursorColor: accent,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'you@company.com',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: accent, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: accent,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset instructions sent to your email.'),
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Send link',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol2 = isDark ? AppColors.darkLine2 : AppColors.lightLine2;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final textSoft = isDark ? AppColors.darkSoft : AppColors.lightSoft;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentGlow = isDark ? AppColors.darkAccentGlow : AppColors.lightAccentSoft;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Top Ambient Glow from styles.css: radial-gradient(circle at 85% 0, var(--accent-glow) 0%, transparent 65%)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 300,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -1.0),
                    radius: 0.85,
                    colors: [
                      accentGlow,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),
          ),

          // Main Page Content (.app > .page in login.html)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Brand Row (login.html line 22: <div class="brand rise">...<svg>...<div class="a">Essane</div><div class="b">Global</div></div>)
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _brandFade.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: _brandSlide.value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // SVG geometric mark (width: 34, height: 64, viewBox: 10 0 160 300)
                              SizedBox(
                                width: 34,
                                height: 64,
                                child: CustomPaint(
                                  painter: _EssaneMarkPainter(color: accent),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // .col: .a "Essane" & .b "Global"
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Essane',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500,
                                      height: 1.0,
                                      color: accent,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    'Global',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                      color: accent,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. Heading Block & Form animated with .rise.d2
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _contentFade.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: _contentSlide.value,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading Block (login.html line 31: <div class="col rise d2" style="margin-top:48px;gap:6px">)
                            const SizedBox(height: 48),
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                                height: 1.2,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to your workspace to continue.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: textMuted,
                                fontFamily: 'Poppins',
                              ),
                            ),

                            // Error Message Banner if any
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.redSoft : const Color(0x1AC62828),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppColors.red : const Color(0xFFC62828),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.exclamationmark_circle,
                                      size: 16,
                                      color: isDark ? AppColors.red : const Color(0xFFC62828),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? AppColors.red : const Color(0xFFC62828),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Form (login.html line 35: <form action="dashboard.html" class="col rise d2" style="margin-top:32px;gap:18px">)
                            const SizedBox(height: 32),

                            // Field 1: Work email (<div class="field"><label for="email">Work email</label>...)
                            Text(
                              'Work email',
                              style: TextStyle(
                                fontSize: 13,
                                color: textSoft,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderCol2, width: 1.0),
                              ),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                cursorColor: accent,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'you@company.com',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: textMuted,
                                    fontFamily: 'Poppins',
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Field 2: Password (<div class="field"><label for="pw">Password</label>...)
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 13,
                                color: textSoft,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 52,
                              padding: const EdgeInsets.only(left: 16, right: 8),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderCol2, width: 1.0),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: !_showPassword,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _handleLogin(),
                                      cursorColor: accent,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: textPrimary,
                                        fontFamily: 'Poppins',
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your password',
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: textMuted,
                                          fontFamily: 'Poppins',
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? CupertinoIcons.eye_slash
                                          : CupertinoIcons.eye,
                                      size: 18,
                                      color: textMuted,
                                    ),
                                    onPressed: () {
                                      setState(() => _showPassword = !_showPassword);
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Forgot password link (<a class="forgot" href="#">Forgot password?</a>)
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => _showForgotPasswordDialog(
                                  accent,
                                  bg,
                                  cardBg,
                                  borderCol2,
                                  textPrimary,
                                  textSoft,
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 44),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: accent,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Sign In Button (<button class="btn" type="submit">Sign in</button>)
                            GestureDetector(
                              onTap: _isLoading ? null : _handleLogin,
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const CupertinoActivityIndicator(color: Colors.white)
                                    : const Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                              ),
                            ),

                            // Demo Accounts Switcher (subtle convenience for reviewers)
                            const SizedBox(height: 24),
                            Center(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    'Demo:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textMuted,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _fillDemoUser(UserRole.employee),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: borderCol2, width: 0.8),
                                      ),
                                      child: Text(
                                        'Sarah (Staff)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: textSoft,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _fillDemoUser(UserRole.admin),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: borderCol2, width: 0.8),
                                      ),
                                      child: Text(
                                        'Marcus (Admin)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: textSoft,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Copyright footer (<p class="sub" style="text-align:center;margin-top:48px;font-size:11px">© 2026 Essane Global</p>)
                            const SizedBox(height: 48),
                            Center(
                              child: Text(
                                '© 2026 Essane Global',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textMuted,
                                  fontFamily: 'Poppins',
                                ),
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
          ),
        ],
      ),
    );
  }
}

// Geometric SVG Mark Custom Painter matching login.html SVG:
// <svg width="34" height="64" viewBox="10 0 160 300" role="img" aria-label="Essane Global mark">
// <rect x="116" y="5" width="46" height="110" rx="2" fill="var(--accent)"/>
// <rect x="116" y="195" width="46" height="100" rx="2" fill="var(--accent)"/>
// <line x1="20" y1="80" x2="104" y2="128" stroke="var(--accent)" stroke-width="46"/>
// <line x1="20" y1="230" x2="104" y2="182" stroke="var(--accent)" stroke-width="46"/>
// </svg>
class _EssaneMarkPainter extends CustomPainter {
  final Color color;

  const _EssaneMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Transform viewBox: 10 0 160 300 into size
    final scaleX = size.width / 160.0;
    final scaleY = size.height / 300.0;
    canvas.scale(scaleX, scaleY);
    canvas.translate(-10.0, 0.0);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Rect 1: x="116" y="5" width="46" height="110" rx="2"
    final r1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(116, 5, 46, 110),
      const Radius.circular(2),
    );
    canvas.drawRRect(r1, fillPaint);

    // 2. Rect 2: x="116" y="195" width="46" height="100" rx="2"
    final r2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(116, 195, 46, 100),
      const Radius.circular(2),
    );
    canvas.drawRRect(r2, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 46.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    // 3. Line 1: line x1="20" y1="80" x2="104" y2="128" stroke-width="46"
    canvas.drawLine(const Offset(20, 80), const Offset(104, 128), strokePaint);

    // 4. Line 2: line x1="20" y1="230" x2="104" y2="182" stroke-width="46"
    canvas.drawLine(const Offset(20, 230), const Offset(104, 182), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EssaneMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
