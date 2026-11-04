import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../app_header_back_button.dart';

class AppleScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool useSliver;
  final Widget? bottomBar;

  const AppleScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.useSliver = false,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (!useSliver) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg.withValues(alpha: 0.9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Navigator.canPop(context)
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    color: AppColors.primaryOrange,
                    size: 26,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headline.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.caption1.copyWith(color: textSecondary),
                ),
            ],
          ),
          actions: actions ??
              (Navigator.canPop(context)
                  ? const [
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: AppHeaderBackButton(),
                      ),
                    ]
                  : null),
        ),
        body: SafeArea(
          bottom: bottomBar == null,
          child: body,
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomBar,
      );
    }

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        bottom: bottomBar == null,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 110.0,
              backgroundColor: bg.withValues(alpha: 0.88),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: Navigator.canPop(context)
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        color: AppColors.primaryOrange,
                        size: 26,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: AppDimens.p16,
                  bottom: AppDimens.p12,
                ),
                title: Text(
                  title,
                  style: AppTypography.title2.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              actions: actions ??
              (Navigator.canPop(context)
                  ? const [
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: AppHeaderBackButton(),
                      ),
                    ]
                  : null),
            ),
            SliverToBoxAdapter(child: body),
          ],
        ),
      ),
    );
  }
}
