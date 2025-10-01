// lib/features/listings/data/listings_repository.dart
import 'package:prokat_app/features/listings/data/listings_api.dart';
import 'package:prokat_app/features/listings/domain/listing.dart';
import 'package:prokat_app/features/listings/domain/taxonomy.dart';

class ListingsRepository {
  final ListingsApi api;
  ListingsRepository(this.api);

  Listing _fromMap(Map<String, dynamic> m) {
    final photos = (m['photos'] as List? ?? [])
        .map((p) => Photo(
              id: (p['id'] as num?)?.toInt() ?? 0,
              path: (p['path']?.toString() ?? '').replaceAll('\\', '/'),
              isMain: (p['is_main'] as bool?) ?? false,
            ))
        .toList();

    return Listing(
      id: (m['id'] as num).toInt(),
      title: m['title']?.toString() ?? '',
      address: m['address']?.toString() ?? '',
      priceHour: (m['price_hour'] as num?)?.toDouble(),
      priceDay: (m['price_day'] as num?)?.toDouble(),
      priceMonth: (m['price_month'] as num?)?.toDouble(),
      condition: ItemConditionX.fromApi(m['condition']?.toString()),
      deposit: (m['deposit'] as bool?) ?? false,
      tags: (m['tags'] is List)
          ? (m['tags'] as List).map((e) => e.toString()).toList()
          : (m['tags']?.toString().split(',') ?? []),
      viewsCount: (m['views_count'] as num?)?.toInt() ?? 0,
      photos: photos,
    );
  }

  Future<List<Listing>> getItems(
      {String? search, int skip = 0, int limit = 20}) async {
    final raw =
        await api.fetchItems(searchQuery: search, skip: skip, limit: limit);
    return raw.map(_fromMap).toList();
  }

  Future<List<Listing>> getMyItems({int skip = 0, int limit = 20}) async {
    final raw = await api.fetchMyItems(skip: skip, limit: limit);
    return raw.map(_fromMap).toList();
  }

  Future<Listing> getItem(int id) async {
    final m = await api.fetchItem(id);
    return _fromMap(m);
  }

  // taxonomy
  Future<List<Section>> getSections() async =>
      (await api.fetchSections()).map((e) => Section.fromJson(e)).toList();

  Future<List<Category>> getCategories({int? sectionId}) async =>
      (await api.fetchCategories(sectionId: sectionId))
          .map((e) => Category.fromJson(e))
          .toList();

  Future<List<Subcategory>> getSubcategories({int? categoryId}) async =>
      (await api.fetchSubcategories(categoryId: categoryId))
          .map((e) => Subcategory.fromJson(e))
          .toList();

  // create
  Future<int> create({
    required String title,
    required String address,
    required ItemCondition condition,
    required bool deposit,
    required List<String> mainPhotos,
    String? description,
    double? priceHour,
    double? priceDay,
    double? priceMonth,
    List<String>? tags, // в API уйдёт CSV
    String? brand,
    String? serialNumber,
    List<String>? equipmentList, // в API уйдёт как строка через запятую
    String? damageDescription,
    int? sectionId,
    int? categoryId,
    int? subcategoryId,
    List<String>? detailedPhotos,
  }) async {
    final m = await api.createItem(
      title: title,
      address: address,
      condition: condition.toApi(),
      deposit: deposit,
      mainPhotoFilePaths: mainPhotos,
      description: description,
      priceHour: priceHour,
      priceDay: priceDay,
      priceMonth: priceMonth,
      tagsCsv: (tags ?? []).where((e) => e.trim().isNotEmpty).join(','),
      brand: brand,
      serialNumber: serialNumber,
      equipmentList:
          (equipmentList ?? []).where((e) => e.trim().isNotEmpty).join(','),
      damageDescription: damageDescription,
      sectionId: sectionId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      detailedPhotoFilePaths: detailedPhotos,
    );
    return (m['id'] as num).toInt();
  }
}
