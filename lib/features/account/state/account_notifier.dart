import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prokat_app/features/account/data/account_repository.dart';

class AccountState {
  final bool loading;
  final UserMe? user;
  final String? error;
  final bool uploading;

  const AccountState({
    this.loading = true,
    this.user,
    this.error,
    this.uploading = false,
  });

  AccountState copyWith({
    bool? loading,
    UserMe? user,
    String? error,
    bool? uploading,
  }) =>
      AccountState(
        loading: loading ?? this.loading,
        user: user ?? this.user,
        error: error,
        uploading: uploading ?? this.uploading,
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
    state = state.copyWith(uploading: true, error: null);
    try {
      await repo.uploadPassportPhotos(paths);
      await load(); // обновим данные
      return true;
    } catch (e) {
      state = state.copyWith(uploading: false, error: e.toString());
      return false;
    }
  }
}
