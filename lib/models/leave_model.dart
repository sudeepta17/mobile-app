class LeaveTypeModel {
  final int id;
  final String name;
  final String code;
  final int allowed;
  final int used;
  final int pending;
  final int remaining;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.allowed,
    required this.used,
    required this.pending,
    required this.remaining,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      allowed: (json['allowed'] as num?)?.toInt() ?? 0,
      used: (json['used'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaveHistoryItem {
  final int id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final int days;
  final String reason;
  final String status; // pending, approved, rejected
  final String appliedOn;
  final String? reviewerComment;

  const LeaveHistoryItem({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.appliedOn,
    this.reviewerComment,
  });

  factory LeaveHistoryItem.fromJson(Map<String, dynamic> json) {
    return LeaveHistoryItem(
      id: json['id'] as int,
      leaveType: json['leave_type'] as String? ?? 'Leave',
      fromDate: json['from_date'] as String? ?? '',
      toDate: json['to_date'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 1,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      appliedOn: json['applied_on'] as String? ?? '',
      reviewerComment: json['reviewer_comment'] as String?,
    );
  }
}

class LeaveDataBundle {
  final int totalAllowed;
  final int taken;
  final int pending;
  final int remaining;
  final List<LeaveTypeModel> types;
  final List<LeaveHistoryItem> history;

  const LeaveDataBundle({
    required this.totalAllowed,
    required this.taken,
    required this.pending,
    required this.remaining,
    required this.types,
    required this.history,
  });

  factory LeaveDataBundle.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final rawTypes = json['types'] as List<dynamic>? ?? [];
    final rawHistory = json['history'] as List<dynamic>? ?? [];

    return LeaveDataBundle(
      totalAllowed: (summary['total_allowed'] as num?)?.toInt() ?? 0,
      taken: (summary['taken'] as num?)?.toInt() ?? 0,
      pending: (summary['pending'] as num?)?.toInt() ?? 0,
      remaining: (summary['remaining'] as num?)?.toInt() ?? 0,
      types: rawTypes.map((e) => LeaveTypeModel.fromJson(e as Map<String, dynamic>)).toList(),
      history: rawHistory.map((e) => LeaveHistoryItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

