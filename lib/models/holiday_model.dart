class HolidayModel {
  final int id;
  final String name;
  final String date;
  final String day;
  final int daysRemaining;
  final String type;
  final String icon;

  const HolidayModel({
    required this.id,
    required this.name,
    required this.date,
    required this.day,
    required this.daysRemaining,
    required this.type,
    required this.icon,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      day: json['day'] as String? ?? '',
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'Holiday',
      icon: json['icon'] as String? ?? 'sparkles',
    );
  }
}

