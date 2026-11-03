enum UserRole { admin, employee }

class UserModel {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String employeeCode;
  final UserRole role;
  final String designation;
  final String department;
  final String? avatarUrl;
  final String joiningDate;
  final String shiftTiming;
  final String? githubUsername;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.employeeCode,
    required this.role,
    required this.designation,
    required this.department,
    this.avatarUrl,
    required this.joiningDate,
    required this.shiftTiming,
    this.githubUsername,
  });

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      employeeCode: json['employee_code'] as String? ?? '',
      role: (json['role'] == 'admin') ? UserRole.admin : UserRole.employee,
      designation: json['designation'] as String? ?? 'Team Member',
      department: json['department'] as String? ?? 'Engineering',
      avatarUrl: json['avatar_url'] as String?,
      joiningDate: json['joining_date'] as String? ?? '',
      shiftTiming: json['shift_timing'] as String? ?? '09:30 AM - 06:30 PM',
      githubUsername: json['github_username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'employee_code': employeeCode,
      'role': role == UserRole.admin ? 'admin' : 'employee',
      'designation': designation,
      'department': department,
      'avatar_url': avatarUrl,
      'joining_date': joiningDate,
      'shift_timing': shiftTiming,
      'github_username': githubUsername,
    };
  }
}

