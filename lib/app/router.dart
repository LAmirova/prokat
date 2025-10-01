import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// LAYOUT
import 'package:prokat_app/app/main_layout.dart';

// ===== AUTH (используем алиас auth, чтобы исключить конфликты) =====
import 'package:prokat_app/features/auth/presentation/pages/login_page.dart'
    as auth;
import 'package:prokat_app/features/auth/presentation/pages/register_page.dart'
    as auth;
import 'package:prokat_app/features/auth/presentation/pages/verify_page.dart'
    as auth;
import 'package:prokat_app/features/auth/presentation/pages/set_password_page.dart'
    as auth;
import 'package:prokat_app/features/auth/presentation/pages/forgot_password_page.dart'
    as auth;

// ===== LISTINGS =====
import 'package:prokat_app/features/listings/presentation/pages/listings_home_page.dart'
    as listings;
import 'package:prokat_app/features/listings/presentation/pages/listing_create_page.dart'
    as listings;

// ===== ACCOUNT =====
import 'package:prokat_app/features/account/presentation/pages/account_page.dart'
    as account;

// ===== OTHER TABS =====
import 'package:prokat_app/features/favorites/presentation/pages/favorites_page.dart'
    as tabs;
import 'package:prokat_app/features/messages/presentation/pages/messages_page.dart'
    as tabs;

final router = GoRouter(
  // Стартуем в каталог
  initialLocation: '/listings',

  // На всякий случай: если где-то остался переход на /home — редиректим
  redirect: (ctx, state) {
    if (state.uri.toString() == '/home') {
      return '/listings';
    }
    return null;
  },

  routes: [
    // ===== AUTH (эти экраны без общего лэйаута) =====
    GoRoute(path: '/login', builder: (_, __) => const auth.LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const auth.RegisterPage()),
    GoRoute(path: '/verify', builder: (_, __) => const auth.VerifyPage()),
    GoRoute(
        path: '/set-password',
        builder: (_, __) => const auth.SetPasswordPage()),
    GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const auth.ForgotPasswordPage()),

    // ===== Общий лэйаут (нижняя навигация + центр «Добавить») =====
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        // Каталог / Поиск
        GoRoute(
          path: '/listings',
          builder: (_, __) => const listings.ListingsHomePage(),
          routes: [
            GoRoute(
              path: 'create', // /listings/create
              builder: (_, __) => const listings.ListingCreatePage(),
            ),
          ],
        ),

        // Избранное
        GoRoute(
          path: '/favorites',
          builder: (_, __) => const tabs.FavoritesPage(),
        ),

        // Сообщения
        GoRoute(
          path: '/messages',
          builder: (_, __) => const tabs.MessagesPage(),
        ),

        // Профиль
        GoRoute(
          path: '/account',
          builder: (_, __) => const account.AccountPage(),
        ),
      ],
    ),
  ],
);

final routerProvider = Provider<GoRouter>((ref) => router);
