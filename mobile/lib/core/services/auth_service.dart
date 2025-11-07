import 'package:rentara/core/models/user_model.dart';
import 'package:rentara/core/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResult> login(String phone, String password) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final user = UserModel.fromJson(data['user']);
        final token = data['token'] as String;

        await _apiService.saveToken(token);

        return AuthResult(user: user, token: token);
      } else {
        throw Exception(response.data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    required String role,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'phone': phone,
        'password': password,
        if (email != null) 'email': email,
        'role': role,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        final user = UserModel.fromJson(data['user']);
        final token = data['token'] as String;

        await _apiService.saveToken(token);

        return AuthResult(user: user, token: token);
      } else {
        throw Exception(response.data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final response = await _apiService.get('/auth/me');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
  }
}

class AuthResult {
  final UserModel user;
  final String token;

  AuthResult({required this.user, required this.token});
}




