import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/attendance_model.dart';
import '../interfaces/attendance_service_interface.dart';

class MockAttendanceService implements IAttendanceService {
  AttendanceDataBundle? _data;

  Future<void> _ensureLoaded() async {
    if (_data != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/attendance.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      _data = AttendanceDataBundle.fromJson(map);
    } catch (_) {
      _data = const AttendanceDataBundle(
        today: TodayAttendance(
          date: '2026-11-02',
          isCheckedIn: true,
          checkInTime: '09:28 AM',
          shift: 'Standard Shift',
          workedHours: '4h 12m',
          status: 'on_time',
          gymCheckedIn: true,
          gymStreak: 14,
        ),
        workingDays: 22,
        presentDays: 21,
        leavesTaken: 1,
        lateArrivals: 0,
        overtimeHours: '6.5 hrs',
        gymVisitsMonth: 18,
        recentLogs: [],
      );
    }
  }

  @override
  Future<AttendanceDataBundle> getAttendanceData() async {
    await _ensureLoaded();
    return _data!;
  }

  @override
  Future<TodayAttendance> punchAttendance() async {
    await _ensureLoaded();
    final current = _data!.today;
    final nowTime = '0${DateTime.now().hour % 12}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}';

    final updated = current.isCheckedIn
        ? current.copyWith(
            isCheckedIn: false,
            checkOutTime: nowTime,
          )
        : current.copyWith(
            isCheckedIn: true,
            checkInTime: nowTime,
            checkOutTime: null,
          );

    _data = AttendanceDataBundle(
      today: updated,
      workingDays: _data!.workingDays,
      presentDays: _data!.presentDays,
      leavesTaken: _data!.leavesTaken,
      lateArrivals: _data!.lateArrivals,
      overtimeHours: _data!.overtimeHours,
      gymVisitsMonth: _data!.gymVisitsMonth,
      recentLogs: _data!.recentLogs,
    );
    return updated;
  }

  @override
  Future<TodayAttendance> gymCheckIn() async {
    await _ensureLoaded();
    final current = _data!.today;
    final nowTime = '0${DateTime.now().hour % 12}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}';

    final updated = current.copyWith(
      gymCheckedIn: !current.gymCheckedIn,
      gymCheckInTime: !current.gymCheckedIn ? nowTime : null,
      gymStreak: !current.gymCheckedIn ? current.gymStreak + 1 : current.gymStreak - 1,
    );

    _data = AttendanceDataBundle(
      today: updated,
      workingDays: _data!.workingDays,
      presentDays: _data!.presentDays,
      leavesTaken: _data!.leavesTaken,
      lateArrivals: _data!.lateArrivals,
      overtimeHours: _data!.overtimeHours,
      gymVisitsMonth: updated.gymCheckedIn ? _data!.gymVisitsMonth + 1 : _data!.gymVisitsMonth,
      recentLogs: _data!.recentLogs,
    );
    return updated;
  }
}

