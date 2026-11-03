class PayslipItem {
  final String id;
  final String month;
  final num grossSalary;
  final num deductions;
  final num netPay;
  final String disbursementDate;
  final String status;
  final Map<String, num> breakdown;

  const PayslipItem({
    required this.id,
    required this.month,
    required this.grossSalary,
    required this.deductions,
    required this.netPay,
    required this.disbursementDate,
    required this.status,
    required this.breakdown,
  });

  factory PayslipItem.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
    final breakdownMap = rawBreakdown.map((k, v) => MapEntry(k, v as num));

    return PayslipItem(
      id: json['id'] as String? ?? '',
      month: json['month'] as String? ?? '',
      grossSalary: json['gross_salary'] as num? ?? 0,
      deductions: json['deductions'] as num? ?? 0,
      netPay: json['net_pay'] as num? ?? 0,
      disbursementDate: json['disbursement_date'] as String? ?? '',
      status: json['status'] as String? ?? 'paid',
      breakdown: breakdownMap,
    );
  }
}

class AllowanceItem {
  final int id;
  final String category;
  final num amount;
  final String submittedDate;
  final String description;
  final String status; // pending, approved, rejected

  const AllowanceItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.submittedDate,
    required this.description,
    required this.status,
  });

  factory AllowanceItem.fromJson(Map<String, dynamic> json) {
    return AllowanceItem(
      id: json['id'] as int,
      category: json['category'] as String? ?? 'General',
      amount: json['amount'] as num? ?? 0,
      submittedDate: json['submitted_date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class AdvanceItem {
  final int id;
  final num requestedAmount;
  final num monthlyDeduction;
  final String requestDate;
  final String reason;
  final String status;
  final num remainingBalance;

  const AdvanceItem({
    required this.id,
    required this.requestedAmount,
    required this.monthlyDeduction,
    required this.requestDate,
    required this.reason,
    required this.status,
    required this.remainingBalance,
  });

  factory AdvanceItem.fromJson(Map<String, dynamic> json) {
    return AdvanceItem(
      id: json['id'] as int,
      requestedAmount: json['requested_amount'] as num? ?? 0,
      monthlyDeduction: json['monthly_deduction'] as num? ?? 0,
      requestDate: json['request_date'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      remainingBalance: json['remaining_balance'] as num? ?? 0,
    );
  }
}

class PayrollDataBundle {
  final num currentMonthNet;
  final num allowanceApproved;
  final num allowancePending;
  final num advanceOutstanding;
  final List<PayslipItem> payslips;
  final List<AllowanceItem> allowances;
  final List<AdvanceItem> advances;

  const PayrollDataBundle({
    required this.currentMonthNet,
    required this.allowanceApproved,
    required this.allowancePending,
    required this.advanceOutstanding,
    required this.payslips,
    required this.allowances,
    required this.advances,
  });

  factory PayrollDataBundle.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final rawPayslips = json['payslips'] as List<dynamic>? ?? [];
    final rawAllowances = json['allowances'] as List<dynamic>? ?? [];
    final rawAdvances = json['advances'] as List<dynamic>? ?? [];

    return PayrollDataBundle(
      currentMonthNet: summary['net_salary_current_month'] as num? ?? 0,
      allowanceApproved: summary['allowance_approved'] as num? ?? 0,
      allowancePending: summary['allowance_pending'] as num? ?? 0,
      advanceOutstanding: summary['advance_outstanding'] as num? ?? 0,
      payslips: rawPayslips.map((e) => PayslipItem.fromJson(e as Map<String, dynamic>)).toList(),
      allowances: rawAllowances.map((e) => AllowanceItem.fromJson(e as Map<String, dynamic>)).toList(),
      advances: rawAdvances.map((e) => AdvanceItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

