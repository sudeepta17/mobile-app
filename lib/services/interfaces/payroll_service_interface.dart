import '../../models/payroll_model.dart';

abstract class IPayrollService {
  Future<PayrollDataBundle> getPayrollData();
  Future<AllowanceItem> submitAllowance({
    required String category,
    required num amount,
    required String description,
  });
  Future<AdvanceItem> requestAdvance({
    required num amount,
    required String reason,
  });
}

