import '../../models/attendance_model.dart';

abstract class IAttendanceService {
  Future<AttendanceDataBundle> getAttendanceData();
  Future<TodayAttendance> punchAttendance();
  Future<TodayAttendance> gymCheckIn();
}

