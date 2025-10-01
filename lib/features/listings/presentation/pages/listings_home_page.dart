import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prokat_app/app/providers.dart';
import 'package:prokat_app/features/listings/widgets/listing_card.dart';

class ListingsHomePage extends ConsumerStatefulWidget {
  static const route = '/listings';
  const ListingsHomePage({super.key});

  @override
  ConsumerState<ListingsHomePage> createState() => _ListingsHomePageState();
}

class _ListingsHomePageState extends ConsumerState<ListingsHomePage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(listingsStateProvider).query;
    _searchCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(listingsStateProvider.notifier).search(_searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingsStateProvider);
    final notifier = ref.read(listingsStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.showingMine ? 'Мои объявления' : 'Каталог'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push('/listings/create');
              if (mounted) {
                state.showingMine ? notifier.loadMine() : notifier.load();
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Создать объявление',
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'mine') {
                notifier.loadMine();
              } else {
                notifier.load();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Все объявления')),
              PopupMenuItem(value: 'mine', child: Text('Мои объявления')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Поиск по названию…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator());
                if (state.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Ошибка: ${state.error}', textAlign: TextAlign.center),
                    ),
                  );
                }
                if (state.items.isEmpty) return const Center(child: Text('Пока пусто'));
                return ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, i) => ListingCard(item: state.items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
