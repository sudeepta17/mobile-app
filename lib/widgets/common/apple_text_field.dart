import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';

class AppleTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AppleTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  State<AppleTextField> createState() => _AppleTextFieldState();
}

class _AppleTextFieldState extends State<AppleTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final surfaceSec = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.footnote.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.p6),
        ],
        Container(
          decoration: BoxDecoration(
            color: surfaceSec,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: widget.errorText != null ? AppColors.error : borderCol,
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: _obscure,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            style: AppTypography.body.copyWith(color: textPrimary),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.placeholder,
              hintStyle: AppTypography.callout.copyWith(color: textTertiary),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, size: 20, color: textTertiary)
                  : null,
              suffixIcon: widget.obscureText
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        size: 20,
                        color: textTertiary,
                      ),
                    )
                  : widget.suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTypography.caption1.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

