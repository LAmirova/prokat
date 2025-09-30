import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prokat_app/features/auth/data/auth_repository.dart';

/// Единый экземпляр репозитория авторизации
final authRepoProvider = Provider<AuthRepository>((ref) => AuthRepository());
