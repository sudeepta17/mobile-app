/// Shift status mirroring EmployeeShiftService.php & AttendanceShiftReports.tsx
enum ShiftStatus {
  active,
  onBreak,
  powerOut,
  completed,
}

extension ShiftStatusExtension on ShiftStatus {
  String get value {
    switch (this) {
      case ShiftStatus.active:
        return 'active';
      case ShiftStatus.onBreak:
        return 'on_break';
      case ShiftStatus.powerOut:
        return 'power_out';
      case ShiftStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case ShiftStatus.active:
        return 'WORKING';
      case ShiftStatus.onBreak:
        return 'ON BREAK';
      case ShiftStatus.powerOut:
        return 'POWER CUT';
      case ShiftStatus.completed:
        return 'OFF THE CLOCK';
    }
  }

  static ShiftStatus fromString(String? val) {
    switch (val) {
      case 'active':
        return ShiftStatus.active;
      case 'on_break':
        return ShiftStatus.onBreak;
      case 'power_out':
        return ShiftStatus.powerOut;
      case 'completed':
      default:
        return ShiftStatus.completed;
    }
  }
}

/// Break log entry
class ShiftBreakItem {
  final int id;
  final DateTime startTime;
  DateTime? endTime;
  int durationMinutes;
  bool isActive;

  ShiftBreakItem({
    required this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.isActive = false,
  });

  factory ShiftBreakItem.fromJson(Map<String, dynamic> json) {
    return ShiftBreakItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      startTime: DateTime.tryParse(json['break_start_at'] ?? '') ?? DateTime.now(),
      endTime: json['break_end_at'] != null ? DateTime.tryParse(json['break_end_at']) : null,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'break_start_at': startTime.toIso8601String(),
    'break_end_at': endTime?.toIso8601String(),
    'duration_minutes': durationMinutes,
    'is_active': isActive,
  };
}

/// Power outage log entry
class ShiftOutageItem {
  final int id;
  final int incidentNumber;
  final DateTime powerOffAt;
  DateTime? powerBackAt;
  int durationMinutes;
  bool isActive;

  ShiftOutageItem({
    required this.id,
    required this.incidentNumber,
    required this.powerOffAt,
    this.powerBackAt,
    this.durationMinutes = 0,
    this.isActive = false,
  });

  factory ShiftOutageItem.fromJson(Map<String, dynamic> json) {
    return ShiftOutageItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      incidentNumber: (json['incident_number'] as num?)?.toInt() ?? 1,
      powerOffAt: DateTime.tryParse(json['power_off_at_iso'] ?? '') ?? DateTime.now(),
      powerBackAt: json['power_back_at_iso'] != null ? DateTime.tryParse(json['power_back_at_iso']) : null,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'incident_number': incidentNumber,
    'power_off_at_iso': powerOffAt.toIso8601String(),
    'power_back_at_iso': powerBackAt?.toIso8601String(),
    'duration_minutes': durationMinutes,
    'is_active': isActive,
  };
}

/// Live shift record matching EmployeeShiftController.php & AttendanceShiftReports.tsx
class EmployeeShiftRecord {
  final int id;
  final int userId;
  final String employeeName;
  final String employeeCode;
  final DateTime shiftDate;
  final DateTime loginAt;
  DateTime? logoutAt;
  final DateTime scheduledStartAt;
  final DateTime scheduledEndAt;
  ShiftStatus status;
  int elapsedMinutes;
  int delayMinutes; // late minutes past 11:00 AM IST
  int totalBreakMinutes;
  int totalOutageMinutes;
  int regularMinutes;
  int overtimeMinutes;
  List<ShiftBreakItem> breaks;
  List<ShiftOutageItem> outages;
  DateTime? lastActionAt;
  String? lastActionName;

  EmployeeShiftRecord({
    required this.id,
    required this.userId,
    required this.employeeName,
    required this.employeeCode,
    required this.shiftDate,
    required this.loginAt,
    this.logoutAt,
    required this.scheduledStartAt,
    required this.scheduledEndAt,
    required this.status,
    this.elapsedMinutes = 0,
    this.delayMinutes = 0,
    this.totalBreakMinutes = 0,
    this.totalOutageMinutes = 0,
    this.regularMinutes = 0,
    this.overtimeMinutes = 0,
    required this.breaks,
    required this.outages,
    this.lastActionAt,
    this.lastActionName,
  });

  /// Check if an undo window of 2 minutes is active
  bool get canUndo {
    if (lastActionAt == null) return false;
    final diff = DateTime.now().difference(lastActionAt!).inSeconds;
    return diff <= 120;
  }

  /// Break currently running
  ShiftBreakItem? get currentBreak {
    for (final b in breaks) {
      if (b.isActive) return b;
    }
    return null;
  }

  /// Outage currently running
  ShiftOutageItem? get currentOutage {
    for (final o in outages) {
      if (o.isActive) return o;
    }
    return null;
  }
}
