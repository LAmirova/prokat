// lib/features/listings/data/listings_api.dart
import 'package:dio/dio.dart';
import 'package:prokat_app/core/network/dio_client.dart';

class ListingsApi {
  // ------- READ -------
  Future<List<Map<String, dynamic>>> fetchItems({
    String? searchQuery,
    int skip = 0,
    int limit = 20,
    Map<String, dynamic>? extra,
  }) async {
    final qp = <String, dynamic>{'skip': skip, 'limit': limit};
    if (searchQuery != null && searchQuery.isNotEmpty)
      qp['search_query'] = searchQuery;
    if (extra != null) qp.addAll(extra);
    final res = await dio.get('/items/', queryParameters: qp);
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchMyItems(
      {int skip = 0, int limit = 20}) async {
    final common = {
      'skip': skip,
      'limit': limit,
      'include_statuses': 'moderation,published'
    };
    try {
      final r1 = await dio.get('/items/my', queryParameters: common);
      return (r1.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) != 404) rethrow;
    }
    try {
      final r2 = await dio
          .get('/items/', queryParameters: {...common, 'owner_me': true});
      return (r2.data as List).cast<Map<String, dynamic>>();
    } catch (_) {}
    final r3 = await dio
        .get('/items/', queryParameters: {...common, 'owner_id': 'me'});
    return (r3.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchItem(int id) async {
    final res = await dio.get('/items/$id');
    return (res.data as Map<String, dynamic>);
  }

  // ------- TAXONOMY -------
  Future<List<Map<String, dynamic>>> fetchSections(
      {int skip = 0, int limit = 100}) async {
    final res = await dio
        .get('/sections/', queryParameters: {'skip': skip, 'limit': limit});
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchCategories(
      {int? sectionId, int skip = 0, int limit = 100}) async {
    final qp = <String, dynamic>{'skip': skip, 'limit': limit};
    if (sectionId != null) qp['section_id'] = sectionId;
    final res = await dio.get('/categories/', queryParameters: qp);
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchSubcategories(
      {int? categoryId, int skip = 0, int limit = 100}) async {
    final qp = <String, dynamic>{'skip': skip, 'limit': limit};
    if (categoryId != null) qp['category_id'] = categoryId;
    final res = await dio.get('/subcategories/', queryParameters: qp);
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  // ------- CREATE -------
  /// Полностью покрывает Body_create_item_items__post из OpenAPI:
  /// обязательные: title, address, condition, deposit, main_photos
  /// опциональные: description, prices, tags, brand, serial_number, equipment_list, damage_description,
  ///               section_id, category_id, subcategory_id, detailed_photos
  Future<Map<String, dynamic>> createItem({
    required String title,
    required String address,
    required String condition, // 'used'|'new'
    required bool deposit,
    required List<String> mainPhotoFilePaths,
    String? description,
    double? priceHour,
    double? priceDay,
    double? priceMonth,
    String? tagsCsv, // "tag1,tag2"
    String? brand,
    String? serialNumber,
    String? equipmentList, // "Кейс, Зарядка" — сервер ждёт string (или null)
    String? damageDescription, // string (или null)

    int? sectionId,
    int? categoryId,
    int? subcategoryId,
    List<String>? detailedPhotoFilePaths,
  }) async {
    final form = FormData();

    form.fields.add(MapEntry('title', title));
    form.fields.add(MapEntry('address', address));
    form.fields.add(MapEntry('condition', condition));
    form.fields.add(MapEntry('deposit', deposit.toString()));

    if (description != null && description.isNotEmpty)
      form.fields.add(MapEntry('description', description));
    if (priceHour != null)
      form.fields.add(MapEntry('price_hour', priceHour.toString()));
    if (priceDay != null)
      form.fields.add(MapEntry('price_day', priceDay.toString()));
    if (priceMonth != null)
      form.fields.add(MapEntry('price_month', priceMonth.toString()));

    if (tagsCsv != null && tagsCsv.isNotEmpty)
      form.fields.add(MapEntry('tags', tagsCsv));
    if (brand != null && brand.isNotEmpty)
      form.fields.add(MapEntry('brand', brand));
    if (serialNumber != null && serialNumber.isNotEmpty)
      form.fields.add(MapEntry('serial_number', serialNumber));
    if (equipmentList != null && equipmentList.isNotEmpty)
      form.fields.add(MapEntry('equipment_list', equipmentList));
    if (damageDescription != null && damageDescription.isNotEmpty) {
      form.fields.add(MapEntry('damage_description', damageDescription));
    }

    if (sectionId != null)
      form.fields.add(MapEntry('section_id', sectionId.toString()));
    if (categoryId != null)
      form.fields.add(MapEntry('category_id', categoryId.toString()));
    if (subcategoryId != null)
      form.fields.add(MapEntry('subcategory_id', subcategoryId.toString()));

    // main_photos (array, required)
    for (final p in mainPhotoFilePaths) {
      form.files.add(MapEntry(
        'main_photos',
        await MultipartFile.fromFile(p, filename: p.split('/').last),
      ));
    }
    // detailed_photos (array, optional)
    if (detailedPhotoFilePaths != null) {
      for (final p in detailedPhotoFilePaths) {
        form.files.add(MapEntry(
          'detailed_photos',
          await MultipartFile.fromFile(p, filename: p.split('/').last),
        ));
      }
    }

    final res = await dio.post(
      '/items/',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return (res.data as Map<String, dynamic>);
  }
}
