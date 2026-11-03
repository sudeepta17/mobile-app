import '../../models/dashboard_summary_model.dart';

abstract class IDashboardService {
  Future<DashboardSummaryModel> getDashboardSummary({int? year});
  Future<bool> punchGymCheckIn();
}

