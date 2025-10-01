// lib/app/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AUTH
import 'package:prokat_app/features/auth/data/auth_repository.dart';

// LISTINGS
import 'package:prokat_app/features/listings/data/listings_api.dart';
import 'package:prokat_app/features/listings/data/listings_repository.dart';
import 'package:prokat_app/features/listings/state/listings_notifier.dart';

// ACCOUNT
import 'package:prokat_app/features/account/data/account_api.dart';
import 'package:prokat_app/features/account/data/account_repository.dart';
import 'package:prokat_app/features/account/state/account_notifier.dart';

// --- AUTH
final authRepoProvider = Provider<AuthRepository>((ref) => AuthRepository());

// --- LISTINGS
final listingsApiProvider = Provider<ListingsApi>((ref) => ListingsApi());
final listingsRepositoryProvider = Provider<ListingsRepository>(
  (ref) => ListingsRepository(ref.watch(listingsApiProvider)),
);
final listingsStateProvider =
    StateNotifierProvider<ListingsNotifier, ListingsState>(
  (ref) => ListingsNotifier(ref.watch(listingsRepositoryProvider)),
);

// --- ACCOUNT
final accountApiProvider = Provider<AccountApi>((ref) => AccountApi());
final accountRepositoryProvider = Provider<AccountRepository>(
    (ref) => AccountRepository(ref.watch(accountApiProvider)));
final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  return AccountNotifier(ref.watch(accountRepositoryProvider));
});
