import 'package:flutter/material.dart';

/// App Background displaying the exact fluid orange ribbon wallpaper
/// from media_1793781287342_d0740728.jpg:
/// - Flowing fluid orange wave arcs at top-right and bottom-left
/// - Clean warm light base in light mode
/// - Deep charcoal in dark mode
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool? isDarkMode;

  const AppBackground({
    super.key,
    required this.child,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode ?? (Theme.of(context).brightness == Brightness.dark);

    if (dark) {
      return ColoredBox(
        color: const Color(0xFF121417),
        child: child,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base warm off-white surface
        const ColoredBox(color: Color(0xFFFFF7F0)),

        // Exact fluid ribbon wallpaper asset
        Positioned.fill(
          child: Image.asset(
            'assets/images/app_background.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),

        // Foreground content
        child,
      ],
    );
  }
}
