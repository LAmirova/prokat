// lib/app/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AUTH
import 'package:prokat_app/features/auth/data/auth_repository.dart';

// LISTINGS
import 'package:prokat_app/features/listings/data/listings_api.dart';
import 'package:prokat_app/features/listings/data/listings_repository.dart';
import 'package:prokat_app/features/listings/state/listings_notifier.dart';

/// Репозиторий авторизации (твой класс на FlutterSecureStorage + AuthApi)
final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// API-слой объявлений (работает через общий dio из core/network/dio_client.dart)
final listingsApiProvider = Provider<ListingsApi>((ref) {
  return ListingsApi();
});

/// Репозиторий объявлений
final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(ref.watch(listingsApiProvider));
});

/// Состояние каталога (список/поиск/мои)
final listingsStateProvider =
    StateNotifierProvider<ListingsNotifier, ListingsState>((ref) {
  return ListingsNotifier(ref.watch(listingsRepositoryProvider));
});
