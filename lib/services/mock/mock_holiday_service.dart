import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/holiday_model.dart';
import '../interfaces/holiday_service_interface.dart';

class MockHolidayService implements IHolidayService {
  List<HolidayModel>? _holidays;

  @override
  Future<List<HolidayModel>> getUpcomingHolidays() async {
    if (_holidays != null) return _holidays!;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/holidays.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _holidays = list.map((e) => HolidayModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _holidays = [];
    }
    return _holidays!;
  }
}

