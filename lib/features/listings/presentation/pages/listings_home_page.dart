// lib/features/listings/presentation/pages/listings_home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _searchCtrl.removeListener(_onChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingsStateProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchCtrl,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Поиск по названию…',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
            isDense: true,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Фильтры',
            icon: const Icon(Icons.tune),
            onPressed: () {
              // TODO: открыть экран/боковой лист с фильтрами
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Фильтры скоро будут 😉')),
              );
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    Text('Ошибка: ${state.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Пока пусто'));
          }

          // Pull-to-refresh перезапускает поиск по текущей строке
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(listingsStateProvider.notifier)
                  .search(_searchCtrl.text.trim());
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length,
              itemBuilder: (context, i) => ListingCard(item: state.items[i]),
            ),
          );
        },
      ),
    );
  }
}
