// lib/features/auth/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prokat_app/features/auth/state/auth_notifier.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Стартуем проверку токена один раз после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).check();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем изменение статуса авторизации и уходим ОДИН раз
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (_navigated) return;
      final isLoggedIn = next.isLoggedIn; // null | true | false
      if (isLoggedIn == null) return; // ещё грузимся
      _navigated = true;
      if (!mounted) return;
      context.go(isLoggedIn ? '/home' : '/login');
    });

    return Scaffold(
      body: const Center(child: CircularProgressIndicator()),
      // ↓↓↓ ВРЕМЕННЫЕ КНОПКИ ДЛЯ ДЕБАГА (можно убрать после проверки)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // ручной переход на логин (блокируем автопереходы)
                    _navigated = true;
                    if (mounted) context.go('/login');
                  },
                  child: const Text('На логин'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Полный выход: удалит токен и обновит состояние
                    await ref.read(authNotifierProvider.notifier).logout();
                    _navigated = true;
                    if (!mounted) return;
                    context.go('/login');
                  },
                  child: const Text('Сбросить сессию'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
