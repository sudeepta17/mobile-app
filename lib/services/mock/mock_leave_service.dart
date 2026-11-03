import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/leave_model.dart';
import '../interfaces/leave_service_interface.dart';

class MockLeaveService implements ILeaveService {
  LeaveDataBundle? _data;

  Future<void> _ensureLoaded() async {
    if (_data != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/leaves.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      _data = LeaveDataBundle.fromJson(map);
    } catch (_) {
      _data = const LeaveDataBundle(
        totalAllowed: 24,
        taken: 8,
        pending: 2,
        remaining: 14,
        types: [],
        history: [],
      );
    }
  }

  @override
  Future<LeaveDataBundle> getLeaveData() async {
    await _ensureLoaded();
    return _data!;
  }

  @override
  Future<LeaveHistoryItem> applyLeave({
    required String leaveType,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    await _ensureLoaded();
    final days = toDate.difference(fromDate).inDays + 1;
    final newItem = LeaveHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch,
      leaveType: leaveType,
      fromDate: fromDate.toIso8601String().substring(0, 10),
      toDate: toDate.toIso8601String().substring(0, 10),
      days: days,
      reason: reason,
      status: 'pending',
      appliedOn: DateTime.now().toIso8601String().substring(0, 10),
      reviewerComment: null,
    );

    final updatedHistory = List<LeaveHistoryItem>.from(_data!.history)..insert(0, newItem);
    _data = LeaveDataBundle(
      totalAllowed: _data!.totalAllowed,
      taken: _data!.taken,
      pending: _data!.pending + days,
      remaining: _data!.remaining - days > 0 ? _data!.remaining - days : 0,
      types: _data!.types,
      history: updatedHistory,
    );
    return newItem;
  }
}

