// lib/app/router.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// AUTH
import 'package:prokat_app/features/auth/presentation/pages/login_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/register_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/verify_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/set_password_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/forgot_password_page.dart';

// HOME (по твоему пути)
import 'package:prokat_app/features/auth/pages/home_page.dart';

import 'package:prokat_app/features/auth/state/auth_notifier.dart';

enum AppRoute { login, register, verify, setPassword, forgotPassword, home }

/// Адаптер: Stream -> Listenable, чтобы GoRouter пересчитывал redirect при login/logout/check
class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider); // bool? isLoggedIn
  final authNotifier = ref.read(authNotifierProvider.notifier); // для refresh

  const authPaths = <String>{
    '/login',
    '/register',
    '/forgot-password',
    '/verify',
    '/set-password',
  };

  return GoRouter(
    // стартуем сразу с логина; если пользователь уже залогинен — редирект отправит на /home
    initialLocation: '/login',

    // чтобы redirect вызывался при изменениях авторизации
    refreshListenable: _RouterRefreshStream(authNotifier.stream),

    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn; // null | true | false
      final loc = state.matchedLocation;
      final onAuthScreen = authPaths.contains(loc);

      // пока статус неизвестен (первая проверка в AuthNotifier.check) — ничего не делаем
      if (isLoggedIn == null) return null;

      // если НЕ авторизован и лезем на приватные маршруты — гоним на /login
      if (!isLoggedIn && !onAuthScreen) return '/login';

      // если УЖЕ авторизован и пытаемся открыть страницу авторизации — уводим на /home
      if (isLoggedIn && onAuthScreen) return '/home';

      // иначе — остаёмся тут
      return null;
    },

    routes: [
      GoRoute(
          path: '/login',
          name: AppRoute.login.name,
          builder: (_, __) => const LoginPage()),
      GoRoute(
          path: '/register',
          name: AppRoute.register.name,
          builder: (_, __) => const RegisterPage()),
      GoRoute(
          path: '/verify',
          name: AppRoute.verify.name,
          builder: (_, __) => const VerifyPage()),
      GoRoute(
          path: '/set-password',
          name: AppRoute.setPassword.name,
          builder: (_, __) => const SetPasswordPage()),
      GoRoute(
          path: '/forgot-password',
          name: AppRoute.forgotPassword.name,
          builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
          path: '/home',
          name: AppRoute.home.name,
          builder: (_, __) => const HomePage()),
    ],
  );
});
