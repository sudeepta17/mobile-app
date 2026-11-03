import '../../models/leave_model.dart';

abstract class ILeaveService {
  Future<LeaveDataBundle> getLeaveData();
  Future<LeaveHistoryItem> applyLeave({
    required String leaveType,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  });
}

