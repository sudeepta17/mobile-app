import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_service_interface.dart';

class MockAuthService implements IAuthService {
  UserModel? _currentUser;
  List<UserModel>? _cachedUsers;

  @override
  Future<List<UserModel>> getDemoUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/users.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedUsers = list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Fallback
      _cachedUsers = [
        const UserModel(
          id: 1,
          name: 'Sarah Jenkins',
          email: 'sarah.jenkins@essane.com',
          mobile: '+91 98765 43210',
          employeeCode: 'ESS-0142',
          role: UserRole.employee,
          designation: 'Senior Fullstack Engineer',
          department: 'Engineering',
          joiningDate: '2023-03-15',
          shiftTiming: '09:30 AM - 06:30 PM',
          githubUsername: 'sarah-essane',
        ),
        const UserModel(
          id: 2,
          name: 'Marcus Vance',
          email: 'marcus.vance@essane.com',
          mobile: '+91 98123 45678',
          employeeCode: 'ESS-0001',
          role: UserRole.admin,
          designation: 'Chief Operating Officer & Director',
          department: 'Executive Leadership',
          joiningDate: '2020-01-10',
          shiftTiming: '09:00 AM - 07:00 PM',
          githubUsername: 'marcus-v',
        ),
      ];
    }
    return _cachedUsers!;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final users = await getDemoUsers();
    final matched = users.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => users.first,
    );
    _currentUser = matched;
    return matched;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser == null) {
      final users = await getDemoUsers();
      _currentUser = users.first; // Default to employee
    }
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}

