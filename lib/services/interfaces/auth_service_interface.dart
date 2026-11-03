import '../../models/user_model.dart';

abstract class IAuthService {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<List<UserModel>> getDemoUsers();
}

