import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prokat_app/features/auth/data/auth_repository.dart';
import 'package:prokat_app/app/providers.dart';

/// null = неизвестно (идёт проверка), true/false = авторизован/нет
class AuthState {
  final bool? isLoggedIn;
  const AuthState({this.isLoggedIn});
  AuthState copyWith({bool? isLoggedIn}) =>
      AuthState(isLoggedIn: isLoggedIn ?? this.isLoggedIn);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repo;
  AuthNotifier(this.repo) : super(const AuthState(isLoggedIn: null)) {
    check();
  }

  Future<void> check() async {
    final ok = await repo.isLoggedIn();
    state = state.copyWith(isLoggedIn: ok);
  }

  Future<void> login(String phone, String password) async {
    await repo.login(phone, password);
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> logout() async {
    await repo.logout();
    state = state.copyWith(isLoggedIn: false);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepoProvider)),
);
