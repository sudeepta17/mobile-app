import 'package:intl/intl.dart';
import '../../models/dashboard_summary_model.dart';
import '../interfaces/dashboard_service_interface.dart';

class MockDashboardService implements IDashboardService {
  DashboardSummaryModel? _cachedSummary;
  int _gymStreak = 5;
  int _gymMonthCount = 14;

  @override
  Future<DashboardSummaryModel> getDashboardSummary({int? year}) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    _cachedSummary = DashboardSummaryModel(
      profile: const DashboardProfile(
        id: 1,
        name: 'Sarah Jenkins',
        employeeCode: 'ESS-0142',
        joiningDate: '2023-03-15',
        githubUsername: 'sarah-essane',
      ),
      requests: const DashboardRequests(
        total: 18,
        pending: 3,
        approved: 13,
        rejected: 2,
      ),
      leave: const DashboardLeave(
        approvedDays: 14,
        pendingDays: 2,
        byType: [
          DashboardLeaveTypeItem(
            id: 1,
            name: 'Casual Leave',
            daysAllowed: 12,
            usedDays: 6,
            pendingDays: 1,
            remainingDays: 6,
          ),
          DashboardLeaveTypeItem(
            id: 2,
            name: 'Sick Leave',
            daysAllowed: 10,
            usedDays: 3,
            pendingDays: 1,
            remainingDays: 7,
          ),
          DashboardLeaveTypeItem(
            id: 3,
            name: 'Earned Leave',
            daysAllowed: 15,
            usedDays: 5,
            pendingDays: 0,
            remainingDays: 10,
          ),
        ],
      ),
      allowance: const DashboardAllowance(
        submittedAmount: 18500.00,
        approvedAmount: 14200.00,
        pendingAmount: 4300.00,
      ),
      advance: const DashboardAdvance(
        approvedAmount: 25000.00,
        pendingAmount: 0.00,
        outstandingBalance: 12500.00,
      ),
      gym: DashboardGym(
        yearCount: 78,
        monthCount: _gymMonthCount,
        currentStreak: _gymStreak,
        lastCheckIn: todayStr,
      ),
      nextHoliday: const DashboardHoliday(
        name: 'Diwali (Festival of Lights)',
        date: '2026-11-08',
        daysRemaining: 5,
      ),
      blockers: const DashboardBlockers(
        pendingCount: 2,
        repliedCount: 5,
        createdCount: 3,
      ),
      recentActivity: [
        DashboardActivityItem(
          id: 'leave_1',
          type: 'leave',
          title: 'Casual leave request',
          message: '20 Oct – 21 Oct (2 days)',
          status: 'approved',
          date: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        ),
        DashboardActivityItem(
          id: 'allowance_1',
          type: 'allowance',
          title: 'Travel allowance',
          message: '₹2,450.00 claim',
          status: 'approved',
          date: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        ),
        DashboardActivityItem(
          id: 'advance_1',
          type: 'advance',
          title: 'Salary advance',
          message: '₹15,000.00 requested',
          status: 'pending',
          date: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        ),
        DashboardActivityItem(
          id: 'leave_2',
          type: 'leave',
          title: 'Sick leave request',
          message: '14 Oct (1 day)',
          status: 'approved',
          date: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        ),
        DashboardActivityItem(
          id: 'allowance_2',
          type: 'allowance',
          title: 'Client dinner allowance',
          message: '₹1,850.00 claim',
          status: 'pending',
          date: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        ),
      ],
    );

    return _cachedSummary!;
  }

  @override
  Future<bool> punchGymCheckIn() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _gymStreak += 1;
    _gymMonthCount += 1;
    return true;
  }
}
