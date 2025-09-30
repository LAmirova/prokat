// lib/features/auth/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prokat_app/features/auth/state/auth_notifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref
        .read(authNotifierProvider.notifier)
        .logout(); // удалит токен + обновит state
    if (context.mounted) context.go('/login'); // мгновенно уводим на логин
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: const Center(
        child: Text('Добро пожаловать!'),
      ),
    );
  }
}
