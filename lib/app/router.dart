// lib/app/router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// LAYOUT
import 'package:prokat_app/app/main_layout.dart';

// AUTH
import 'package:prokat_app/features/auth/presentation/pages/login_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/register_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/verify_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/set_password_page.dart';
import 'package:prokat_app/features/auth/presentation/pages/forgot_password_page.dart';

// LISTINGS
import 'package:prokat_app/features/listings/presentation/pages/listings_home_page.dart';
import 'package:prokat_app/features/listings/presentation/pages/listing_create_page.dart';

// ACCOUNT
import 'package:prokat_app/features/account/presentation/pages/account_page.dart';

// OTHER TABS
import 'package:prokat_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:prokat_app/features/messages/presentation/pages/messages_page.dart';

final router = GoRouter(
  initialLocation: '/listings',
  routes: [
    // Auth (вне ShellRoute)
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/verify', builder: (_, __) => const VerifyPage()),
    GoRoute(path: '/set-password', builder: (_, __) => const SetPasswordPage()),
    GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage()),

    // Общий лэйаут снизу + FAB
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/listings',
          builder: (_, __) => const ListingsHomePage(),
          routes: [
            GoRoute(
              path: 'create', // /listings/create
              builder: (_, __) => const ListingCreatePage(),
            ),
          ],
        ),
        GoRoute(
          path: '/favorites',
          builder: (_, __) => const FavoritesPage(),
        ),
        GoRoute(
          path: '/messages',
          builder: (_, __) => const MessagesPage(),
        ),
        GoRoute(
          path: '/account',
          builder: (_, __) => const AccountPage(),
        ),
      ],
    ),
  ],
);

final routerProvider = Provider<GoRouter>((ref) => router);
