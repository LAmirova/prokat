import 'package:dio/dio.dart';
import 'package:prokat_app/core/network/dio_client.dart';

class AccountApi {
  final Dio _dio = dio;

  Future<Map<String, dynamic>> getMe() async {
    final r = await _dio.get('/users/me');
    return (r.data as Map<String, dynamic>);
  }

  /// Загрузка паспортных данных (ожидаем фото/сканы)
  /// Параметр `files` — пути к локальным файлам.
  Future<void> uploadPassport(List<String> files) async {
    final form = FormData();
    for (final p in files) {
      form.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(p, filename: p.split('/').last),
      ));
    }
    await _dio.post(
      '/users/me/upload_passport',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
