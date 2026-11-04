import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/user_model.dart';
import '../../state/auth_state.dart';

/// Pixel-perfect implementation of the Warm Light Login Screen
/// matching media_1793698266948_8076b05a.jpg:
/// - Flowing fluid warm orange ribbon wave background
/// - Centered floating white card (radius 32, ambient warm shadow)
/// - Brand mark + "Essane Global" in #E8590C
/// - "Welcome back" (bold, 32px) & "Sign in to your workspace to continue."
/// - "Work email" with mail leading icon, text, and green checkmark
/// - "Password" with lock leading icon, dots, and eye toggle
/// - "Forgot password?" right-aligned in #EA580C
/// - "Sign in →" button with rich orange gradient and glowing shadow
/// - Demo switcher: "Sarah (Staff)" and "Marcus (Admin)" with icons
/// - "© 2026 Essane Global" centered copyright
class LoginScreen extends StatefulWidget {
  final AuthState authState;

  const LoginScreen({super.key, required this.authState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'sarah.jenkins@essane.com');
  final _passwordController = TextEditingController(text: 'password123');
  FocusNode? _emailFocus;
  FocusNode? _passwordFocus;
  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  FocusNode get _effectiveEmailFocus {
    _emailFocus ??= FocusNode()..addListener(_onFocusChanged);
    return _emailFocus!;
  }

  FocusNode get _effectivePasswordFocus {
    _passwordFocus ??= FocusNode()..addListener(_onFocusChanged);
    return _passwordFocus!;
  }

  AnimationController? _animController;
  Animation<double>? _cardFade;
  Animation<Offset>? _cardSlide;

  static const Color _brandColor = Color(0xFFE8590C); // Warm Deep Orange
  static const Color _btnGradientStart = Color(0xFFFA5E03); // Rich Orange
  static const Color _btnGradientEnd = Color(0xFFD9480F); // Deep Terracotta
  static const Color _labelColor = Color(0xFF374151); // Dark charcoal for labels
  static const Color _mutedColor = Color(0xFF6B7280); // Cool medium grey
  static const Color _fieldBg = Colors.white; // Clean white field background
  static const Color _fieldBorder = Color(0xFFE5E7EB); // Subtle outline

  @override
  void initState() {
    super.initState();
    _ensureAnimations();
    _emailController.addListener(_onEmailChanged);
    _effectiveEmailFocus;
    _effectivePasswordFocus;
  }

  void _onEmailChanged() {
    if (mounted) setState(() {});
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _ensureAnimations() {
    if (_animController == null) {
      _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      );
      _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController!,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
        ),
      );
      _cardSlide = Tween<Offset>(begin: const Offset(0, 16), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animController!,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
        ),
      );
      _animController!.forward();
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _emailController.removeListener(_onEmailChanged);
    _emailFocus?.removeListener(_onFocusChanged);
    _passwordFocus?.removeListener(_onFocusChanged);
    _emailFocus?.dispose();
    _passwordFocus?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    return email.contains('@') && email.contains('.');
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

