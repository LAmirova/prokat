// lib/features/auth/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Добро пожаловать!!'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/listings'),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Перейти в каталог'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/listings/create'),
              icon: const Icon(Icons.add),
              label: const Text('Создать объявление'),
            ),
          ],
        ),
      ),
    );
  }
}
