// lib/features/account/presentation/pages/account_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prokat_app/app/providers.dart';

class AccountPage extends ConsumerStatefulWidget {
  static const route = '/account';
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  @override
  void initState() {
    super.initState();
    // стягиваем профиль
    Future.microtask(() => ref.read(accountNotifierProvider.notifier).load());
  }

  Future<void> _uploadPassport() async {
    final pics = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (!mounted || pics.isEmpty) return;
    final ok = await ref
        .read(accountNotifierProvider.notifier)
        .uploadPassport(pics.map((e) => e.path).toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Паспорт загружен' : 'Не удалось загрузить')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(accountNotifierProvider);

    // Первый кадр: загрузка
    if (st.loading && st.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Личный кабинет')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // Ошибка до получения данных
    if (st.error != null && st.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Личный кабинет')),
        body: Center(child: Text('Ошибка: ${st.error}')),
      );
    }
    // На всякий случай: ждём данные
    if (st.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Личный кабинет')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final u = st.user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Личный кабинет')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: (u.avatarUrl != null && u.avatarUrl!.isNotEmpty)
                    ? NetworkImage(u.avatarUrl!)
                    : null,
                child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name ?? 'Без имени',
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(u.phone),
                    if (u.email != null && u.email!.isNotEmpty) Text(u.email!),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          u.isVerified ? Icons.verified : Icons.error_outline,
                          size: 18,
                          color: u.isVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          u.isVerified
                              ? 'Аккаунт верифицирован'
                              : 'Нужна верификация',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _uploadPassport,
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Загрузить паспортные данные'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/listings'),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Мои объявления'),
          ),
        ],
      ),
    );
  }
}
