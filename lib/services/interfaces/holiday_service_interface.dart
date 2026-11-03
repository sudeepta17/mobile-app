import '../../models/holiday_model.dart';

abstract class IHolidayService {
  Future<List<HolidayModel>> getUpcomingHolidays();
}