  void _showForgotPasswordDialog() {
    HapticFeedback.lightImpact();
    final resetController = TextEditingController(text: _emailController.text);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reset password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your work email address and we will send you a reset link.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _fieldBorder, width: 1.0),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: resetController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                      ),
                      cursorColor: _brandColor,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
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
                              border: Border.all(color: _fieldBorder, width: 1.0),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B5563),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                              gradient: const LinearGradient(
                                colors: [_btnGradientStart, _btnGradientEnd],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Send link',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
    _ensureAnimations();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0), // Soft warm peach background
      body: Stack(
        children: [
          // 1. Exact Fluid Ribbon Background Wallpaper matching media_1793781287342_d0740728.jpg
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => CustomPaint(
                painter: _FluidRibbonPainter(),
              ),
            ),
          ),

          // 2. Main Scrollable View with Floating Glass Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: AnimatedBuilder(
                  animation: _animController ?? const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                    final opacity = _cardFade?.value.clamp(0.0, 1.0) ?? 1.0;
                    final offset = _cardSlide?.value ?? Offset.zero;
                    return Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: offset,
                        child: child,
                      ),
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Brand Logo Row: SVG Mark + "Essane Global" ---
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // SVG Geometric Mark (width 36, height 68)
                              SizedBox(
                                width: 36,
                                height: 68,
                                child: CustomPaint(
                                  painter: _EssaneMarkPainter(color: _brandColor),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // "Essane" & "Global"
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Essane',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      height: 1.05,
                                      color: _brandColor,
                                      fontFamily: 'Poppins',
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Global',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      height: 1.1,
                                      color: _brandColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // --- Heading: "Welcome back" ---
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: Color(0xFF111827),
                              fontFamily: 'Poppins',
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // --- Subtitle: "Sign in to your workspace to continue." ---
                          const Text(
                            'Sign in to your workspace to continue.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: _mutedColor,
                              fontFamily: 'Poppins',
                            ),
                          ),

                          // Error Banner if needed
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0x15DC2626),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDC2626), width: 1.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    size: 16,
                                    color: Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFDC2626),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 26),

                          // --- Field 1: Work email ---
                          const Text(
                            'Work email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _labelColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: _fieldBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: (_emailFocus?.hasFocus ?? false) ? _brandColor : _fieldBorder,
                                width: (_emailFocus?.hasFocus ?? false) ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEA580C).withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.mail,
                                  size: 19,
                                  color: _mutedColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    focusNode: _effectiveEmailFocus,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    cursorColor: _brandColor,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF111827),
                                      fontFamily: 'Poppins',
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'you@company.com',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF9CA3AF),
                                        fontFamily: 'Poppins',
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      filled: false,
                                      fillColor: Colors.transparent,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_isEmailValid)
                                  const Icon(
                                    CupertinoIcons.checkmark,
                                    size: 18,
                                    color: Color(0xFF16A34A),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --- Field 2: Password ---
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _labelColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: _fieldBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: (_passwordFocus?.hasFocus ?? false) ? _brandColor : _fieldBorder,
                                width: (_passwordFocus?.hasFocus ?? false) ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEA580C).withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.lock,
                                  size: 19,
                                  color: _mutedColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    focusNode: _effectivePasswordFocus,
                                    controller: _passwordController,
                                    obscureText: !_showPassword,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _handleLogin(),
                                    cursorColor: _brandColor,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF111827),
                                      fontFamily: 'Poppins',
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '••••••••••',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF9CA3AF),
                                        letterSpacing: 2.0,
                                        fontFamily: 'Poppins',
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      filled: false,
                                      fillColor: Colors.transparent,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  icon: Icon(
                                    _showPassword
                                        ? CupertinoIcons.eye_slash
                                        : CupertinoIcons.eye,
                                    size: 20,
                                    color: _mutedColor,
                                  ),
                                  onPressed: () {
                                    setState(() => _showPassword = !_showPassword);
                                  },
                                ),
                              ],
                            ),
                          ),

                          // --- Forgot password? (Right aligned in #EA580C) ---
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: Container(
                                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _brandColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // --- "Sign in →" Button with rich orange gradient ---
                          GestureDetector(
                            onTap: _isLoading ? null : _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _btnGradientStart,
                                    _btnGradientEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _btnGradientEnd.withValues(alpha: 0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const CupertinoActivityIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'Sign in',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          CupertinoIcons.arrow_right,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // --- Demo: Sarah (Staff) / Marcus (Admin) Switcher ---
                          Center(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  'Demo:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _mutedColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _fillDemoUser(UserRole.employee),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: _fieldBorder, width: 1.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          CupertinoIcons.person,
                                          size: 15,
                                          color: Color(0xFF374151),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Sarah (Staff)',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF374151),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _fillDemoUser(UserRole.admin),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: _fieldBorder, width: 1.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          CupertinoIcons.shield,
                                          size: 15,
                                          color: Color(0xFF374151),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Marcus (Admin)',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF374151),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- Copyright footer: "© 2026 Essane Global" ---
                          const Center(
                            child: Text(
                              '© 2026 Essane Global',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _mutedColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// Custom painter for the warm fluid organic waves/ribbons matching the screenshot background
class _FluidRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Top-right sweeping amber/orange organic ribbon
    final path1 = Path()
      ..moveTo(w * 0.45, 0)
      ..cubicTo(w * 0.70, h * 0.05, w * 0.95, h * 0.15, w, h * 0.35)
      ..lineTo(w, 0)
      ..close();

    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFA05C).withValues(alpha: 0.45),
          const Color(0xFFEA580C).withValues(alpha: 0.25),
          const Color(0xFFFFEDD5).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.45));
    canvas.drawPath(path1, paint1);

    // 2. Second overlapping ribbon in top-right
    final path2 = Path()
      ..moveTo(w * 0.65, 0)
      ..cubicTo(w * 0.85, h * 0.10, w * 0.98, h * 0.22, w, h * 0.45)
      ..lineTo(w, 0)
      ..close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.centerLeft,
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.35),
          const Color(0xFFFB923C).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.5));
    canvas.drawPath(path2, paint2);

    // 3. Subtle curved wave edge line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.6),
          const Color(0xFFFB923C).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.4));

    final pathLine = Path()
      ..moveTo(w * 0.50, 0)
      ..cubicTo(w * 0.72, h * 0.08, w * 0.92, h * 0.18, w, h * 0.38);
    canvas.drawPath(pathLine, linePaint);

    // 4. Bottom-left warm wave swoosh
    final path3 = Path()
      ..moveTo(0, h * 0.65)
      ..cubicTo(w * 0.20, h * 0.75, w * 0.35, h * 0.88, w * 0.40, h)
      ..lineTo(0, h)
      ..close();

    final paint3 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.35),
          const Color(0xFFFB923C).withValues(alpha: 0.18),
          const Color(0xFFFFEDD5).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.6, w * 0.5, h * 0.4));
    canvas.drawPath(path3, paint3);

    // 5. Subtle bottom-left wave edge line
    final pathLine2 = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.22, h * 0.78, w * 0.32, h * 0.89, w * 0.38, h);
    canvas.drawPath(pathLine2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Geometric SVG Mark Custom Painter matching login SVG geometry:
/// ViewBox: (10, 0, 160, 300)
/// - Rect 1: x="116" y="5" width="46" height="110" rx="2"
/// - Rect 2: x="116" y="195" width="46" height="100" rx="2"
/// - Line 1: line x1="20" y1="80" x2="104" y2="128" stroke-width="46"
/// - Line 2: line x1="20" y1="230" x2="104" y2="182" stroke-width="46"
class _EssaneMarkPainter extends CustomPainter {
  final Color color;

  const _EssaneMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

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

    // 3. Line 1: line x1="20" y1="80" x2="104" y2="128"
    canvas.drawLine(const Offset(20, 80), const Offset(104, 128), strokePaint);

    // 4. Line 2: line x1="20" y1="230" x2="104" y2="182"
    canvas.drawLine(const Offset(20, 230), const Offset(104, 182), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EssaneMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
