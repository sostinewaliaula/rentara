import 'package:rentara/core/models/user_model.dart';
import 'package:rentara/core/services/api_service.dart';
import 'package:rentara/core/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  @override
  AuthState build() {
    return AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.login(phone, password);
      state = state.copyWith(
        user: result.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.register(
        name: name,
        phone: phone,
        password: password,
        email: email,
        role: role,
      );
      state = state.copyWith(
        user: result.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
    );
  }
}

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;

  AuthState({
    required this.user,
    required this.isAuthenticated,
    required this.isLoading,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}




