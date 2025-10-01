import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prokat_app/features/listings/data/listings_repository.dart';
import 'package:prokat_app/features/listings/domain/listing.dart';

class ListingsState {
  final bool isLoading;
  final List<Listing> items;
  final String? error;
  final bool showingMine;
  final String query;

  const ListingsState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.showingMine = false,
    this.query = '',
  });

  ListingsState copyWith({
    bool? isLoading,
    List<Listing>? items,
    String? error,
    bool? showingMine,
    String? query,
  }) {
    return ListingsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
      showingMine: showingMine ?? this.showingMine,
      query: query ?? this.query,
    );
  }
}

class ListingsNotifier extends StateNotifier<ListingsState> {
  final ListingsRepository repo;
  ListingsNotifier(this.repo) : super(const ListingsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null, showingMine: false);
    try {
      final data = await repo.getItems(search: state.query);
      state = state.copyWith(isLoading: false, items: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMine() async {
    state = state.copyWith(isLoading: true, error: null, showingMine: true);
    try {
      final data = await repo.getMyItems();
      state = state.copyWith(isLoading: false, items: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(String q) async {
    state = state.copyWith(query: q);
    await load();
  }
}
