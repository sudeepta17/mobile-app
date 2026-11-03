import 'interfaces/auth_service_interface.dart';
import 'interfaces/project_service_interface.dart';
import 'interfaces/blocker_service_interface.dart';
import 'interfaces/leave_service_interface.dart';
import 'interfaces/attendance_service_interface.dart';
import 'interfaces/payroll_service_interface.dart';
import 'interfaces/holiday_service_interface.dart';

import 'mock/mock_auth_service.dart';
import 'mock/mock_project_service.dart';
import 'mock/mock_blocker_service.dart';
import 'mock/mock_leave_service.dart';
import 'mock/mock_attendance_service.dart';
import 'mock/mock_payroll_service.dart';
import 'mock/mock_holiday_service.dart';

/// Central Service Locator following Clean Architecture.
/// Facilitates effortless replacement of Mock implementations with real REST API / GraphQL clients.
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  late final IAuthService authService = MockAuthService();
  late final IProjectService projectService = MockProjectService();
  late final IBlockerService blockerService = MockBlockerService();
  late final ILeaveService leaveService = MockLeaveService();
  late final IAttendanceService attendanceService = MockAttendanceService();
  late final IPayrollService payrollService = MockPayrollService();
  late final IHolidayService holidayService = MockHolidayService();
}

final services = ServiceLocator.instance;

