class DashboardSummaryModel {
  final DashboardProfile profile;
  final DashboardRequests requests;
  final DashboardLeave leave;
  final DashboardAllowance allowance;
  final DashboardAdvance advance;
  final DashboardGym gym;
  final DashboardHoliday? nextHoliday;
  final DashboardBlockers blockers;
  final List<DashboardActivityItem> recentActivity;

  const DashboardSummaryModel({
    required this.profile,
    required this.requests,
    required this.leave,
    required this.allowance,
    required this.advance,
    required this.gym,
    this.nextHoliday,
    required this.blockers,
    required this.recentActivity,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      profile: DashboardProfile.fromJson(json['profile'] as Map<String, dynamic>? ?? {}),
      requests: DashboardRequests.fromJson(json['requests'] as Map<String, dynamic>? ?? {}),
      leave: DashboardLeave.fromJson(json['leave'] as Map<String, dynamic>? ?? {}),
      allowance: DashboardAllowance.fromJson(json['allowance'] as Map<String, dynamic>? ?? {}),
      advance: DashboardAdvance.fromJson(json['advance'] as Map<String, dynamic>? ?? {}),
      gym: DashboardGym.fromJson(json['gym'] as Map<String, dynamic>? ?? {}),
      nextHoliday: json['next_holiday'] != null
          ? DashboardHoliday.fromJson(json['next_holiday'] as Map<String, dynamic>)
          : null,
      blockers: DashboardBlockers.fromJson(json['blockers'] as Map<String, dynamic>? ?? {}),
      recentActivity: (json['recent_activity'] as List<dynamic>? ?? [])
          .map((e) => DashboardActivityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardProfile {
  final int id;
  final String name;
  final String? employeeCode;
  final String? joiningDate;
  final String? githubUsername;

  const DashboardProfile({
    required this.id,
    required this.name,
    this.employeeCode,
    this.joiningDate,
    this.githubUsername,
  });

  factory DashboardProfile.fromJson(Map<String, dynamic> json) {
    return DashboardProfile(
      id: json['id'] as int? ?? 1,
      name: json['name'] as String? ?? 'Sarah Jenkins',
      employeeCode: json['employee_code'] as String? ?? 'ESS-0142',
      joiningDate: json['joining_date'] as String?,
      githubUsername: json['github_username'] as String?,
    );
  }
}

class DashboardRequests {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  const DashboardRequests({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory DashboardRequests.fromJson(Map<String, dynamic> json) {
    return DashboardRequests(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      approved: json['approved'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
    );
  }
}

class DashboardLeave {
  final int approvedDays;
  final int pendingDays;
  final List<DashboardLeaveTypeItem> byType;

  const DashboardLeave({
    required this.approvedDays,
    required this.pendingDays,
    required this.byType,
  });

  factory DashboardLeave.fromJson(Map<String, dynamic> json) {
    return DashboardLeave(
      approvedDays: json['approved_days'] as int? ?? 0,
      pendingDays: json['pending_days'] as int? ?? 0,
      byType: (json['by_type'] as List<dynamic>? ?? [])
          .map((e) => DashboardLeaveTypeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardLeaveTypeItem {
  final int id;
  final String name;
  final int daysAllowed;
  final int usedDays;
  final int pendingDays;
  final int? remainingDays;

  const DashboardLeaveTypeItem({
    required this.id,
    required this.name,
    required this.daysAllowed,
    required this.usedDays,
    required this.pendingDays,
    this.remainingDays,
  });

  factory DashboardLeaveTypeItem.fromJson(Map<String, dynamic> json) {
    return DashboardLeaveTypeItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      daysAllowed: json['days_allowed'] as int? ?? 0,
      usedDays: json['used_days'] as int? ?? 0,
      pendingDays: json['pending_days'] as int? ?? 0,
      remainingDays: json['remaining_days'] as int?,
    );
  }
}

class DashboardAllowance {
  final double submittedAmount;
  final double approvedAmount;
  final double pendingAmount;

  const DashboardAllowance({
    required this.submittedAmount,
    required this.approvedAmount,
    required this.pendingAmount,
  });

  factory DashboardAllowance.fromJson(Map<String, dynamic> json) {
    return DashboardAllowance(
      submittedAmount: (json['submitted_amount'] as num?)?.toDouble() ?? 0.0,
      approvedAmount: (json['approved_amount'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardAdvance {
  final double approvedAmount;
  final double pendingAmount;
  final double outstandingBalance;

  const DashboardAdvance({
    required this.approvedAmount,
    required this.pendingAmount,
    required this.outstandingBalance,
  });

  factory DashboardAdvance.fromJson(Map<String, dynamic> json) {
    return DashboardAdvance(
      approvedAmount: (json['approved_amount'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance: (json['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardGym {
  final int yearCount;
  final int monthCount;
  final int currentStreak;
  final String? lastCheckIn;

  const DashboardGym({
    required this.yearCount,
    required this.monthCount,
    required this.currentStreak,
    this.lastCheckIn,
  });

  factory DashboardGym.fromJson(Map<String, dynamic> json) {
    return DashboardGym(
      yearCount: json['year_count'] as int? ?? 0,
      monthCount: json['month_count'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      lastCheckIn: json['last_check_in'] as String?,
    );
  }
}

class DashboardHoliday {
  final String name;
  final String date;
  final int daysRemaining;

  const DashboardHoliday({
    required this.name,
    required this.date,
    required this.daysRemaining,
  });

  factory DashboardHoliday.fromJson(Map<String, dynamic> json) {
    return DashboardHoliday(
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      daysRemaining: json['days_remaining'] as int? ?? 0,
    );
  }
}

class DashboardBlockers {
  final int pendingCount;
  final int repliedCount;
  final int createdCount;

  const DashboardBlockers({
    required this.pendingCount,
    required this.repliedCount,
    required this.createdCount,
  });

  factory DashboardBlockers.fromJson(Map<String, dynamic> json) {
    return DashboardBlockers(
      pendingCount: json['pending_count'] as int? ?? 0,
      repliedCount: json['replied_count'] as int? ?? 0,
      createdCount: json['created_count'] as int? ?? 0,
    );
  }
}

class DashboardActivityItem {
  final String id;
  final String type; // 'leave' | 'allowance' | 'advance'
  final String title;
  final String message;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? date;

  const DashboardActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    this.date,
  });

  factory DashboardActivityItem.fromJson(Map<String, dynamic> json) {
    return DashboardActivityItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'leave',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      date: json['date'] as String?,
    );
  }
}

