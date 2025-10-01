import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// AUTH PAGES
import 'package:prokat_app/features/auth/pages/home_page.dart';
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

/// Отдельные роуты каталога
final listingsRoutes = <GoRoute>[
  GoRoute(
    path: '/listings',
    builder: (context, state) => const ListingsHomePage(),
    routes: [
      GoRoute(
        path: 'create', // => /listings/create
        builder: (context, state) => const ListingCreatePage(),
      ),
    ],
  ),
];

/// Основной роутер приложения
final router = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    // AUTH
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
        path: '/register', builder: (context, state) => const RegisterPage()),
    GoRoute(path: '/verify', builder: (context, state) => const VerifyPage()),
    GoRoute(
        path: '/set-password',
        builder: (context, state) => const SetPasswordPage()),
    GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage()),

    // HOME
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),

    // ACCOUNT
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountPage(),
    ),

    // LISTINGS
    ...listingsRoutes,
  ],
);

/// Провайдер для GoRouter (используется в MaterialApp.router)
final routerProvider = Provider<GoRouter>((ref) => router);
