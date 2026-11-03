class TodayAttendance {
  final String date;
  final bool isCheckedIn;
  final String? checkInTime;
  final String? checkOutTime;
  final String shift;
  final String workedHours;
  final String status;
  final bool gymCheckedIn;
  final String? gymCheckInTime;
  final int gymStreak;

  const TodayAttendance({
    required this.date,
    required this.isCheckedIn,
    this.checkInTime,
    this.checkOutTime,
    required this.shift,
    required this.workedHours,
    required this.status,
    required this.gymCheckedIn,
    this.gymCheckInTime,
    required this.gymStreak,
  });

  TodayAttendance copyWith({
    bool? isCheckedIn,
    String? checkInTime,
    String? checkOutTime,
    bool? gymCheckedIn,
    String? gymCheckInTime,
    int? gymStreak,
  }) {
    return TodayAttendance(
      date: date,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      shift: shift,
      workedHours: workedHours,
      status: status,
      gymCheckedIn: gymCheckedIn ?? this.gymCheckedIn,
      gymCheckInTime: gymCheckInTime ?? this.gymCheckInTime,
      gymStreak: gymStreak ?? this.gymStreak,
    );
  }

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      date: json['date'] as String? ?? '',
      isCheckedIn: json['is_checked_in'] as bool? ?? false,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      shift: json['shift'] as String? ?? 'Standard Shift',
      workedHours: json['worked_hours'] as String? ?? '0h 00m',
      status: json['status'] as String? ?? 'on_time',
      gymCheckedIn: json['gym_checked_in'] as bool? ?? false,
      gymCheckInTime: json['gym_check_in_time'] as String?,
      gymStreak: (json['gym_streak'] as num?)?.toInt() ?? 0,
    );
  }
}

class AttendanceLog {
  final String date;
  final String day;
  final String checkIn;
  final String checkOut;
  final String hours;
  final String status;
  final bool gym;

  const AttendanceLog({
    required this.date,
    required this.day,
    required this.checkIn,
    required this.checkOut,
    required this.hours,
    required this.status,
    required this.gym,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      date: json['date'] as String? ?? '',
      day: json['day'] as String? ?? '',
      checkIn: json['check_in'] as String? ?? '--:--',
      checkOut: json['check_out'] as String? ?? '--:--',
      hours: json['hours'] as String? ?? '0h',
      status: json['status'] as String? ?? 'present',
      gym: json['gym'] as bool? ?? false,
    );
  }
}

class AttendanceDataBundle {
  final TodayAttendance today;
  final int workingDays;
  final int presentDays;
  final int leavesTaken;
  final int lateArrivals;
  final String overtimeHours;
  final int gymVisitsMonth;
  final List<AttendanceLog> recentLogs;

  const AttendanceDataBundle({
    required this.today,
    required this.workingDays,
    required this.presentDays,
    required this.leavesTaken,
    required this.lateArrivals,
    required this.overtimeHours,
    required this.gymVisitsMonth,
    required this.recentLogs,
  });

  factory AttendanceDataBundle.fromJson(Map<String, dynamic> json) {
    final rawToday = json['today'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final logs = json['recent_logs'] as List<dynamic>? ?? [];

    return AttendanceDataBundle(
      today: TodayAttendance.fromJson(rawToday),
      workingDays: (stats['working_days'] as num?)?.toInt() ?? 0,
      presentDays: (stats['present_days'] as num?)?.toInt() ?? 0,
      leavesTaken: (stats['leaves_taken'] as num?)?.toInt() ?? 0,
      lateArrivals: (stats['late_arrivals'] as num?)?.toInt() ?? 0,
      overtimeHours: stats['overtime_hours'] as String? ?? '0 hrs',
      gymVisitsMonth: (stats['gym_visits_month'] as num?)?.toInt() ?? 0,
      recentLogs: logs.map((e) => AttendanceLog.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

