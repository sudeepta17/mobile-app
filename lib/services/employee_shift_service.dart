import 'dart:async';
import '../models/employee_shift_model.dart';

/// Shift Service Engine mirroring mmanagement EmployeeShiftService.php & EmployeeShiftController.php
class EmployeeShiftService {
  EmployeeShiftRecord? _activeShift;
  final List<EmployeeShiftRecord> _shiftHistory = [];

  EmployeeShiftService() {
    _seedDefaultHistory();
  }

  void _seedDefaultHistory() {
    final now = DateTime.now();

    // Default active shift for today: started at 10:55 AM
    final todayStart = DateTime(now.year, now.month, now.day, 10, 55);
    final scheduledStart = DateTime(now.year, now.month, now.day, 11, 0);
    final scheduledEnd = DateTime(now.year, now.month, now.day, 20, 0);

    _activeShift = EmployeeShiftRecord(
      id: 101,
      userId: 1,
      employeeName: 'Sarah Jenkins',
      employeeCode: 'ESS-0142',
      shiftDate: DateTime(now.year, now.month, now.day),
      loginAt: todayStart,
      scheduledStartAt: scheduledStart,
      scheduledEndAt: scheduledEnd,
      status: ShiftStatus.active,
      delayMinutes: 0,
      breaks: [
        ShiftBreakItem(
          id: 1,
          startTime: todayStart.add(const Duration(hours: 3)),
          endTime: todayStart.add(const Duration(hours: 3, minutes: 25)),
          durationMinutes: 25,
          isActive: false,
        ),
      ],
      outages: [],
      totalBreakMinutes: 25,
      lastActionAt: now.subtract(const Duration(minutes: 1)),
      lastActionName: 'login',
    );

    // Past 4 completed shifts
    for (int i = 1; i <= 4; i++) {
      final pastDate = now.subtract(Duration(days: i));
      final pastLogin = DateTime(pastDate.year, pastDate.month, pastDate.day, 11, 2);
      final pastLogout = DateTime(pastDate.year, pastDate.month, pastDate.day, 20, 15);
      _shiftHistory.add(
        EmployeeShiftRecord(
          id: 100 - i,
          userId: 1,
          employeeName: 'Sarah Jenkins',
          employeeCode: 'ESS-0142',
          shiftDate: DateTime(pastDate.year, pastDate.month, pastDate.day),
          loginAt: pastLogin,
          logoutAt: pastLogout,
          scheduledStartAt: DateTime(pastDate.year, pastDate.month, pastDate.day, 11, 0),
          scheduledEndAt: DateTime(pastDate.year, pastDate.month, pastDate.day, 20, 0),
          status: ShiftStatus.completed,
          delayMinutes: 2,
          totalBreakMinutes: 45,
          totalOutageMinutes: i == 2 ? 20 : 0,
          regularMinutes: 480,
          overtimeMinutes: 15,
          breaks: [
            ShiftBreakItem(
              id: i * 10,
              startTime: pastLogin.add(const Duration(hours: 3)),
              endTime: pastLogin.add(const Duration(hours: 3, minutes: 45)),
              durationMinutes: 45,
              isActive: false,
            ),
          ],
          outages: i == 2
              ? [
                  ShiftOutageItem(
                    id: 99,
                    incidentNumber: 1,
                    powerOffAt: pastLogin.add(const Duration(hours: 5)),
                    powerBackAt: pastLogin.add(const Duration(hours: 5, minutes: 20)),
                    durationMinutes: 20,
                    isActive: false,
                  )
                ]
              : [],
        ),
      );
    }
  }

  EmployeeShiftRecord? get activeShift => _activeShift;
  List<EmployeeShiftRecord> get shiftHistory => List.unmodifiable(_shiftHistory);

  /// Start Daily Shift (Login)
  Future<EmployeeShiftRecord> startShift({
    String employeeName = 'Sarah Jenkins',
    String employeeCode = 'ESS-0142',
  }) async {
    final now = DateTime.now();
    final scheduledStart = DateTime(now.year, now.month, now.day, 11, 0);
    final scheduledEnd = DateTime(now.year, now.month, now.day, 20, 0);

    int delay = 0;
    if (now.isAfter(scheduledStart)) {
      delay = now.difference(scheduledStart).inMinutes;
    }

    final newShift = EmployeeShiftRecord(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 1,
      employeeName: employeeName,
      employeeCode: employeeCode,
      shiftDate: DateTime(now.year, now.month, now.day),
      loginAt: now,
      scheduledStartAt: scheduledStart,
      scheduledEndAt: scheduledEnd,
      status: ShiftStatus.active,
      delayMinutes: delay,
      breaks: [],
      outages: [],
      lastActionAt: now,
      lastActionName: 'login',
    );

    _activeShift = newShift;
    return newShift;
  }

