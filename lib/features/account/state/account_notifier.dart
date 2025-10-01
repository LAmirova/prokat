import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prokat_app/features/account/data/account_repository.dart';

class AccountState {
  final bool loading;
  final UserMe? user;
  final String? error;

  const AccountState({this.loading = false, this.user, this.error});

  AccountState copyWith({bool? loading, UserMe? user, String? error}) =>
      AccountState(
        loading: loading ?? this.loading,
        user: user ?? this.user,
        error: error,
      );
}

class AccountNotifier extends StateNotifier<AccountState> {
  final AccountRepository repo;
  AccountNotifier(this.repo) : super(const AccountState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final u = await repo.me();
      state = state.copyWith(loading: false, user: u);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> uploadPassport(List<String> paths) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await repo.uploadPassport(paths);
      await load(); // обновим инфу
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}
