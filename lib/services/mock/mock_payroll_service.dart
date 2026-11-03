import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/payroll_model.dart';
import '../interfaces/payroll_service_interface.dart';

class MockPayrollService implements IPayrollService {
  PayrollDataBundle? _data;

  Future<void> _ensureLoaded() async {
    if (_data != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/payroll.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      _data = PayrollDataBundle.fromJson(map);
    } catch (_) {
      _data = const PayrollDataBundle(
        currentMonthNet: 125000,
        allowanceApproved: 8500,
        allowancePending: 2200,
        advanceOutstanding: 0,
        payslips: [],
        allowances: [],
        advances: [],
      );
    }
  }

  @override
  Future<PayrollDataBundle> getPayrollData() async {
    await _ensureLoaded();
    return _data!;
  }

  @override
  Future<AllowanceItem> submitAllowance({
    required String category,
    required num amount,
    required String description,
  }) async {
    await _ensureLoaded();
    final newItem = AllowanceItem(
      id: DateTime.now().millisecondsSinceEpoch,
      category: category,
      amount: amount,
      submittedDate: DateTime.now().toIso8601String().substring(0, 10),
      description: description,
      status: 'pending',
    );

    final updatedList = List<AllowanceItem>.from(_data!.allowances)..insert(0, newItem);
    _data = PayrollDataBundle(
      currentMonthNet: _data!.currentMonthNet,
      allowanceApproved: _data!.allowanceApproved,
      allowancePending: _data!.allowancePending + amount,
      advanceOutstanding: _data!.advanceOutstanding,
      payslips: _data!.payslips,
      allowances: updatedList,
      advances: _data!.advances,
    );
    return newItem;
  }

  @override
  Future<AdvanceItem> requestAdvance({
    required num amount,
    required String reason,
  }) async {
    await _ensureLoaded();
    final newItem = AdvanceItem(
      id: DateTime.now().millisecondsSinceEpoch,
      requestedAmount: amount,
      monthlyDeduction: (amount / 3).round(),
      requestDate: DateTime.now().toIso8601String().substring(0, 10),
      reason: reason,
      status: 'pending',
      remainingBalance: amount,
    );

    final updatedAdvances = List<AdvanceItem>.from(_data!.advances)..insert(0, newItem);
    _data = PayrollDataBundle(
      currentMonthNet: _data!.currentMonthNet,
      allowanceApproved: _data!.allowanceApproved,
      allowancePending: _data!.allowancePending,
      advanceOutstanding: _data!.advanceOutstanding + amount,
      payslips: _data!.payslips,
      allowances: _data!.allowances,
      advances: updatedAdvances,
    );
    return newItem;
  }
}