  /// Toggle Break (Take Break or Resume Work)
  Future<EmployeeShiftRecord> toggleBreak() async {
    if (_activeShift == null) {
      throw StateError('No active shift to toggle break.');
    }

    final now = DateTime.now();
    final shift = _activeShift!;

    if (shift.status == ShiftStatus.onBreak) {
      // Resume Work
      for (final b in shift.breaks) {
        if (b.isActive) {
          b.isActive = false;
          b.endTime = now;
          b.durationMinutes = now.difference(b.startTime).inMinutes;
        }
      }
      shift.status = ShiftStatus.active;
      shift.lastActionAt = now;
      shift.lastActionName = 'resume_work';
    } else {
      // Start Break
      final newBreak = ShiftBreakItem(
        id: shift.breaks.length + 1,
        startTime: now,
        isActive: true,
      );
      shift.breaks.insert(0, newBreak);
      shift.status = ShiftStatus.onBreak;
      shift.lastActionAt = now;
      shift.lastActionName = 'start_break';
    }

    _recalculateTotals(shift);
    return shift;
  }

  /// Toggle Power Outage (Report Power Cut or Restore Power)
  Future<EmployeeShiftRecord> togglePower() async {
    if (_activeShift == null) {
      throw StateError('No active shift to toggle power.');
    }

    final now = DateTime.now();
    final shift = _activeShift!;

    if (shift.status == ShiftStatus.powerOut) {
      // Power Restored
      for (final o in shift.outages) {
        if (o.isActive) {
          o.isActive = false;
          o.powerBackAt = now;
          o.durationMinutes = now.difference(o.powerOffAt).inMinutes;
        }
      }
      shift.status = ShiftStatus.active;
      shift.lastActionAt = now;
      shift.lastActionName = 'power_restored';
    } else {
      // Power Cut Reported
      final newOutage = ShiftOutageItem(
        id: shift.outages.length + 1,
        incidentNumber: shift.outages.length + 1,
        powerOffAt: now,
        isActive: true,
      );
      shift.outages.insert(0, newOutage);
      shift.status = ShiftStatus.powerOut;
      shift.lastActionAt = now;
      shift.lastActionName = 'power_cut';
    }

    _recalculateTotals(shift);
    return shift;
  }

  /// End Daily Shift (Logout)
  Future<EmployeeShiftRecord> endShift() async {
    if (_activeShift == null) {
      throw StateError('No active shift to end.');
    }

    final now = DateTime.now();
    final shift = _activeShift!;

    // Close any active break
    for (final b in shift.breaks) {
      if (b.isActive) {
        b.isActive = false;
        b.endTime = now;
        b.durationMinutes = now.difference(b.startTime).inMinutes;
      }
    }

    // Close any active outage
    for (final o in shift.outages) {
      if (o.isActive) {
        o.isActive = false;
        o.powerBackAt = now;
        o.durationMinutes = now.difference(o.powerOffAt).inMinutes;
      }
    }

    shift.logoutAt = now;
    shift.status = ShiftStatus.completed;
    shift.lastActionAt = now;
    shift.lastActionName = 'logout';

    _recalculateTotals(shift);

    _shiftHistory.insert(0, shift);
    _activeShift = null;
    return shift;
  }

  /// Undo last shift action within 2-minute window
  Future<EmployeeShiftRecord?> undoLastAction() async {
    final shift = _activeShift;
    if (shift == null || !shift.canUndo) return null;

    final action = shift.lastActionName;

    if (action == 'start_break') {
      if (shift.breaks.isNotEmpty && shift.breaks.first.isActive) {
        shift.breaks.removeAt(0);
      }
      shift.status = ShiftStatus.active;
    } else if (action == 'resume_work') {
      if (shift.breaks.isNotEmpty) {
        final last = shift.breaks.first;
        last.isActive = true;
        last.endTime = null;
      }
      shift.status = ShiftStatus.onBreak;
    } else if (action == 'power_cut') {
      if (shift.outages.isNotEmpty && shift.outages.first.isActive) {
        shift.outages.removeAt(0);
      }
      shift.status = ShiftStatus.active;
    } else if (action == 'power_restored') {
      if (shift.outages.isNotEmpty) {
        final last = shift.outages.first;
        last.isActive = true;
        last.powerBackAt = null;
      }
      shift.status = ShiftStatus.powerOut;
    }

    shift.lastActionAt = null;
    shift.lastActionName = null;
    _recalculateTotals(shift);
    return shift;
  }

  void _recalculateTotals(EmployeeShiftRecord shift) {
    int totalBreak = 0;
    for (final b in shift.breaks) {
      if (!b.isActive && b.endTime != null) {
        totalBreak += b.durationMinutes;
      } else if (b.isActive) {
        totalBreak += DateTime.now().difference(b.startTime).inMinutes;
      }
    }
    shift.totalBreakMinutes = totalBreak;

    int totalOutage = 0;
    for (final o in shift.outages) {
      if (!o.isActive && o.powerBackAt != null) {
        totalOutage += o.durationMinutes;
      } else if (o.isActive) {
        totalOutage += DateTime.now().difference(o.powerOffAt).inMinutes;
      }
    }
    shift.totalOutageMinutes = totalOutage;

    final refEnd = shift.logoutAt ?? DateTime.now();
    final gross = refEnd.difference(shift.loginAt).inMinutes;
    shift.elapsedMinutes = gross;

    final netWork = (gross - totalBreak - totalOutage).clamp(0, 9999);
    if (netWork > 480) {
      shift.regularMinutes = 480;
      shift.overtimeMinutes = netWork - 480;
    } else {
      shift.regularMinutes = netWork;
      shift.overtimeMinutes = 0;
    }
  }
}
