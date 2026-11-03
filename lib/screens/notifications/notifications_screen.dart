import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Notification item data model
class NotificationItemData {
  final String id;
  final IconData icon;
  final String title;
  final String message;
  final String time;
  bool isUnread;

  NotificationItemData({
    required this.id,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  });
}

/// Notifications Screen mirroring notifications.html & styles.css
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Notifications array matching notifications.html lines 27-31
  late final List<NotificationItemData> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      NotificationItemData(
        id: '1',
        icon: CupertinoIcons.calendar, // data-icon="leave"
        title: 'Leave request approved',
        message: 'Your casual leave for 20 – 21 Oct was approved.',
        time: '2 hours ago',
        isUnread: true,
      ),
      NotificationItemData(
        id: '2',
        icon: CupertinoIcons.checkmark_square, // data-icon="tasks"
        title: 'New task assigned',
        message: 'Review project brief has been assigned to you.',
        time: '5 hours ago',
        isUnread: true,
      ),
      NotificationItemData(
        id: '3',
        icon: CupertinoIcons.clock, // data-icon="clock"
        title: 'Timesheet reminder',
        message: 'Submit your weekly timesheet before 5:00 PM today.',
        time: 'Yesterday',
        isUnread: false,
      ),
      NotificationItemData(
        id: '4',
        icon: CupertinoIcons.checkmark_square, // data-icon="tasks"
        title: 'Task completed',
        message: 'Attend onboarding session was marked as done.',
        time: 'Yesterday',
        isUnread: false,
      ),
      NotificationItemData(
        id: '5',
        icon: CupertinoIcons.calendar, // data-icon="leave"
        title: 'Leave request rejected',
        message: 'Your earned leave for 1 – 3 Sep was not approved.',
        time: '2 days ago',
        isUnread: false,
      ),
    ];
  }

  void _markAsRead(int index) {
    if (_items[index].isUnread) {
      HapticFeedback.selectionClick();
      setState(() {
        _items[index].isUnread = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final accentGlow = isDark ? AppColors.darkAccentGlow : AppColors.lightAccentSoft;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Top Ambient Glow: radial-gradient(circle at 85% 0, var(--accent-glow) 0%, transparent 65%)
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

          // Main App Area (.app in notifications.html: style="padding-bottom:40px")
          SafeArea(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 40),
              children: [
                // Header (notifications.html line 22: <header class="row" style="gap:4px;margin-left:-8px">)
                Row(
                  children: [
                    // Back button (<a class="icon-btn" href="dashboard.html" ... style="border:0;background:none">)
                    IconButton(
                      icon: const Icon(CupertinoIcons.chevron_back, size: 22),
                      color: textPrimary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      alignment: Alignment.centerLeft,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        height: 1.2,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Notifications List (.list in notifications.html line 26)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return GestureDetector(
                      onTap: () => _markAsRead(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderCol, width: 1.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // .ico (notifications.html line 12: 38x38, radius 12, var(--accent-soft))
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: accentSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Icon(item.icon, size: 18, color: accent),
                            ),
                            const SizedBox(width: 12),

                            // .grow (.t, .m, .time)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // .t (font-size: 14px, font-weight: 500, line-height: 1.35)
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                      height: 1.35,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // .m (font-size: 12px, line-height: 1.4, color: var(--muted))
                                  Text(
                                    item.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: textMuted,
                                      height: 1.4,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // .time (font-size: 11px, color: var(--muted), margin-top: 4px)
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: textMuted,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // .dot (width: 9px, height: 9px, border-radius: 50%, background: var(--accent), margin-top: 6px)
                            if (item.isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
