// lib/features/listings/data/listings_api.dart
import 'package:dio/dio.dart';
import 'package:prokat_app/core/network/dio_client.dart'; // единый Dio с интерцептором токена

class ListingsApi {
  /// Общий каталог (публичный)
  Future<List<Map<String, dynamic>>> fetchItems({
    String? searchQuery,
    int skip = 0,
    int limit = 20,
    Map<String, dynamic>? extra, // доп.параметры (status и т.п.)
  }) async {
    final qp = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // если бэкенд ждёт другой ключ — замени здесь
      qp['search_query'] = searchQuery;
    }
    if (extra != null) qp.addAll(extra);

    final res = await dio.get('/items/', queryParameters: qp);
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  /// Мои объявления (включая модерацию)
  /// Пытаемся разными способами, чтобы подстроиться под бэкенд:
  /// 1) GET /items/my
  /// 2) GET /items/?owner_me=true
  /// 3) GET /items/?owner_id=me
  Future<List<Map<String, dynamic>>> fetchMyItems({
    int skip = 0,
    int limit = 20,
  }) async {
    final common = {
      'skip': skip,
      'limit': limit,
      'include_statuses': 'moderation,published',
    };

    // 1) /items/my
    try {
      final r1 = await dio.get('/items/my', queryParameters: common);
      return (r1.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) != 404) rethrow;
    }

    // 2) /items/?owner_me=true
    try {
      final r2 = await dio
          .get('/items/', queryParameters: {...common, 'owner_me': true});
      return (r2.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (_) {}

    // 3) /items/?owner_id=me
    final r3 = await dio
        .get('/items/', queryParameters: {...common, 'owner_id': 'me'});
    return (r3.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchItem(int id) async {
    final res = await dio.get('/items/$id');
    return (res.data as Map<String, dynamic>);
  }

  /// Создать объявление. Возвращает JSON созданного объекта.
  Future<Map<String, dynamic>> createItem({
    required String title,
    required String address,
    required String condition, // 'used'|'new'
    required bool deposit,
    List<String> mainPhotoFilePaths = const [],
    double? priceHour,
    double? priceDay,
    double? priceMonth,
    String? description,
    String? tagsCsv,
    int? sectionId,
    int? categoryId,
    int? subcategoryId,
  }) async {
    final form = FormData.fromMap({
      'title': title,
      'address': address,
      'condition': condition,
      'deposit': deposit,
      if (priceHour != null) 'price_hour': priceHour,
      if (priceDay != null) 'price_day': priceDay,
      if (priceMonth != null) 'price_month': priceMonth,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (tagsCsv != null && tagsCsv.isNotEmpty) 'tags': tagsCsv,
      if (sectionId != null) 'section_id': sectionId,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      'main_photos': [
        for (final p in mainPhotoFilePaths)
          await MultipartFile.fromFile(p, filename: p.split('/').last),
      ],
    });

    final res = await dio.post(
      '/items/',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return (res.data as Map<String, dynamic>);
  }
}
