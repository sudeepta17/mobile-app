import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../state/auth_state.dart';
import '../../state/theme_state.dart';

/// Profile & Settings Screen mirroring profile.html & styles.css
class ProfileScreen extends StatelessWidget {
  final AuthState authState;
  final ThemeState themeState;

  const ProfileScreen({
    super.key,
    required this.authState,
    required this.themeState,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'EN';
  }

  void _showChangePasswordDialog(
    BuildContext context,
    Color bg,
    Color cardBg,
    Color borderCol2,
    Color textPrimary,
    Color textSoft,
    Color accent,
  ) {
    HapticFeedback.lightImpact();
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();

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
                    'Change password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current password',
                    style: TextStyle(fontSize: 13, color: textSoft, fontFamily: 'Poppins'),
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
                      controller: currentPwController,
                      obscureText: true,
                      style: TextStyle(fontSize: 15, color: textPrimary, fontFamily: 'Poppins'),
                      cursorColor: accent,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Enter current password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'New password',
                    style: TextStyle(fontSize: 13, color: textSoft, fontFamily: 'Poppins'),
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
                      controller: newPwController,
                      obscureText: true,
                      style: TextStyle(fontSize: 15, color: textPrimary, fontFamily: 'Poppins'),
                      cursorColor: accent,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Enter new password',
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
                              const SnackBar(content: Text('Password updated successfully.')),
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
                              'Update',
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

  void _showHelpSupportDialog(
    BuildContext context,
    Color bg,
    Color borderCol2,
    Color textPrimary,
    Color textMuted,
    Color accent,
  ) {
    HapticFeedback.lightImpact();
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
                    'Help and support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Essane Global Support Desk is available 24/7 for workforce management and administrative inquiries.',
                    style: TextStyle(fontSize: 13, color: textMuted, height: 1.4, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Email: support@essane.com\nTelegram: @essane_support\nPortal: help.essane.com',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                      height: 1.6,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
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

  void _confirmSignOut(BuildContext context, Color bg, Color borderCol2, Color textPrimary, Color textMuted, Color red) {
    HapticFeedback.lightImpact();
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
                    'Sign out',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to sign out of your workspace?',
                    style: TextStyle(fontSize: 13, color: textMuted, fontFamily: 'Poppins'),
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
                              border: Border.all(color: borderCol2, width: 1.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop();
                            await authState.logout();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: red,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Sign out',
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
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final borderCol2 = isDark ? AppColors.darkLine2 : AppColors.lightLine2;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final textSoft = isDark ? AppColors.darkSoft : AppColors.lightSoft;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final accentGlow = isDark ? AppColors.darkAccentGlow : AppColors.lightAccentSoft;
    final red = isDark ? AppColors.red : const Color(0xFFC62828);
    final chipOff = isDark ? AppColors.darkChipOff : AppColors.lightChipOff;

    final user = authState.currentUser;
    final userName = user?.name ?? 'Sarah Jenkins';
    final userInitials = _getInitials(userName);
    final userDesignation = user?.designation ?? 'Senior Fullstack Engineer';
    final userDepartment = user?.department ?? 'Engineering';
    final employeeId = user?.employeeCode ?? 'EMP-0142';
    final userEmail = user?.email ?? 'sarah.jenkins@essane.com';
    final userPhone = user?.mobile ?? '+91 98765 43210';
    final userJoined = user?.joiningDate ?? '15 Mar 2023';

    final isWhiteTheme = !isDark;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Top Ambient Glow (.glow in profile.html line 14: radial-gradient(circle at 85% 0, var(--accent-glow) 0%, transparent 65%))
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

          // Main Page Content (.app > .page in profile.html line 15)
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 104),
              children: [
                // 1. Header (profile.html line 16: <header class="col" style="align-items:center;gap:4px">)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar lg (styles.css: .avatar.lg: 76x76, font-size 26px, border 1px solid var(--accent))
                    Container(
                      width: 76,
                      height: 76,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentSoft,
                        border: Border.all(color: accent, width: 1.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userInitials,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: accent,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                    // Employee Name (<h1 style="font-size:20px;line-height:1.3">Employee Name</h1>)
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        height: 1.3,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),

                    // Designation · Department (<p class="sub">Designation · Department</p>)
                    Text(
                      '$userDesignation · $userDepartment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Details Section (profile.html line 22: <section class="card rows" aria-label="Details">)
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      // Employee ID
                      _ProfileRow(
                        label: 'Employee ID',
                        value: employeeId,
                        borderCol: borderCol,
                        textMuted: textMuted,
                        textPrimary: textPrimary,
                        isLast: false,
                      ),
                      // Email
                      _ProfileRow(
                        label: 'Email',
                        value: userEmail,
                        borderCol: borderCol,
                        textMuted: textMuted,
                        textPrimary: textPrimary,
                        isLast: false,
                      ),
                      // Phone
                      _ProfileRow(
                        label: 'Phone',
                        value: userPhone,
                        borderCol: borderCol,
                        textMuted: textMuted,
                        textPrimary: textPrimary,
                        isLast: false,
                      ),
                      // Joined
                      _ProfileRow(
                        label: 'Joined',
                        value: userJoined,
                        borderCol: borderCol,
                        textMuted: textMuted,
                        textPrimary: textPrimary,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Settings Section (profile.html line 29: <section class="card rows" aria-label="Settings">)
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      // White theme with custom .switch (styles.css: .switch: 46x28px)
                      Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: borderCol, width: 1.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'White theme',
                              style: TextStyle(
                                fontSize: 14,
                                color: textPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            // CSS-matched .switch widget
                            _CssSwitch(
                              value: isWhiteTheme,
                              accentColor: accent,
                              chipOffColor: chipOff,
                              line2Color: borderCol2,
                              mutedColor: textMuted,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                themeState.toggleTheme(context);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Notifications link (<a href="notifications.html"><span>Notifications</span><i data-icon="chevron"></i></a>)
                      _NavigationRow(
                        label: 'Notifications',
                        borderCol: borderCol,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isLast: false,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(context, AppRoutes.notifications);
                        },
                      ),

                      // Change password link
                      _NavigationRow(
                        label: 'Change password',
                        borderCol: borderCol,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isLast: false,
                        onTap: () => _showChangePasswordDialog(
                          context,
                          bg,
                          cardBg,
                          borderCol2,
                          textPrimary,
                          textSoft,
                          accent,
                        ),
                      ),

                      // Help and support link
                      _NavigationRow(
                        label: 'Help and support',
                        borderCol: borderCol,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isLast: true,
                        onTap: () => _showHelpSupportDialog(
                          context,
                          bg,
                          borderCol2,
                          textPrimary,
                          textMuted,
                          accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Sign out button (profile.html line 36: <a class="btn danger" href="login.html">Sign out</a>)
                GestureDetector(
                  onTap: () => _confirmSignOut(context, bg, borderCol2, textPrimary, textMuted, red),
                  child: Container(
                    width: double.infinity,
                    height: 50, // styles.css: .btn.danger { min-height: 50px; font-size: 15px; border: 1.5px solid var(--red); }
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: red, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: red,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Subtle Testing Role Switcher & Splash Replay
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          authState.switchDemoRole(
                            user?.role == UserRole.admin ? UserRole.employee : UserRole.admin,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: borderCol2, width: 0.8),
                          ),
                          child: Text(
                            'Switch Role (${user?.role == UserRole.admin ? "Admin" : "Staff"})',
                            style: TextStyle(fontSize: 11, color: textSoft, fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pushNamed(context, AppRoutes.splash);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: borderCol2, width: 0.8),
                          ),
                          child: Text(
                            'Replay Splash',
                            style: TextStyle(fontSize: 11, color: textSoft, fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Details Row (.rows > div in profile.html line 23)
class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final Color borderCol;
  final Color textMuted;
  final Color textPrimary;
  final bool isLast;

  const _ProfileRow({
    required this.label,
    required this.value,
    required this.borderCol,
    required this.textMuted,
    required this.textPrimary,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: borderCol, width: 1.0),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // .k (font-size: 13px, color: var(--muted))
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textMuted,
              fontFamily: 'Poppins',
            ),
          ),
          // .v (font-size: 13px, font-weight: 500)
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation Row with Chevron (.rows > a in profile.html line 31)
class _NavigationRow extends StatelessWidget {
  final String label;
  final Color borderCol;
  final Color textPrimary;
  final Color textMuted;
  final bool isLast;
  final VoidCallback onTap;

  const _NavigationRow({
    required this.label,
    required this.borderCol,
    required this.textPrimary,
    required this.textMuted,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: borderCol, width: 1.0),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            // Chevron icon: data-icon="chevron"
            Icon(
              CupertinoIcons.chevron_right,
              size: 15,
              color: textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Exact CSS-replica switch (.switch in styles.css lines 81-84):
/// .switch{width:46px;height:28px;border-radius:14px;background:var(--chip-off);border:1px solid var(--line2);position:relative;padding:0;flex:0 0 auto;min-height:0}
/// .switch::after{content:"";position:absolute;top:3px;left:3px;width:20px;height:20px;border-radius:50%;background:var(--muted);transition:transform .2s}
/// .switch[aria-checked="true"]{background:var(--accent);border-color:var(--accent)}
/// .switch[aria-checked="true"]::after{transform:translateX(18px);background:var(--on-accent)}
class _CssSwitch extends StatelessWidget {
  final bool value;
  final Color accentColor;
  final Color chipOffColor;
  final Color line2Color;
  final Color mutedColor;
  final ValueChanged<bool> onChanged;

  const _CssSwitch({
    required this.value,
    required this.accentColor,
    required this.chipOffColor,
    required this.line2Color,
    required this.mutedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? accentColor : chipOffColor,
          border: Border.all(
            color: value ? accentColor : line2Color,
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              top: 3,
              left: value ? 21 : 3,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? Colors.white : mutedColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
