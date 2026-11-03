import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/service_locator.dart';

class AuthState extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await services.authService.getCurrentUser();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await services.authService.login(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchDemoRole(UserRole targetRole) async {
    final demoUsers = await services.authService.getDemoUsers();
    _currentUser = demoUsers.firstWhere(
      (u) => u.role == targetRole,
      orElse: () => demoUsers.first,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await services.authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}

