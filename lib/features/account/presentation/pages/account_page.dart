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
  bool _editing = false;

  @override
  void initState() {
    super.initState();
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
      SnackBar(
          content:
              Text(ok ? 'Фото паспорта загружены' : 'Не удалось загрузить')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(accountNotifierProvider);

    if (st.loading && st.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Личный кабинет')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (st.error != null && st.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Личный кабинет')),
        body: Center(child: Text('Ошибка: ${st.error}')),
      );
    }
    if (st.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Личный кабинет')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final u = st.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
        actions: [
          IconButton(
            tooltip: _editing ? 'Готово' : 'Редактировать',
            icon: Icon(_editing ? Icons.check : Icons.edit),
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.phone,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          u.isVerified ? Icons.verified : Icons.error_outline,
                          size: 18,
                          color: u.isVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(u.isVerified
                            ? 'Аккаунт верифицирован'
                            : 'Нужна верификация'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Block: Паспорт (только фото)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Паспорт',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    u.passport.seriesNumber?.isNotEmpty == true
                        ? 'Серия/номер: ${u.passport.seriesNumber}'
                        : 'Данные не указаны',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: st.uploading ? null : _uploadPassport,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(
                        st.uploading ? 'Загружаю…' : 'Загрузить фото паспорта'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Block: Аккаунт (пока только просмотр — телефон редактировать нельзя)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Аккаунт',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _kv('ID', u.id.toString()),
                  _kv('Телефон', u.phone),
                  _kv('Создан', u.createdAt),
                  _kv('Статус', u.isActive ? 'Активен' : 'Неактивен'),
                  if (u.isAdmin) _kv('Роль', 'Администратор'),
                  const SizedBox(height: 8),
                  Text(
                    _editing
                        ? 'Редактирование пока доступно только для фото паспорта.'
                        : 'Для изменения данных нажмите «Редактировать».',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}
