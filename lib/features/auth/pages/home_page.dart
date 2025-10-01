// lib/features/auth/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prokat_app/app/providers.dart'; // authRepoProvider

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepoProvider).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // Делаем AppBar явно видимым (фон + тень)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        title: const Text('Главная'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Добро пожаловать!'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/listings'),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text(' каталог '),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/listings/create'),
              icon: const Icon(Icons.add),
              label: const Text('Создать объявление'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/account'),
              icon: const Icon(Icons.person_outline),
              label: const Text('Личный кабинет'),
            ),
          ],
        ),
      ),
    );
  }
}
